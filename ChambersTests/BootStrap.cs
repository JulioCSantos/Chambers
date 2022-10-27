using ChambersTests.DataModel;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Net.NetworkInformation;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests
{
    public static class BootStrap
    {
        #region ChambersTests Literal
        public const string ChambersTests = nameof(ChambersTests);
        #endregion ChambersTests Literal

        #region TestDbContext
        public static ChambersDbContext TestDbContext { get; }
        #endregion TestDbContext

        #region NextId

        private static int _id;
        public static Func<int> NextId = () => { Interlocked.Increment(ref _id); return _id; };
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
        private static readonly Dictionary<string, ChambersDbContext> contextsDictionary;
        public static ReadOnlyDictionary<string, ChambersDbContext> ChambersDictionary;
        public static ChambersDbContext GetNamedContext(string contextName)
        {
            if (ChambersDictionary.ContainsKey(contextName)) { return ChambersDictionary[contextName]; }

            var dbContext = new ChambersDbContext(contextName);
            contextsDictionary.Add(contextName, dbContext);
            dbContext.Database.EnsureDeleted();
            dbContext.Database.EnsureCreated();
            dbContext.InjectEmbededSqlResources();
            Assert.IsTrue(ChambersDictionary.ContainsKey(contextName));
            return ChambersDictionary[contextName];
        }
        #endregion GetNamedContext


        static BootStrap()
        {
            _id = 1000;
            contextsDictionary = new Dictionary<string, ChambersDbContext>();
            ChambersDictionary = new ReadOnlyDictionary<string, ChambersDbContext>(contextsDictionary);
            TestDbContext = GetNamedContext(ChambersTests);
        }
    }
}
