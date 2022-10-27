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

        public static PointsPace NewPointsPace(string stageName, DateTime? nextStartDate = null, int? stepSizeDays = null ) {
            var tag = TagTests.NewTag(stageName);
            TestDbContext.Tags.Add(tag);
            var pointsPace = new PointsPace() { TagId = tag.TagId };
            if (nextStartDate != null) {pointsPace.NextStepStartDate = (DateTime)nextStartDate;}
            if (stepSizeDays != null) {pointsPace.StepSizeDays = (int)stepSizeDays;}

            return pointsPace;
        }

        [TestMethod]
        public void InsertTest()
        {
            var name = NewName();
            var pointsPace = NewPointsPace(name);
            pointsPace.NextStepStartDate = new DateTime(2022, 01, 01);
            pointsPace.StepSizeDays = 3;
            TestDbContext.PointsPaces.Add(pointsPace);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(2, savedCount);
        }

        [TestMethod]
        public void PointsStepsLogNextValueTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2022, 02, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            var stageDate = StageDatesTests.NewStageDates(pointsPace.Tag, new DateTime(2022,01,01), new DateTime(2022,12,31));
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
        }
    }
}
