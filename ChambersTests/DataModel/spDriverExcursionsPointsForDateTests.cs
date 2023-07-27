using System;
using System.Collections.Generic;
using System.Linq;
using System.Resources;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Xml.XPath;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.TestTools.UnitTesting;

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
        public async Task OneHighExcursionPointTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate, 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            baseDate = baseDate.AddDays(1);
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
            Assert.AreEqual(1, result.First().HiPointsCt);
            Assert.AreEqual(0, result.First().LowPointsCt);
            Assert.AreEqual(hiExcPoint.Value, result.First().MaxValue);
            Assert.AreEqual(hiExcPoint.Value, result.First().MinValue);
            Assert.AreEqual(hiExcPoint.Value, result.First().AvergValue);
        }

        [TestMethod]
        public async Task PointsPacesUpdateWithOneHighExcursionPointTest() {
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
            Assert.AreEqual(1, result.First().HiPointsCt);
            Assert.AreEqual(0, result.First().LowPointsCt);
            Assert.AreEqual(hiExcPoint.Value, result.First().MaxValue);
            Assert.AreEqual(hiExcPoint.Value, result.First().MinValue);
            Assert.AreEqual(hiExcPoint.Value, result.First().AvergValue);
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
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(1), (float)(stage.MaxThreshold! * 0.9));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(2), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(3), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            var prevPointsPaces = TestDbContext.PointsPaces.AsNoTracking()
                .Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            Assert.AreEqual(0, prevPointsPaces.Count);;
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(3), stageDate.StageDateId.ToString());
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(result.First().RampInDate, rampInPoint.Time);
            Assert.AreEqual(result.First().FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(result.First().LastExcDate, hiExcPoint.Time);
            Assert.AreEqual(result.First().RampOutDate, rampOutPoint.Time);
            var currPointsPaces = TestDbContext.PointsPaces.AsNoTracking()
                .Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            Assert.AreEqual(5, currPointsPaces.Count);
            Assert.AreEqual(1, currPointsPaces.Count(pp => pp.ProcessedDate == null));
            Assert.IsNotNull(result.First().StageDateId);
            Assert.IsNotNull(result.First().TagId);
            Assert.AreEqual(1, result.First().HiPointsCt);
            Assert.AreEqual(0, result.First().LowPointsCt);
            Assert.AreEqual(hiExcPoint.Value, result.First().MaxValue);
            Assert.AreEqual(hiExcPoint.Value, result.First().MinValue);
            Assert.AreEqual(hiExcPoint.Value, result.First().AvergValue);
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
        public async Task TwoLowExcursionPointsWithRampsTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 3);
            TestDbContext.PointsPaces.Add(pointsPace);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddMinutes(1), (float)(stage.MinThreshold! * 1.1));
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
            Assert.AreEqual(0, result.First().HiPointsCt);
            Assert.AreEqual(2, result.First().LowPointsCt);
            Assert.AreEqual(firstLowExcPoint.Value, result.First().MaxValue);
            Assert.AreEqual(lastLowExcPoint.Value, result.First().MinValue);
            Assert.AreEqual((firstLowExcPoint.Value + lastLowExcPoint.Value)/2, result.First().AvergValue);
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
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 1);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            // excursion 1
            var baseDate1 = baseDate.AddDays(1);
            var rampInPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(2), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(3), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            // excursion 2
            var baseDate2 = baseDate.AddDays(2);
            var rampInPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(2), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(3), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(4), pointsPace.StageDateId.ToString());
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
            var rampInPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(2), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate1.AddHours(3), (float)(stage.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            // excursion 2
            var rampInPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(1), (float)(stage.MaxThreshold! * 0.9));
            var highExcursionPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(2), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate2.AddHours(3), (float)(stage.MaxThreshold! * 0.8));
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
        public async Task HighExcursionNoPointsPaceTest()
        {
            var tagName = NewName();
            var baseDate = DateTime.Today.AddDays(-30);
            var stageDate = new StagesDate(tagName, baseDate);
            var stage = stageDate.Stage;
            stage.SetThresholds(100, 200);
            var pointsPaces = TestDbContext.PointsPaces.Where(pp => pp.StageDateId == stageDate.StageDateId).ToList();
            TestDbContext.PointsPaces.RemoveRange(pointsPaces);
            TestDbContext.StagesDates.Add(stageDate);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddHours(-5), (float)(stage.MinThreshold! * 1.5));
            var hiExcPoint1 = TestDbContext.NewInterpolatedPoint(tagName, baseDate, (float)(stage.MinThreshold! * 0.5));
            var hiExcPoint2 = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddHours(1), (float)(stage.MinThreshold! * 0.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddHours(5), (float)(stage.MinThreshold! * 1.5));
            await TestDbContext.SaveChangesAsync();
            
            var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(-1), baseDate.AddDays(2), stageDate.StageDateId.ToString());
            var excPoint = TestDbContext.ExcursionPoints;
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(2, result.First().LowPointsCt);
            Assert.AreEqual(result.First().FirstExcDate, hiExcPoint1.Time);
            Assert.AreEqual(result.First().LastExcDate, hiExcPoint2.Time);
            Assert.AreEqual(stage.MaxThreshold, result.First().MaxThreshold);
            Assert.AreEqual(stage.MinThreshold, result.First().MinThreshold);
        }

        [TestMethod]
        public async Task OneHighExcursionThresholdDurationSetPointTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(-1), 1);
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
                baseDate.AddDays(-1), baseDate.AddDays(3), pointsPace.StageDateId.ToString());
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.TagId == driverResult.First().TagId && ex.TagExcNbr == driverResult.First().TagExcNbr)).First();
            Assert.AreEqual(1, driverResult.Count);
            Assert.AreEqual(excursion.FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(excursion.LastExcDate, hiExcPoint.Time);
            Assert.AreEqual(excursion.ThresholdDuration, driverResult.First().ThresholdDuration);
            Assert.AreEqual(excursion.SetPoint, driverResult.First().SetPoint);
        }

        [TestMethod]
        public async Task OneHighExcursionDeprecatedDateTest() {
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
                pointsPace.NextStepStartDate, stage.DeprecatedDate.Value.AddDays(1), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, driverResult.Count);
            Assert.IsNotNull(driverResult.First().DeprecatedDate);
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.StageDateId == driverResult.First().StageDateId)).FirstOrDefault();
            Assert.IsNotNull(excursion);
            Assert.IsNotNull(excursion.DeprecatedDate);
            Assert.AreEqual(excursion.DeprecatedDate, stage.DeprecatedDate);
        }

        [TestMethod]
        public async Task DeprecatedStageTest()
        {
            var baseDate = DateTime.Today.AddDays(-30);
            var tagName = NewName();
            var stageDate1 = new StagesDate(tagName, baseDate);
            var stage1 = stageDate1.Stage; stage1.SetThresholds(100,200);
            stage1.SetPoint = 150; stage1.ThresholdDuration = 60;
            stage1.ProductionDate = baseDate;
            stage1.DeprecatedDate = baseDate.AddDays(5);
            TestDbContext.Add(stageDate1);
            var stageDate2 = new StagesDate(tagName, baseDate.AddDays(5));
            var stage2 = stageDate2.Stage; stage2.SetThresholds(130, 230);
            stage2.ProductionDate = baseDate.AddDays(5);
            TestDbContext.Add(stageDate2);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate, (float)(stage1.MaxThreshold! * 0.8));
            for (int ix = 0; ix < 10; ix++) {
                TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddDays(ix).AddHours(1), (float)(stage1.MaxThreshold! * 1.5));
            }
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tagName, baseDate.AddDays(9).AddHours(2), (float)(stage1.MaxThreshold! * 0.8));
            await TestDbContext.SaveChangesAsync();
            
            var driverResult1 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(10), stageDate1.StageDateId.ToString());
            Assert.AreEqual(1, driverResult1.Count);
            var driverResul2 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(9), baseDate.AddDays(20), stageDate2.StageDateId.ToString());
            
            Assert.AreEqual(1, driverResul2.Count);
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
            Assert.AreEqual(99, excursions.Sum(e => e.HiPointsCt));
        }

        [TestMethod]
        public async Task SubsequentExcursionPointTest() {
            var baseDate = DateTime.Today.AddDays(-30);
            var e1Dt = baseDate.AddDays(1);
            var e2Dt = baseDate.AddDays(2);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), e1Dt, 1);
            TestDbContext.PointsPaces.Add(pointsPace);
            await TestDbContext.SaveChangesAsync();
            var stageDate = pointsPace.StageDate;
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            var prevExc = new ExcursionPoint() {
                TagId = tag.TagId, TagName = tag.TagName, StageDateId = stageDate.StageDateId , TagExcNbr = 1
                , RampInDate = e1Dt.AddHours(1), RampInValue = 150, FirstExcDate = e1Dt.AddHours(2), FirstExcValue = 210
                , LastExcDate = e1Dt.AddHours(3), LastExcValue = 230, RampOutDate = e1Dt.AddHours(4), RampOutValue = 180
                , HiPointsCt = 10
            };
            TestDbContext.Add(prevExc);

            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, e2Dt.AddHours(1), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, e2Dt.AddHours(2), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, e2Dt.AddHours(3), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();

            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                e2Dt, e2Dt.AddDays(2), pointsPace.StageDateId.ToString());
            
            Assert.AreEqual(1, driverResult.Count);
            var excs = TestDbContext.ExcursionPoints.Where(ep => ep.StageDateId == stageDate.StageDateId);
            Assert.AreEqual(2, excs.Count());
            var exc = excs.OrderByDescending(e => e.CycleId).First();
            Assert.AreEqual(prevExc.TagExcNbr + 1, exc.TagExcNbr);
            Assert.AreEqual(exc.FirstExcDate, hiExcPoint.Time);
            Assert.AreEqual(exc.LastExcDate, hiExcPoint.Time);
        }
        [TestMethod]
        public async Task LengthyExcursionNoRampsTest() {
            var baseDate = new DateTime(2023, 01, 01);
            var stageDate = new StagesDate(NewName(), baseDate);
            var stage = stageDate.Stage; stage.SetThresholds(100,200);
            var tag = stage.Tag;
            TestDbContext.Add(stageDate);
            await TestDbContext.SaveChangesAsync();
            var stageDateId = stageDate.StageDateId;

            for (int ix = 0; ix < 10; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddDays(ix), (float)(stage.MaxThreshold! * 1.30d));
            }
            await TestDbContext.SaveChangesAsync();

            var driverResult1 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(5), stageDateId.ToString());
            var driverResult2 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate.AddDays(4), baseDate.AddDays(11), stageDateId.ToString());
            var excs = TestDbContext.ExcursionPoints.Where(ep => ep.StageDateId == stageDateId);

            Assert.IsNotNull(excs);
            Assert.AreEqual(1,excs.Count());
        }

        [TestMethod]
        public async Task MidnightExcursionTest() {
            var baseDate = new DateTime(2023, 01, 01,23,59,30);
            var stageDate = new StagesDate(NewName(), baseDate);
            var stage = stageDate.Stage; stage.SetThresholds(100, 200);
            var tag = stage.Tag;
            TestDbContext.Add(stageDate);
            await TestDbContext.SaveChangesAsync();

            for (float ix = 0; ix < 60; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddSeconds(ix), (float)(stage.MaxThreshold! * 1.30d) + ix/10);
            }
            await TestDbContext.SaveChangesAsync();

            var driverResult1 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(4), stageDate.StageDateId.ToString());
            //var excs = TestDbContext.ExcursionPoints.Where(ep => ep.StageDateId == stageDate.StageDateId);
            var excs = TestDbContext.ExcursionPoints.Where(e => e.StageDateId == stageDate.StageDateId);

            Assert.IsNotNull(excs);
            Assert.AreEqual(1, excs.Count());
        }


        [TestMethod]
        public async Task MergeTest() {
            var baseDate = new DateTime(2023, 01, 01, 23, 59, 57);
            var stageDate = new StagesDate(NewName(), baseDate);
            var stage = stageDate.Stage; stage.SetThresholds(100, 200);
            var tag = stage.Tag;
            TestDbContext.Add(stageDate);
            await TestDbContext.SaveChangesAsync();


            TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddSeconds(-1), (float)(stage.MaxThreshold! * 0.8d));
            for (float ix = 0; ix < 5; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddSeconds(ix), (float)(stage.MaxThreshold! * 1.30d) + ix / 10);
            }
            TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddSeconds(7), (float)(stage.MaxThreshold! * 0.7d));

            for (float ix = 0; ix < 5; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddDays(1).AddSeconds(ix), (float)(stage.MaxThreshold! * 1.30d) + ix / 10);
            }

            for (float ix = 0; ix < 5; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddDays(2).AddSeconds(ix), (float)(stage.MaxThreshold! * 1.30d) + ix / 10);
            }
            await TestDbContext.SaveChangesAsync();

            var driverResult1 = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(6), stageDate.StageDateId.ToString());
            var excs = TestDbContext.ExcursionPoints.Where(ep => ep.StageDateId == stageDate.StageDateId);

            Assert.IsNotNull(excs);
            Assert.AreEqual(2, excs.Count());
            var earliestTime = TestDbContext.Interpolateds
                .Where(i => i.Tag == tag.TagName && i.Value >= stage.MaxThreshold!).Min(ex => ex.Time);
            var latestTime = TestDbContext.Interpolateds
                .Where(i => i.Tag == tag.TagName && i.Value >= stage.MaxThreshold!).Max(ex => ex.Time);
            Assert.AreEqual(earliestTime,excs.First().FirstExcDate);
            Assert.AreEqual(latestTime, excs.Skip(1).First().LastExcDate);
            Assert.IsNull(excs.First().RampInDate);
            Assert.IsNotNull(excs.First().RampOutDate);
            Assert.IsNull(excs.Skip(1).First().RampInDate);
            Assert.IsNull(excs.Skip(1).First().RampOutDate);
        }
        [TestMethod]
        public async Task MergeDaysAPartTest() {
            var baseDate = new DateTime(2023, 01, 01, 22, 00, 00);
            var stageDate = new StagesDate(NewName(), baseDate);
            var stage = stageDate.Stage; stage.SetThresholds(100, 200);
            var tag = stage.Tag;
            TestDbContext.Add(stageDate);
            await TestDbContext.SaveChangesAsync();


            for (float ix = 0; ix < 5; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(ix), (float)(stage.MaxThreshold! * 1.30d) + ix / 10);
            }

            for (float ix = 0; ix < 5; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddDays(1).AddHours(ix), (float)(stage.MaxThreshold! * 1.30d) + ix / 10);
            }

            for (float ix = 0; ix < 5; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddDays(2).AddHours(ix), (float)(stage.MaxThreshold! * 0.5) + ix / 10);
            }

            for (float ix = -1; ix < 4; ix++) {
                TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddDays(3).AddHours(ix), (float)(stage.MaxThreshold! * 1.30d) + ix / 10);
            }
            await TestDbContext.SaveChangesAsync();

            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                baseDate, baseDate.AddDays(5), stageDate.StageDateId.ToString());
            Assert.IsNotNull(driverResult);
            Assert.AreEqual(2,driverResult.Count);
            var excs = TestDbContext.ExcursionPoints.Where(ep => ep.StageDateId == stageDate.StageDateId);

            Assert.IsNotNull(excs);
            Assert.AreEqual(2, excs.Count());
            var earliestTime = TestDbContext.Interpolateds
                .Where(i => i.Tag == tag.TagName && i.Value >= stage.MaxThreshold!).Min(ex => ex.Time);
            var latestTime = TestDbContext.Interpolateds
                .Where(i => i.Tag == tag.TagName && i.Value >= stage.MaxThreshold!).Max(ex => ex.Time);
            Assert.AreEqual(earliestTime, excs.First().FirstExcDate);
            Assert.AreEqual(latestTime, excs.Skip(1).First().LastExcDate);
            Assert.IsNull(excs.First().RampInDate);
            Assert.IsNotNull(excs.First().RampOutDate);
            Assert.IsNotNull(excs.Skip(1).First().RampInDate);
            Assert.IsNull(excs.Skip(1).First().RampOutDate);
        }

        [TestMethod]
        public async Task OneHighExcursionDecommissionTest() {
            var baseDate = DateTime.Today.AddDays(-5);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate.AddDays(1), 3);
            var stage = pointsPace.StageDate.Stage;
            var tag = stage.Tag;
            tag.DecommissionedDate = baseDate.AddDays(2);
            TestDbContext.PointsPaces.Add(pointsPace);
            var excDate = tag.DecommissionedDate.Value;
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, excDate.AddHours(-20), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, excDate.AddHours(-15), (float)(stage.MaxThreshold! * 1.5));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, excDate.AddHours(-10), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                pointsPace.NextStepStartDate, tag.DecommissionedDate.Value.AddDays(3), pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, driverResult.Count);
            Assert.IsNotNull(driverResult.First().DecommissionedDate);
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.StageDateId == driverResult.First().StageDateId)).FirstOrDefault();
            Assert.IsNotNull(excursion);
            Assert.IsNotNull(excursion.DecommissionedDate);
            Assert.AreEqual(excursion.DecommissionedDate, tag.DecommissionedDate);
            var pointsStepsLog = (TestDbContext.PointsStepsLogs
                .Where(ex => ex.StageDateId == driverResult.First().StageDateId)).FirstOrDefault();
            Assert.IsNotNull(pointsStepsLog);
            Assert.IsNotNull(pointsStepsLog.DecommissionedDate);
            Assert.AreEqual(pointsStepsLog.DecommissionedDate, tag.DecommissionedDate);
        }

        [TestMethod]
        public async Task ProcessWithDeprecatedDateTest() {
            TestDbContext.IsPreservedForTest = true;
            var baseDate = DateTime.Today.AddDays(-10);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate, 3);
            var stage = pointsPace.StageDate.Stage;
            stage.ThresholdDuration = 0;
            stage.DeprecatedDate = baseDate.AddHours(12);
            var tag = stage.Tag;
            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(10), (float)(stage.MaxThreshold! * 1.5));
            var hiExcPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(11), (float)(stage.MaxThreshold! * 1.6));
            var hiExcPoint3 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(16), (float)(stage.MaxThreshold! * 1.6));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(20), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var startDate = pointsPace.NextStepStartDate;
            var stopDate = stage.DeprecatedDate.Value.AddDays(4);
            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                startDate, stopDate, pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, driverResult.Count);
            Assert.IsNotNull(driverResult.First().DeprecatedDate);
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.StageDateId == driverResult.First().StageDateId)).FirstOrDefault();
            Assert.IsNotNull(excursion);
            Assert.IsNotNull(excursion.DeprecatedDate);
            Assert.AreEqual(excursion.DeprecatedDate, stage.DeprecatedDate);
            Assert.AreEqual(excursion.RampInDate, rampInPoint.Time);
            Assert.AreEqual(excursion.FirstExcDate, hiExcPoint1.Time);
            Assert.AreEqual(excursion.FirstExcValue, hiExcPoint1.Value);
            Assert.AreEqual(excursion.LastExcDate, hiExcPoint2.Time);
            Assert.AreEqual(excursion.LastExcValue, hiExcPoint2.Value);

            Assert.IsNull(excursion.RampOutDate);
        }
        [TestMethod]
        public async Task ProcessWithDecommissionedDateTest() {
            TestDbContext.IsPreservedForTest = true;
            var baseDate = DateTime.Today.AddDays(-10);
            var pointsPace = TestDbContext.NewPointsPace(NewName(), baseDate, 3);
            var stage = pointsPace.StageDate.Stage;
            stage.ThresholdDuration = 0;
            var tag = stage.Tag;
            tag.DecommissionedDate = baseDate.AddHours(12);

            TestDbContext.PointsPaces.Add(pointsPace);
            var rampInPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(5), (float)(stage.MaxThreshold! * 0.8));
            var hiExcPoint1 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(10), (float)(stage.MaxThreshold! * 1.5));
            var hiExcPoint2 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(11), (float)(stage.MaxThreshold! * 1.6));
            var hiExcPoint3 = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(16), (float)(stage.MaxThreshold! * 1.6));
            var rampOutPoint = TestDbContext.NewInterpolatedPoint(tag.TagName, baseDate.AddHours(20), (float)(stage.MaxThreshold! * 0.5));
            await TestDbContext.SaveChangesAsync();
            //var effectiveStages = await TestDbContext.GetStagesLimitsAndDates(tag.TagId, baseDate);
            var startDate = pointsPace.NextStepStartDate;
            var stopDate = tag.DecommissionedDate.Value.AddDays(4);
            var driverResult = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
                startDate, stopDate, pointsPace.StageDateId.ToString());
            Assert.AreEqual(1, driverResult.Count);
            Assert.IsNotNull(driverResult.First().DecommissionedDate);
            var excursion = (TestDbContext.ExcursionPoints
                .Where(ex => ex.StageDateId == driverResult.First().StageDateId)).FirstOrDefault();
            Assert.IsNotNull(excursion);
            Assert.IsNotNull(excursion.DecommissionedDate);
            Assert.AreEqual(excursion.DecommissionedDate, tag.DecommissionedDate);
            Assert.AreEqual(excursion.RampInDate, rampInPoint.Time);
            Assert.AreEqual(excursion.FirstExcDate, hiExcPoint1.Time);
            Assert.AreEqual(excursion.FirstExcValue, hiExcPoint1.Value);
            Assert.AreEqual(excursion.LastExcDate, hiExcPoint2.Time);
            Assert.AreEqual(excursion.LastExcValue, hiExcPoint2.Value);

            Assert.IsNull(excursion.RampOutDate);
        }

    }
}
