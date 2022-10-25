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

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(TagTests) + "_" + name;
            return newName;
        }


        [TestMethod]
        public void InsertTest()
        {
            var target = NewTag(NewName());
            TestDbContext.Add(target);
            var changesCnt = TestDbContext.SaveChanges(); 
            Assert.AreEqual(target.TagName, TestDbContext.Tags.First(t => t.TagId == target.TagId).TagName);
        }
    }
}
