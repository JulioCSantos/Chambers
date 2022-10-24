using ChambersDataModel;
using ChambersTests.DataModel;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests
{
    public static class BootStrap
    {
        #region NextId
        public static int Id { get; private set; } = 1000;
        public static Func<int> NextId = () => { Id++; return Id; };
        #endregion NextId

        #region DbSharedcontext
        private static ChambersDbContext? _dbContext;
        public static ChambersDbContext DbContext {
            get {
                if (_dbContext != null) { return _dbContext; }

                _dbContext = new ChambersDbContext();
                var sql = _dbContext.Database.GenerateCreateScript();

                return _dbContext;
            }

        }
        #endregion DbSharedSharedcontext

        #region DbInMemorycontext
        private static ChambersDbContext? _dbInMemorycontext;
        public static ChambersDbContext InMemoryDbcontext {
            get {
                if (_dbInMemorycontext != null) { return _dbInMemorycontext; }

                var contextOptions = new DbContextOptionsBuilder<ChambersDbContext>()
                    .UseInMemoryDatabase(nameof(TagTests)).Options;
                _dbInMemorycontext = new ChambersDbContext(contextOptions);

                return _dbInMemorycontext;
            }
        }
        #endregion DbInMemorycontext

        #region GetNamedContext
        private static Dictionary<string, ChambersDbContext> contextsDictionary = new();
        public static ReadOnlyDictionary<string, ChambersDbContext> ChambersDictionary = new (contextsDictionary);
        public static ChambersDbContext GetNamedContext(string contextName)
        {
            if (ChambersDictionary.ContainsKey(contextName)) { return ChambersDictionary[contextName]; }

            var dbContext = new ChambersDbContext(contextName);
            contextsDictionary.Add(contextName, dbContext);
            dbContext.Database.EnsureCreated();
            Assert.IsTrue(ChambersDictionary.ContainsKey(contextName));
            return ChambersDictionary[contextName];
        }
        #endregion GetNamedContext


        public static Tag NewTag(this DbContext context, [CallerMemberName] string? tagName = null) {
            var tag = new Tag() { TagId = BootStrap.NextId(), TagName = tagName };
            context.Add(tag);
            return tag;
        }
    }
}
