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

        //ChambersDataModel.StoredProcs.spGetStagesLimitsAndDates.sql
        //    ChambersDataModel.Views.PointsStepsLogNextValues.sql
        //ChambersDataModel.Views.StagesLimitsAndDates.sql
        //    ChambersDataModel.Functions.fnGetOverlappingDates.SQL

        //public void InjectView(string sqlFileName, string viewName)
        //{
        //    var assembly = typeof(ChambersDbContext).Assembly;
        //    var assemblyName = assembly.FullName?.Substring(0, assembly.FullName.IndexOf(','));
        //    var resource = assembly.GetManifestResourceStream($"{assemblyName}.Views.{sqlFileName}");
        //    var sqlQuery = new StreamReader(resource ??
        //                                    throw new InvalidOperationException(
        //                                        $"Assembly resource 'Views.{sqlFileName}' not found"))
        //        .ReadToEnd();
        //    //we always delete the old view, in case the sql query has changed
        //    this.Database.ExecuteSqlRaw($"IF OBJECT_ID('{viewName}') IS NOT NULL BEGIN DROP VIEW {viewName} END");
        //    //creating a view based on the sql query
        //    this.Database.ExecuteSqlRaw(sqlQuery);
        //}

        //public void InjectStoredProc(string sqlFileName, string storedProcName)
        //{
        //    var assembly = typeof(ChambersDbContext).Assembly;
        //    var assemblyName = assembly.FullName?.Substring(0, assembly.FullName.IndexOf(','));
        //    var resource = assembly.GetManifestResourceStream($"{assemblyName}.StoredProcs.{sqlFileName}");
        //    var sqlQuery = new StreamReader(resource ??
        //                                    throw new InvalidOperationException(
        //                                        $"Assembly resource 'StoredProcs.{sqlFileName}' not found"))
        //        .ReadToEnd();
        //    //we always delete the old view, in case the sql query has changed
        //    this.Database.ExecuteSqlRaw(
        //        $"IF OBJECT_ID('{storedProcName}') IS NOT NULL BEGIN DROP PROCEDURE {storedProcName} END");
        //    //creating a view based on the sql query
        //    this.Database.ExecuteSqlRaw(sqlQuery);
        //}

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
