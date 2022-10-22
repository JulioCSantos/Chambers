using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using ChambersDataModel;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class TagTests
    {

        #region Context
        private static ChambersDbContext Context = BootStrap.InMemoryDbcontext;
        #endregion Context

        public static Tag NewTag([CallerMemberName] string? tagName = null) {
            var tag = new Tag() { TagId = BootStrap.NextId(), TagName = tagName };
            return tag;
        }

        public static Lazy<Tag> InsertTestTag = new Lazy<Tag>(() => NewTag(nameof(InsertTestTag)));

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

        [TestMethod]
        public void InsertTest2()
        {
            var target = Context.NewTag(nameof(InsertTest2));
            PreTest(target);
            Context.Add(target);
            var changesCnt = Context.SaveChanges();
            Assert.AreEqual(1, changesCnt);
            Assert.AreEqual(1, Context.Tags.Count());
            Assert.AreEqual(target.TagName, Context.Tags.First().TagName);
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

    }
}
