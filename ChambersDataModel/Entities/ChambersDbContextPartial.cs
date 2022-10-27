using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Dynamic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace ChambersDataModel.Entities
{
    public partial class ChambersDbContext : DbContext
    {
        public string? DatabaseName { get; }

        public ChambersDbContext(string databaseName) {
            DatabaseName = databaseName;
        }

        public ChambersDbContext(string databaseName, DbContextOptions<ChambersDbContext> options)
            :base(options) {
            DatabaseName = databaseName;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder) {
            if (!optionsBuilder.IsConfigured) {
                if (DatabaseName == null) {
                    optionsBuilder.UseSqlServer("Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True");
                }
                else {
                    optionsBuilder.UseSqlServer($"Data Source=ASUS-Strange;Initial Catalog={DatabaseName};Integrated Security=True");
                }
                //#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see http://go.microsoft.com/fwlink/?LinkId=723263.
                //                optionsBuilder.UseSqlServer("Data Source=ASUS-Strange;Initial Catalog=ELChambers;Integrated Security=True");
            }
        }

        public void InjectEmbededSqlResources()
        {
            var assembly = typeof(ChambersDbContext).Assembly;
            var orderedResourcesList = new SortedList<int,NameParsed>();
            assembly.GetManifestResourceNames().ToList()
                .ForEach(name => {
                    var nameParsed = new NameParsed(name);
                    orderedResourcesList.Add(nameParsed.Sequence, nameParsed);
                });


            foreach (var parsedName in orderedResourcesList.Values)
            {
                var resource = assembly.GetManifestResourceStream(parsedName.ResourceName);
                if (resource == null) { continue; }

                var sqlQuery = new StreamReader(resource).ReadToEnd(); 

                switch (parsedName.SqlType)
                {
                    case ("StoredProcs"):
                        this.Database.ExecuteSqlRaw($"IF OBJECT_ID('{parsedName.SqlName}') IS NOT NULL BEGIN DROP PROCEDURE {parsedName.SqlName} END");
                        break;
                    case ("Views"):
                        this.Database.ExecuteSqlRaw($"IF OBJECT_ID('{parsedName.SqlName}') IS NOT NULL BEGIN DROP VIEW {parsedName.SqlName} END");
                        break;
                    case ("Functions"):
                        this.Database.ExecuteSqlRaw($"IF OBJECT_ID('{parsedName.SqlName}') IS NOT NULL BEGIN DROP FUNCTION {parsedName.SqlName} END");
                        break;
                }

                this.Database.ExecuteSqlRaw(sqlQuery);
            }
        }

        public struct NameParsed
        {
            public readonly string AssemblyName;
            public readonly string SqlType;

            public readonly string ResourceName; 
            public readonly string SqlName;

            public int Sequence { get; private set; }

            public NameParsed(string name)
            {
                var parts = name.Split('.');
                AssemblyName = parts[0];
                SqlType = parts[1];
                ResourceName = name;
                var orderNameSplit = parts[2].Split('_');
                Sequence = int.Parse(orderNameSplit[0]);
                SqlName = orderNameSplit[1];
            }

        }

  
        //https://stackoverflow.com/questions/5466677/undo-changes-in-entity-framework-entities
        public void RollBack()
        {
            var context = this;
            var changedEntries = context.ChangeTracker.Entries()
                .Where(x => x.State != EntityState.Unchanged).ToList();

            foreach (var entry in changedEntries)
            {
                switch (entry.State)
                {
                    case EntityState.Modified:
                        entry.CurrentValues.SetValues(entry.OriginalValues);
                        entry.State = EntityState.Unchanged;
                        break;
                    case EntityState.Added:
                        entry.State = EntityState.Detached;
                        break;
                    case EntityState.Deleted:
                        entry.State = EntityState.Unchanged;
                        break;
                }
            }
        }
    }
}
