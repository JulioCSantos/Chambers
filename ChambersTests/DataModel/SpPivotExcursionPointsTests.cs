﻿using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class SpPivotExcursionPointsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(SpPivotExcursionPointsTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task EmptyTest() {
            var result = await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                    "NO Tag", new DateTime(2018, 01, 01), new DateTime(2018, 03, 31), 100, 200, null, null, 120, 150);
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        //EXECUTE[dbo].[spPivotExcursionPoints] 'T1', '2022-01-01', '2022-03-31', 100, 200;
        public async Task HiExcursionWithPrevTagExcNbrTest()
        {
            string tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var prevDt = new DateTime(2022, 01, 01);
            var prevExcPoint = new ExcursionPoint() {
                TagId = 11, TagName = tag, TagExcNbr = 22,
                RampInDate = prevDt.AddDays(1), RampInValue = lt + 50, FirstExcDate = prevDt.AddDays(2),
                FirstExcValue = ht + 20, LastExcDate = prevDt.AddDays(3), RampOutDate = prevDt.AddDays(4),
                RampOutValue = lt + 50, HiPointsCt = 3, LowPointsCt = 0
            };
            TestDbContext.ExcursionPoints.Add(prevExcPoint);
            var rampInP1 = new CompressedPoint(tag,dt.AddDays(1), lt + 20); TestDbContext.Add(rampInP1);
            var rampInP2 = new CompressedPoint(tag, dt.AddDays(2), lt + 60); TestDbContext.Add(rampInP2);
            var excP1 = new CompressedPoint(tag, dt.AddDays(3), ht + 20); TestDbContext.Add(excP1);
            var excP2 = new CompressedPoint(tag, dt.AddDays(4), ht + 60); TestDbContext.Add(excP2);
            var excP3 = new CompressedPoint(tag, dt.AddDays(5), ht + 40); TestDbContext.Add(excP3);
            var rampOutP1 = new CompressedPoint(tag, dt.AddDays(6), ht - 10); TestDbContext.Add(rampOutP1);
            var rampOutP2 = new CompressedPoint(tag, dt.AddDays(7), ht - 30); TestDbContext.Add(rampOutP2);
            await TestDbContext.SaveChangesAsync();
            TestDbContext.Interpolateds.AddRange(TestDbContext.CompressedPoints.ToInterpolatedPoints());
            await TestDbContext.SaveChangesAsync();

            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht, null, null, 120, 150)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.AreEqual(prevExcPoint.TagExcNbr + 1, excPointNew.TagExcNbr);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.HiPointsCt == 3);
            Assert.IsTrue(excPointNew.LowPointsCt == 0);
            Assert.IsTrue(excPointNew.ThresholdDuration == 120);
            Assert.IsTrue(excPointNew.SetPoint == 150);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue >= ht);
            Assert.IsTrue(excPointNew.LastExcValue >= ht);
            var excPoints = new[] { excP1.Value, excP2.Value, excP3.Value };
            Assert.AreEqual(excPoints.Min(), excPointNew.MinValue);
            Assert.AreEqual(excPoints.Max(), excPointNew.MaxValue);
            Assert.AreEqual(excPoints.Average(), excPointNew.AvergValue);
            Assert.AreEqual(excPoints.StandardDeviationSample(), excPointNew.StdDevValue);
        }

        [TestMethod]
        public async Task LowExcursionTest() {
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var rampInP1 = new CompressedPoint(tag, dt.AddDays(1), lt + 60); TestDbContext.Add(rampInP1);
            var rampInP2 = new CompressedPoint(tag, dt.AddDays(2), lt + 20); TestDbContext.Add(rampInP2);
            var excP1 = new CompressedPoint(tag, dt.AddDays(3), lt - 20); TestDbContext.Add(excP1);
            var excP2 = new CompressedPoint(tag, dt.AddDays(4), lt - 30); TestDbContext.Add(excP2);
            var excP3 = new CompressedPoint(tag, dt.AddDays(5), lt - 10); TestDbContext.Add(excP3);
            var rampOutP1 = new CompressedPoint(tag, dt.AddDays(6), lt + 70); TestDbContext.Add(rampOutP1);
            var rampOutP2 = new CompressedPoint(tag, dt.AddDays(7), lt + 90); TestDbContext.Add(rampOutP2);
            //TestDbContext.Add(rampInP1); TestDbContext.Add(rampInP2);
            //TestDbContext.Add(excP1); TestDbContext.Add(excP2); TestDbContext.Add(excP3);
            //TestDbContext.Add(rampOutP1); TestDbContext.Add(rampOutP2);
            await TestDbContext.SaveChangesAsync();
            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht, null, null, 120, 150)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.AreEqual(1, excPointNew.TagExcNbr);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.LowPointsCt == 3);
            Assert.IsTrue(excPointNew.HiPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue < lt);
            Assert.IsTrue(excPointNew.LastExcValue < lt);
        }

        [TestMethod]
        public async Task HiLowExcursionTest()
        {
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var rampInPh1 = new CompressedPoint(tag, dt.AddDays(1), lt + 20); TestDbContext.Add(rampInPh1);
            var rampInPh2 = new CompressedPoint(tag, dt.AddDays(2), lt + 60); TestDbContext.Add(rampInPh2);
            var excPh1 = new CompressedPoint(tag, dt.AddDays(3), ht + 20); TestDbContext.Add(excPh1);
            var excPh2 = new CompressedPoint(tag, dt.AddDays(4), ht + 60); TestDbContext.Add(excPh2);
            var excPh3 = new CompressedPoint(tag, dt.AddDays(5), ht + 40); TestDbContext.Add(excPh3);
            var rampOutPh1 = new CompressedPoint(tag, dt.AddDays(6), ht - 10); TestDbContext.Add(rampOutPh1);
            var rampOutPh2 = new CompressedPoint(tag, dt.AddDays(7), ht - 30); TestDbContext.Add(rampOutPh2);
            dt = dt.AddDays(10);
            var rampInPl1 = new CompressedPoint(tag, dt.AddDays(1), lt + 60); TestDbContext.Add(rampInPl1);
            var rampInPl2 = new CompressedPoint(tag, dt.AddDays(2), lt + 20); TestDbContext.Add(rampInPl2);
            var excPl1 = new CompressedPoint(tag, dt.AddDays(3), lt - 20); TestDbContext.Add(excPl1);
            var excPl2 = new CompressedPoint(tag, dt.AddDays(4), lt - 30); TestDbContext.Add(excPl2);
            var excPl3 = new CompressedPoint(tag, dt.AddDays(5), lt - 10); TestDbContext.Add(excPl3);
            var rampOutPl1 = new CompressedPoint(tag, dt.AddDays(6), lt + 70); TestDbContext.Add(rampOutPl1);
            var rampOutPl2 = new CompressedPoint(tag, dt.AddDays(7), lt + 90); TestDbContext.Add(rampOutPl2);
            await TestDbContext.SaveChangesAsync();

            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht, null, null, 120, 150)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.HiPointsCt == 3);
            Assert.IsTrue(excPointNew.LowPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue >= ht);
            Assert.IsTrue(excPointNew.LastExcValue >= ht);
            Assert.IsTrue(excPointNew.ThresholdDuration == 120);
            Assert.IsTrue(excPointNew.SetPoint == 150);
            excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht, null, null, 120, 150)).Skip(1).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.LowPointsCt == 3);
            Assert.IsTrue(excPointNew.HiPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue < lt);
            Assert.IsTrue(excPointNew.LastExcValue < lt);
            Assert.IsTrue(excPointNew.ThresholdDuration == 120);
            Assert.IsTrue(excPointNew.SetPoint == 150);

        }
    }
}
