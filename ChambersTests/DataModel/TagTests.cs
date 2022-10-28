using System.Runtime.CompilerServices;
using Chambers.Common;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class TagTests
    {
        //public static Tag NewTag([CallerMemberName] string? tagName = null) {

        //        var tag = new Tag() { TagId = BootStrap.NextId(), TagName = tagName };
        //        return tag;
        //}

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(TagTests) + "_" + name;
            return newName;
        }


        [TestMethod]
        public void InsertTest()
        {
            var target = new Tag(IntExtensions.NextId(), NewName());
            TestDbContext.Add(target);
            var changesCnt = TestDbContext.SaveChanges(); 
            Assert.AreEqual(1, changesCnt);
            Assert.AreEqual(target.TagName, TestDbContext.Tags.First(t => t.TagId == target.TagId).TagName);
        }
    }
}
