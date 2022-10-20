using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ChambersDataModel;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class TagTests
    {
        public static int Id { get; private set; } = 1000;

        public static Func<int> NextId = () => { Id++; return Id; };

        private static ChambersDbContext? _context;

        public static ChambersDbContext Context {
            //get
            //{
            //    if (_context != null) { return _context; }

            //    _context = new ChambersDbContext();

            //    return _context;
            //}
            get {
                if (_context != null) { return _context; }

                var contextOptions = new DbContextOptionsBuilder<ChambersDbContext>()
                    .UseInMemoryDatabase(nameof(TagTests)).Options;
                _context = new ChambersDbContext(contextOptions);

                return _context;
            }
        }

        public static Lazy<Tag> InsertTestTag = new Lazy<Tag>(
            () => new Tag(){TagId = NextId(), TagName = nameof(InsertTestTag)}
        );


        [TestMethod]
        public void InsertTest()
        {
            var target = InsertTestTag.Value;
            PreTest(target);
            Context.Add(target);
            var changesCnt = Context.SaveChanges(); 
            Assert.AreEqual(1,changesCnt);
            Assert.AreEqual(1, Context.Tags.Count());
            Assert.AreEqual(target.TagName,Context.Tags.First().TagName);
            PostTest(target);
        }

        private void PreTest(Tag tag)
        {
            var prev = Context.Tags.FirstOrDefault(t => t.TagId == tag.TagId);
            if (prev == null) { return;}
            Context.Tags.Remove(prev);
            Context.SaveChanges();
        }

        private void PostTest(Tag tag) {
            var prev = Context.Tags.FirstOrDefault(t => t.TagId == tag.TagId);
            if (prev == null) { return;}
            Context.Tags.Remove(prev);
            Context.SaveChanges();
        }

        [ClassCleanup]
        public static void CleanTags() {
           //Context.Database.ExecuteSqlRaw("TRUNCATE TABLE [Tags]");
           //Context.Database.CloseConnection();
           Context.Dispose();
        }
    }
}
