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
           var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                new DateTime(2222, 1, 22), new DateTime(2222, 1, 23),"-1");
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task OneHighExcursionPointTest()
        {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
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
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
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
            var tagName = NewName();
            var baseDate = DateTime.Today.AddDays(-30);
            var stageDate = new StagesDate(tagName, baseDate.AddHours(6));
            var stage = stageDate.Stage;
            stage.SetThresholds(100,300);
            var tag = stage.Tag;
            TestDbContext.StagesDates.Add(stageDate);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
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
            Assert.IsNotNull(result.First().StageDateId);
            Assert.IsNotNull(result.First().TagId);
        }

        [TestMethod]
        public async Task OneHighExcursionPointWithInitialPointsPaceTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
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
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-1), (float)(stage.MinThreshold! * 1.1));
            var firstLowExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddMinutes(10), (float)(stage.MinThreshold! * 0.9));
            var lastLowExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddMinutes(20), (float)(stage.MinThreshold! * 0.8));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(+1), (float)(stage.MinThreshold! * 1.2));
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
            var highExcursionPoint = TestDbContext.NewInterpolatedPoint(tag.TagName
                , pointsPace.NextStepStartDate.AddDays(-1), (float)(stage.MaxThreshold! * 1.5));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(1),pointsPace.StageDateId.ToString());
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task TwoConsecutiveExcursionsTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            // excursion 1
            var baseDate1 = baseDate;
            var rampInPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            // excursion 2
            var baseDate2 = baseDate.AddDays(1);
            var rampInPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
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
            var baseDate = DateTime.Today.AddDays(-30);
            var stepDays = 2;
            var baseDate1 = baseDate;
            var baseDate2 = baseDate.AddDays(stepDays);

            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate, stepDays);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            // excursion 1
            var rampInPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            // excursion 2
            var rampInPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(-1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(+1), (float)(stage.MaxThreshold! * 0.8));
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
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            stage.MinThreshold = null;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
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
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            stage.MaxThreshold = null;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MinThreshold! * 1.5));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MinThreshold! * 0.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MinThreshold! * 1.5));
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
            var tagName = NewName();
            var baseDate = DateTime.Today.AddDays(-30);
            var stageDate = new StagesDate(tagName, baseDate);
            var stage = stageDate.Stage;
            stage.SetThresholds(100, 200);
            var pointsPaces = TestDbContext.PointsPaces.Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            TestDbContext.PointsPaces.RemoveRange(pointsPaces);
            TestDbContext.StagesDates.Add(stageDate);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddHours(-5), (float)(stage.MinThreshold! * 1.5));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate, (float)(stage.MinThreshold! * 0.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddHours(5), (float)(stage.MinThreshold! * 1.5));
            await TestDbContext.SaveChangesAsync();
            
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(2), stageDate.StageDateId.ToString());
            var excPoint = TestDbContext.ExcursionPoints;
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, hiExcPoint.Time);
            Assert.AreEqual(stage.MaxThreshold, result.First().MaxThreshold);
            Assert.AreEqual(stage.MinThreshold, result.First().MinThreshold);
        }

        [TestMethod]
        public async Task OneHighExcursionThresholdDurationSetPointTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            stage.ThresholdDuration = 6; //six seconds to be considered an excursion. SSRS only.
            stage.SetPoint = 155; // fridge set point. SSRS only.
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.CycleId == driverResult.First().CycleId)).First();
            Assert.AreEqual(1, driverResult.Count);
            Assert.AreEqual(excursion.FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(excursion.LastExcDate, hiExcPoint.Time);
            Assert.AreEqual(excursion.ThresholdDuration, driverResult.First().ThresholdDuration);
            Assert.AreEqual(excursion.SetPoint, driverResult.First().SetPoint);
        }

        [TestMethod]
        public async Task OneHighExcursionDeprecatedDateTest()
        {
            var baseDate = DateTime.Today.AddDays(-10);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            var stage = pointsPace.StageDate.Stage;
            stage.DeprecatedDate = baseDate.AddDays(7); 
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(-5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate, (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, driverResult.Count);
            Assert.IsNotNull(driverResult.First().DeprecatedDate);
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.CycleId == driverResult.First().CycleId)).First();
            Assert.IsNotNull(excursion.DeprecatedDate);
            Assert.AreEqual(excursion.DeprecatedDate, stage.DeprecatedDate);
        }

        [TestMethod]
        public async Task DeprecatedStageTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var tagName = NewName();
            var stageDate1 = new StagesDate(tagName, baseDate);
            var stage1 = stageDate1.Stage; stage1.SetThresholds(100,200);
            stage1.ProductionDate = baseDate;
            stage1.DeprecatedDate = baseDate.AddDays(5);
            TestDbContext.Add(stageDate1);
            var stageDate2 = new StagesDate(tagName, baseDate.AddDays(5));
            var stage2 = stageDate2.Stage; stage2.SetThresholds(130, 230);
            stage2.ProductionDate = baseDate.AddDays(5);
            TestDbContext.Add(stageDate2);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate, (float)(stage1.MaxThreshold! * 0.8));
            for (int ix = 1; ix < 10; ix++) {
                TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddDays(ix), (float)(stage1.MaxThreshold! * 1.5));
            }
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddDays(11), (float)(stage1.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            
            var driverResult1 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(10), stageDate1.StageDateId.ToString());
            var numberOfSteps1 = ((DateTime)stage1.DeprecatedDate).Subtract((DateTime)stage1.ProductionDate).Days - 2; 
            Assert.AreEqual(numberOfSteps1, driverResult1.Count);
            var driverResul2 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(10), stageDate2.StageDateId.ToString());
            var numberOfSteps2 = (rampOutPoint.Time).Subtract((DateTime)stage2.ProductionDate).Days - 2;
            
            Assert.AreEqual(numberOfSteps2, driverResul2.Count);
            var excs = TestDbContext.ExcursionPoints
                .Where(ex => ex.TagName == tagName);
            Assert.AreEqual(2, excs.ToList().Count);
            var exc1 = excs.FirstOrDefault(ex => ex.StageDateId == stageDate1.StageDateId);
            var exc2 = excs.FirstOrDefault(ex => ex.StageDateId == stageDate2.StageDateId);
            Assert.IsNotNull(exc1);
            Assert.IsNotNull(exc2);
            Assert.AreEqual(rampInPoint.Time, exc1.RampInDate);
            Assert.AreEqual(stage1.DeprecatedDate, exc1.DeprecatedDate);
            Assert.IsNull(exc1.RampOutDate);
            Assert.IsNull(exc2.RampInDate);
        }
        [TestMethod]
        public async Task OneLengthyExcursionWithoutRampsTest() {
            var baseDate = DateTime.Today.AddDays(-200);
            var stageDate = new StagesDate(NewName(), baseDate.AddDays(-1));
            var stage = stageDate.Stage;
            var tag = stage.Tag;
            stage.SetThresholds(100,200);
            TestDbContext.Add(stageDate);
            for (int ix = 1; ix < 100; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(ix), (float)stage.MaxThreshold! * (1 + ix/100));
            }
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(6), stageDate.StageDateId.ToString());
            var excursions = TestDbContext.ExcursionPoints.Where(x => x.StageDateId == stageDate.StageDateId).ToList();
            Assert.AreEqual(1, excursions.Count);
            Assert.AreEqual(99, excursions.First().HiPointsCt);
        }
    }
}
