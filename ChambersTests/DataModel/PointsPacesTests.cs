using ChambersDataModel;
using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class PointsPaceTests
    {

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StageDatesTests) + "_" + name;
            return newName;
        }

        public static PointsPace NewPointsPace(string stageName) {
            var tag = TagTests.NewTag(stageName);
            TestDbContext.Tags.Add(tag);
            var pointsPace = new PointsPace() { TagId = tag.TagId };
            return pointsPace;
        }

        [TestMethod]
        public void InsertTest()
        {
            var name = NewName();
            var pointsPace = NewPointsPace(name);
            pointsPace.NextStepStartTime = new DateTime(2022, 01, 01);
            pointsPace.StepSizeDays = 3;
            TestDbContext.PointsPaces.Add(pointsPace);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(2, savedCount);
        }
    }
}
