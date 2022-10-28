﻿using ChambersDataModel;
using System.Runtime.CompilerServices;
using Chambers.Common;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class PointsPaceTests
    {

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(PointsPaceTests) + "_" + name;
            return newName;
        }

        public static PointsPace NewPointsPace(string stageName, DateTime? nextStartDate = null, int? stepSizeDays = null ) {
            var tag = new Tag(IntExtensions.NextId(), stageName);
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
        public void PointsStepsLogNextValueAllInclusiveTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2022, 02, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            var stageDate = new StagesDate(new Stage(pointsPace.Tag, 10, 100), new DateTime(2022,01,01), new DateTime(2022,12,31));
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues;
            Assert.IsNotNull(result);
            Assert.AreEqual(1, result.Count());
            var firstLogValue = result.First();
            Assert.AreEqual(pointsPace.NextStepStartDate, firstLogValue.NextStepStartDate);
            Assert.AreEqual(pointsPace.NextStepEndDate, firstLogValue.NextStepEndDate);
        }

        [TestMethod]
        public void PointsStepsLogNextValueEarlyStartedTest() {
            var name = NewName();
            var pointsPace = NewPointsPace(name, new DateTime(2022, 02, 01), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            var stageDate = new StagesDate(new Stage(pointsPace.Tag,10,100), new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            Assert.AreEqual(4, savedCount);
            var result = TestDbContext.PointsStepsLogNextValues.Where(ps => ps.StageName == name);
            Assert.IsNotNull(result);
            Assert.AreEqual(1, result.Count());
            var firstLogValue = result.First();
            Assert.AreEqual(pointsPace.NextStepStartDate, firstLogValue.NextStepStartDate);
            Assert.AreEqual(pointsPace.NextStepEndDate, firstLogValue.NextStepEndDate);
        }
    }
}
