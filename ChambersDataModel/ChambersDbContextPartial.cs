using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel
{
    public partial class ChambersDbContext : DbContext
    {
        public void OnModelCreatingPartial(ModelBuilder modelBuilder)
        {

        }

        public void InjectView(string sqlFileName, string viewName)
        {
            var assembly = typeof(ChambersDbContext).Assembly;
            var assemblyName = assembly.FullName?.Substring(0, assembly.FullName.IndexOf(','));
            var resource = assembly.GetManifestResourceStream($"{assemblyName}.Views.{sqlFileName}");
            var sqlQuery = new StreamReader(resource ??
                                            throw new InvalidOperationException(
                                                $"Assembly resource 'Views.{sqlFileName}' not found"))
                .ReadToEnd();
            //we always delete the old view, in case the sql query has changed
            this.Database.ExecuteSqlRaw($"IF OBJECT_ID('{viewName}') IS NOT NULL BEGIN DROP VIEW {viewName} END");
            //creating a view based on the sql query
            this.Database.ExecuteSqlRaw(sqlQuery);
        }

        public void InjectStoredProc(string sqlFileName, string storedProcName)
        {
            var assembly = typeof(ChambersDbContext).Assembly;
            var assemblyName = assembly.FullName?.Substring(0, assembly.FullName.IndexOf(','));
            var resource = assembly.GetManifestResourceStream($"{assemblyName}.StoredProcs.{sqlFileName}");
            var sqlQuery = new StreamReader(resource ??
                                            throw new InvalidOperationException(
                                                $"Assembly resource 'StoredProcs.{sqlFileName}' not found"))
                .ReadToEnd();
            //we always delete the old view, in case the sql query has changed
            this.Database.ExecuteSqlRaw(
                $"IF OBJECT_ID('{storedProcName}') IS NOT NULL BEGIN DROP PROCEDURE {storedProcName} END");
            //creating a view based on the sql query
            this.Database.ExecuteSqlRaw(sqlQuery);
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
