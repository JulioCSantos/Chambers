using System;
using System.Collections.Generic;
using System.Linq;
using System.Resources;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

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
        public async Task EmptyResultsTest()
        {
            TestDbContext.IsPreservedForTest = true;
           var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                new DateTime(2222, 1, 22), new DateTime(2222, 1, 23),"-1");
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task OneHighExcursionPointTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, hiExcPoint.Time);
        }

        [TestMethod]
        public async Task PointsPacesUpdateWithOneHighExcursionPointTest()
        {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            Assert.AreEqual(1, TestDbContext.PointsPaces.Count(pp => pp.StageDateId == pointsPace.StageDateId));
            Assert.IsTrue(TestDbContext.PointsPaces.First().ProcessedDate == null);
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3),pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(2, TestDbContext.PointsPaces.Count(pp => pp.StageDateId == pointsPace.StageDateId));
            Assert.IsTrue(TestDbContext.PointsPaces.Any(pp => pp.ProcessedDate != null));
            Assert.IsTrue(TestDbContext.PointsPaces.Any(pp => pp.ProcessedDate == null));
        }

        [TestMethod]
        public async Task OneHighExcursionPointWithNoPointsPaceTest() {
            TestDbContext.IsPreservedForTest = true;
            var tagName = NewName();
            var baseDate = DateTime.Today;
            var stageDate = new StagesDate(tagName, baseDate.AddHours(6));
            var stage = stageDate.Stage;
            stage.SetThresholds(100,300);
            var tag = stage.Tag;
            TestDbContext.StagesDates.Add(stageDate);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            var prevPointsPaces = TestDbContext.PointsPaces.AsNoTracking()
                .Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            Assert.AreEqual(0, prevPointsPaces.Count);
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(3), stageDate.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().RampInDate, rampInPoint.Time);
            Assert.AreEqual(result.First().FirstExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().RampOutDate, rampOutPoint.Time);
            var currPointsPaces = TestDbContext.PointsPaces.AsNoTracking()
                .Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            Assert.AreEqual(4, currPointsPaces.Count);
            Assert.AreEqual(1, currPointsPaces.Count(pp => pp.ProcessedDate == null));
        }

        [TestMethod]
        public async Task OneHighExcursionPointWithInitialPointsPaceTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            var prevPointsPaces = TestDbContext.PointsPaces.AsNoTracking()
                .Where(pp => pp.StageDateId == pointsPace.StageDateId).ToList();
            Assert.AreEqual(1, prevPointsPaces.Count);
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().RampInDate, rampInPoint.Time);
            Assert.AreEqual(result.First().FirstExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, highExcursionPoint.Time);
            Assert.AreEqual(result.First().RampOutDate, rampOutPoint.Time);
            var currPointsPaces = TestDbContext.PointsPaces.AsNoTracking()
                .Where(pp => pp.StageDateId == pointsPace.StageDateId).ToList();
            Assert.AreEqual(2, currPointsPaces.Count);
            Assert.AreEqual(1, currPointsPaces.Count(pp => pp.ProcessedDate == null));
        }

        [TestMethod]
        public async Task TwoLowExcursionPointsWithRampsTest()
        {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MinThreshold! * 1.1));
            var firstLowExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddMinutes(10), (float)(stage.MinThreshold! * 0.9));
            var lastLowExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddMinutes(20), (float)(stage.MinThreshold! * 0.8));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MinThreshold! * 1.2));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
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

        [TestMethod]
        public async Task ExcursionOnOffDateTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var highExcursionPoint = TestDbContext.NewCompressedPoint(tag.TagName
                , pointsPace.NextStepStartDate.AddDays(-1), (float)(stage.MaxThreshold! * 1.5));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(1),pointsPace.StageDateId.ToString());
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task TwoConsecutiveExcursionsTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            // excursion 1
            var baseDate1 = baseDate;
            var rampInPoint1 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate1.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint1 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate1, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint1 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate1.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            // excursion 2
            var baseDate2 = baseDate.AddDays(1);
            var rampInPoint2 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate2.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint2 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate2, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint2 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate2.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(2, result.Count);
            Assert.AreEqual(result.First().RampInDate, rampInPoint1.Time);
            Assert.AreEqual(result.First().FirstExcDate, highExcursionPoint1.Time);
            Assert.AreEqual(result.First().LastExcDate, highExcursionPoint1.Time);
            Assert.AreEqual(result.First().RampOutDate, rampOutPoint1.Time);
            Assert.AreEqual(result.Skip(1).First().RampInDate, rampInPoint2.Time);
            Assert.AreEqual(result.Skip(1).First().FirstExcDate, highExcursionPoint2.Time);
            Assert.AreEqual(result.Skip(1).First().LastExcDate, highExcursionPoint2.Time);
            Assert.AreEqual(result.Skip(1).First().RampOutDate, rampOutPoint2.Time);
        }

        //[TestMethod]
        public async Task TwoExcursionsOnTwoStepsTest()
        {
            var baseDate = DateTime.Today;
            var stepDays = 2;
            var baseDate1 = baseDate;
            var baseDate2 = baseDate.AddDays(stepDays);

            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate, stepDays);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            // excursion 1
            var rampInPoint1 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate1.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint1 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate1, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint1 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate1.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            // excursion 2
            var rampInPoint2 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate2.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint2 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate2, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint2 = TestDbContext.NewCompressedPoint(tag.TagName, baseDate2.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            
            // Driver run for first day. One NOT Processed PaceStep
            Assert.AreEqual(0, TestDbContext.PointsPaces.Count(pp => pp.PaceId == pointsPace.PaceId && pp.ProcessedDate != null));
            var day1 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate1.AddDays(0), baseDate1.AddDays(3),pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, day1.Count);
            Assert.AreEqual(1, TestDbContext.PointsPaces.Count(pp => pp.PaceId == pointsPace.PaceId && pp.ProcessedDate != null));
            Assert.AreEqual(1, TestDbContext.PointsStepsLogs.Count(psl => psl.StageDateId == pointsPace.StageDateId));
            
            // Driver run for second day. One Processed and one not processed (Next) PaceStep
            Assert.AreEqual(1, TestDbContext.PointsPaces.Count(pp => pp.PaceId == pointsPace.PaceId && pp.ProcessedDate != null));
            var day2 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate1.AddDays(1), baseDate1.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(0, day2.Count);
            Assert.AreEqual(1, TestDbContext.PointsPaces.Count(pp => pp.PaceId == pointsPace.PaceId && pp.ProcessedDate != null));
            Assert.AreEqual(1, TestDbContext.PointsStepsLogs.Count(psl => psl.StageDateId == pointsPace.StageDateId));
            // Driver run for third day. One Processed and one not processed (Next) PaceStep
            var day3 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate2.AddDays(0), baseDate2.AddDays(3),pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, day3.Count);
            Assert.AreEqual(1, TestDbContext.PointsPaces.Count(pp => pp.PaceId == pointsPace.PaceId && pp.ProcessedDate != null));
            Assert.AreEqual(2, TestDbContext.PointsStepsLogs.Count(psl => psl.StageDateId == pointsPace.StageDateId));

            // Driver run for third day. One Processed and one not processed (Next) PaceStep
            var day4 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate2.AddDays(1), baseDate2.AddDays(2), pointsPace.StageDateId.ToString());
            Assert.AreEqual(0, day4.Count);
            Assert.AreEqual(1, TestDbContext.PointsPaces.Count(pp => pp.PaceId == pointsPace.PaceId && pp.ProcessedDate != null));
            Assert.AreEqual(2, TestDbContext.PointsStepsLogs.Count(psl => psl.StageDateId == pointsPace.StageDateId));

            // validate both Excursions created 
            Assert.AreEqual(day1.First().RampInDate, rampInPoint1.Time);
            Assert.AreEqual(day1.First().FirstExcDate, highExcursionPoint1.Time);
            Assert.AreEqual(day1.First().LastExcDate, highExcursionPoint1.Time);
            Assert.AreEqual(day1.First().RampOutDate, rampOutPoint1.Time);
            Assert.AreEqual(day3.First().RampInDate, rampInPoint2.Time);
            Assert.AreEqual(day3.First().FirstExcDate, highExcursionPoint2.Time);
            Assert.AreEqual(day3.First().LastExcDate, highExcursionPoint2.Time);
            Assert.AreEqual(day3.First().RampOutDate, rampOutPoint2.Time);
        }

        [TestMethod]
        public async Task OneHighExcursionPointWithNullLowExcursionTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            stage.MinThreshold = null;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, hiExcPoint.Time);
            Assert.AreEqual(stage.MaxThreshold, result.First().MaxThreshold);
            Assert.AreEqual(stage.MinThreshold, result.First().MinThreshold);
        }

        [TestMethod]
        public async Task OneLowExcursionPointWithNullHighExcursionTest() {
            var baseDate = DateTime.Today;
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            stage.MaxThreshold = null;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MinThreshold! * 1.5));
            var hiExcPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate, (float)(stage.MinThreshold! * 0.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MinThreshold! * 1.5));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, hiExcPoint.Time);
            Assert.AreEqual(stage.MaxThreshold, result.First().MaxThreshold);
            Assert.AreEqual(stage.MinThreshold, result.First().MinThreshold);
        }

        [TestMethod]
        public async Task HighExcursionNoPointsPaceTest() {
            TestDbContext.IsPreservedForTest = true;
            var tagName = NewName();
            var baseDate = DateTime.Today;
            var stageDate = new StagesDate(tagName, baseDate);
            var stage = stageDate.Stage;
            stage.SetThresholds(100, 200);
            var pointsPaces = TestDbContext.PointsPaces.Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            TestDbContext.PointsPaces.RemoveRange(pointsPaces);
            TestDbContext.StagesDates.Add(stageDate);
            var rampInPoint = TestDbContext.NewCompressedPoint(tagName, baseDate.AddHours(-5), (float)(stage.MinThreshold! * 1.5));
            var hiExcPoint = TestDbContext.NewCompressedPoint(tagName, baseDate, (float)(stage.MinThreshold! * 0.5));
            var rampOutPoint = TestDbContext.NewCompressedPoint(tagName, baseDate.AddHours(5), (float)(stage.MinThreshold! * 1.5));
            await TestDbContext.SaveChangesAsync();
            
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(1), stageDate.StageDateId.ToString());
            var excPoint = TestDbContext.ExcursionPoints;
            //Assert.AreEqual(1, result.Count);
            //Assert.AreEqual(result.First().FirstExcDate, hiExcPoint.Time);
            //Assert.AreEqual(result.First().LastExcDate, hiExcPoint.Time);
            //Assert.AreEqual(stage.MaxThreshold, result.First().MaxThreshold);
            //Assert.AreEqual(stage.MinThreshold, result.First().MinThreshold);
        }
    }
}
