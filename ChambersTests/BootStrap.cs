using ChambersDataModel;
using ChambersTests.DataModel;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
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

                _dbContext = new ChambersDbContext("ChambersTest");
                _dbContext.Database.EnsureCreated();
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
        public static Dictionary<string, ChambersDbContext> _chambersDictionary = new ();
        public static ChambersDbContext GetNamedContext(string contextName)
        {
            if (_chambersDictionary.ContainsKey(contextName)) { return _chambersDictionary[contextName]; }

            _chambersDictionary.Add(contextName, new ChambersDbContext());

            return _chambersDictionary[contextName];
        }
        #endregion GetNamedContext


        public static Tag NewTag(this DbContext context, [CallerMemberName] string? tagName = null) {
            var tag = new Tag() { TagId = BootStrap.NextId(), TagName = tagName };
            context.Add(tag);
            return tag;
        }
    }
}
