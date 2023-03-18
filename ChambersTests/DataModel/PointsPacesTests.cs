using ChambersDataModel;
using System.Runtime.CompilerServices;
using Chambers.Common;
using Microsoft.EntityFrameworkCore;
using ChambersDataModel.Entities;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class PointsPaceTests
    {

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(PointsPaceTests) + "_" + name;
            return newName;
        }

        public static PointsPace NewPointsPace(string stageName, DateTime? nextStartDate = null
            , int? stepSizeDays = null, int? minThreshold = 100, int? maxThreshold = 200 ) {
            var tag = new Tag(IntExtensions.NextId(), tagName: stageName);
            var stage = new Stage(tag, minThreshold, maxThreshold);
            var stageDate = new StagesDate(stage);
            TestDbContext.Tags.Add(tag);
            TestDbContext.Stages.Add(stage);
            TestDbContext.StagesDates.Add(stageDate);
            var pointsPace = new PointsPace() { StageDate = stageDate };
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
            Assert.AreEqual(0,pointsPace.PaceId);
            TestDbContext.SaveChanges();
            Assert.IsTrue(pointsPace.PaceId > 0);
            Assert.AreEqual(name, pointsPace.StageDate.Stage.StageName);
        }

        [TestMethod]
        public void PointsStepsLogNextValueAllInclusiveTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2022, 02, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            pointsPace.StageDate.SetDates(new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            pointsPace.StageDate.Stage.SetThresholds(80, 100);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues
                .Where(ps => ps.StageDateId == pointsPace.StageDateId);
            Assert.IsNotNull(result);
            Assert.AreEqual(1, result.Count());
            var firstLogValue = result.First();
            Assert.AreEqual(pointsPace.NextStepStartDate, firstLogValue.StartDate);
            Assert.AreEqual(pointsPace.NextStepEndDate, firstLogValue.EndDate);
        }

        [TestMethod]
        public void PointsStepsLogNextValueEarlyStartedTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2021, 12, 31), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            pointsPace.StageDate.SetDates(new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            pointsPace.StageDate.Stage.SetThresholds(10, 100);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues
                .Where(ps => ps.StageDateId == pointsPace.StageDateId);
            Assert.IsNotNull(result);
            Assert.AreEqual(1, result.Count());
            var firstLogValue = result.First();
            Assert.AreEqual(pointsPace.StageDate.StartDate, firstLogValue.StartDate);
            Assert.AreEqual(pointsPace.NextStepEndDate, firstLogValue.EndDate);
        }

        [TestMethod]
        public void PointsStepsLogNextValueLateStartedTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2022, 12, 31), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            pointsPace.StageDate.SetDates(new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            pointsPace.StageDate.Stage.SetThresholds(10, 100);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues
                .Where(ps => ps.StageDateId == pointsPace.StageDateId);
            Assert.IsNotNull(result);
            Assert.AreEqual(1, result.Count());
            var firstLogValue = result.First();
            Assert.AreEqual(pointsPace.NextStepStartDate, firstLogValue.StartDate);
            Assert.AreEqual(pointsPace.StageDate.EndDate, firstLogValue.EndDate);
        }

        [TestMethod]
        public void PointsStepsLogNextValueOutsideTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2020, 01, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            pointsPace.StageDate.SetDates(new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            pointsPace.StageDate.Stage.SetThresholds(10, 100);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues
                .Where(ps => ps.StageDateId == pointsPace.StageDateId);
            Assert.IsNotNull(result);
            Assert.AreEqual(0, result.Count());
        }

        [TestMethod]
        public void PointsStepsLogNextValueTwoRacesTest() {
            var newName = NewName();
            var name1 = newName + 1;
            var pointsPace1 = NewPointsPace(name1, new DateTime(2022, 02, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace1);
            pointsPace1.StageDate.SetDates(new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            pointsPace1.StageDate.Stage.SetThresholds(10, 100);
            var name2 = newName + 2;
            var pointsPace2 = NewPointsPace(name2, new DateTime(2022, 03, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace2);
            pointsPace2.StageDate.SetDates(new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            pointsPace2.StageDate.Stage.SetThresholds(10, 100);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(8, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues
                .Where(ps => ps.StageName != null && ps.StageName.StartsWith(newName));
            Assert.IsNotNull(result);
            Assert.AreEqual(2, result.Count());
        }
    }
}
