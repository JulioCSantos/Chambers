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
        private static ChambersDbContext? _context;

        public static ChambersDbContext Context {
            get {
                if (_context != null) { return _context; }

                var contextOptions = new DbContextOptionsBuilder<ChambersDbContext>()
                    .UseInMemoryDatabase(nameof(TagTests)).Options;
                _context = new ChambersDbContext(contextOptions);

                return _context;
            }
        }

        public TagTests()
        {

        }

        [TestMethod]
        public void InstantiationTest()
        {
            PreTest();
            var target = new Tag { TagName = "T1" };
            Context.Add(target);
            var chngsCnt = Context.SaveChanges();
            Assert.AreEqual(1,chngsCnt);
            Assert.AreEqual(1, Context.Tags.Count());
            Assert.AreEqual("T1",Context.Tags.First().TagName);
            PostTest();
        }

        private void PreTest() {
            var prev = Context.Tags.FirstOrDefault(t => t.TagName == "T1");
            if (prev == null) { return;}
            Context.Tags.Remove(prev);
            Context.SaveChanges();
        }

        private void PostTest() {
            var prev = Context.Tags.FirstOrDefault(t => t.TagName == "T1");
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
