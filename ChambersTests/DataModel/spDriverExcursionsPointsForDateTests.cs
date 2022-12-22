using System;
using System.Collections.Generic;
using System.Linq;
using System.Resources;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class spDriverExcursionsPointsForDateTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(spDriverExcursionsPointsForDateTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task EmptyResultsTest() {
           var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
               ForDate: new DateTime(2222, 1, 22), StageDateId: -1, TagName: "");
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task OneHighExcursionPointTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var highExcursionPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxValue * 1.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                ForDate: baseDate, StageDateId: pointsPace.StageDateId, TagName: tag.TagName);
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().FirstExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, highExcursionPoint.Time);
        }

        [TestMethod]
        public async Task OneHighExcursionWithRampsTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MaxValue * 0.9));
            var highExcursionPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxValue * 1.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MaxValue * 0.8));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                ForDate: baseDate, StageDateId: pointsPace.StageDateId, TagName: tag.TagName);
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().RampInDate, rampInPoint.Time);
            Assert.AreEqual(result.First().FirstExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().RampOutDate, rampOutPoint.Time);
        }

        [TestMethod]
        public async Task TwoLowExcursionWithRampsTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MinValue * 1.1));
            var firstLowExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddMinutes(10), (float)(stage.MinValue * 0.9));
            var lastLowExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddMinutes(20), (float)(stage.MinValue * 0.8));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MinValue * 1.2));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                ForDate: baseDate, StageDateId: pointsPace.StageDateId, TagName: tag.TagName);
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().RampInDate, rampInPoint.Time);
            Assert.AreEqual(result.First().RampInValue, rampInPoint.Value);
            Assert.AreEqual(result.First().FirstExcDate, firstLowExcPoint.Time);
            Assert.AreEqual(result.First().FirstExcValue, firstLowExcPoint.Value);
            Assert.AreEqual(result.First().LastExcDate, lastLowExcPoint.Time);
            Assert.AreEqual(result.First().LastExcValue, lastLowExcPoint.Value);
            Assert.AreEqual(result.First().RampOutDate, rampOutPoint.Time);
            Assert.AreEqual(result.First().RampOutValue, rampOutPoint.Value);
        }
    }
}
