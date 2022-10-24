using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using ChambersDataModel;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class TagTests
    {

        public static Tag NewTag([CallerMemberName] string? tagName = null) {
            var tag = new Tag() { TagId = BootStrap.NextId(), TagName = tagName };
            return tag;
        }

        public static Lazy<Tag> InsertTestTag = new Lazy<Tag>(() => NewTag(nameof(InsertTestTag)));

        [TestMethod]
        public void InsertTest()
        {
            var target = InsertTestTag.Value;
            var prevTagsCount = TestDbContext.Tags.Count();
            TestDbContext.Add(target);
            var changesCnt = TestDbContext.SaveChanges(); 
            Assert.AreEqual(1,changesCnt);
            Assert.AreEqual(prevTagsCount + 1, TestDbContext.Tags.Count());
            Assert.AreEqual(target.TagName, TestDbContext.Tags.First(t => t.TagId == target.TagId).TagName);
        }
    }
}
