using Microsoft.EntityFrameworkCore;
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
                    "NO Tag", new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), 100, 200);
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        //EXECUTE[dbo].[spPivotExcursionPoints] 'T1', '2022-01-01', '2022-03-31', 100, 200;
        public async Task HiExcursionWithPrevTagExcNbrTest()
        {
            string tag = "T1";
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var prevDt = new DateTime(2022, 01, 01);
            var prevExcPoint = new ExcursionPointsNew() {
                TagId = 11, TagName = tag, TagExcNbr = 22,
                RampInDate = prevDt.AddDays(1), RampInValue = lt + 50, FirstExcDate = prevDt.AddDays(2),
                FirstExcValue = ht + 20, LastExcDate = prevDt.AddDays(3), RampOutDate = prevDt.AddDays(4),
                RampOutValue = lt + 50, HiPointsCt = 3, LowPointsCt = 0
            };
            TestDbContext.ExcursionPointsNews.Add(prevExcPoint);
            var rampInP1 = new CompressedPoint(tag,dt.AddDays(1), lt + 20);
            var rampInP2 = new CompressedPoint(tag, dt.AddDays(2), lt + 60);
            var excP1 = new CompressedPoint(tag, dt.AddDays(3), ht + 20);
            var excP2 = new CompressedPoint(tag, dt.AddDays(4), ht + 60);
            var excP3 = new CompressedPoint(tag, dt.AddDays(5), ht + 40);
            var rampOutP1 = new CompressedPoint(tag, dt.AddDays(6), ht - 10);
            var rampOutP2 = new CompressedPoint(tag, dt.AddDays(7), ht - 30);
            TestDbContext.Add(rampInP1); TestDbContext.Add(rampInP2);
            TestDbContext.Add(excP1); TestDbContext.Add(excP2); TestDbContext.Add(excP3);
            TestDbContext.Add(rampOutP1); TestDbContext.Add(rampOutP2);
            await TestDbContext.SaveChangesAsync();
            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.AreEqual(prevExcPoint.TagExcNbr + 1, excPointNew.TagExcNbr);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.HiPointsCt == 3);
            Assert.IsTrue(excPointNew.LowPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue >= ht);
            Assert.IsTrue(excPointNew.LastExcValue >= ht);
        }

        [TestMethod]
        public async Task LowExcursionTest() {
            var tag = "T2";
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var rampInP1 = new CompressedPoint(tag, dt.AddDays(1), lt + 60);
            var rampInP2 = new CompressedPoint(tag, dt.AddDays(2), lt + 20);
            var excP1 = new CompressedPoint(tag, dt.AddDays(3), lt - 20);
            var excP2 = new CompressedPoint(tag, dt.AddDays(4), lt - 30);
            var excP3 = new CompressedPoint(tag, dt.AddDays(5), lt - 10);
            var rampOutP1 = new CompressedPoint(tag, dt.AddDays(6), lt + 70);
            var rampOutP2 = new CompressedPoint(tag, dt.AddDays(7), lt + 90);
            TestDbContext.Add(rampInP1); TestDbContext.Add(rampInP2);
            TestDbContext.Add(excP1); TestDbContext.Add(excP2); TestDbContext.Add(excP3);
            TestDbContext.Add(rampOutP1); TestDbContext.Add(rampOutP2);
            await TestDbContext.SaveChangesAsync();
            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.AreEqual(0, excPointNew.TagExcNbr);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.LowPointsCt == 3);
            Assert.IsTrue(excPointNew.HiPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue < lt);
            Assert.IsTrue(excPointNew.LastExcValue < lt);
        }

        [TestMethod]
        public async Task HiLowExcursionTest() {
            var tag = "T3";
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var rampInPh1 = new CompressedPoint(tag, dt.AddDays(1), lt + 20);
            var rampInPh2 = new CompressedPoint(tag, dt.AddDays(2), lt + 60);
            var excPh1 = new CompressedPoint(tag, dt.AddDays(3), ht + 20);
            var excPh2 = new CompressedPoint(tag, dt.AddDays(4), ht + 60);
            var excPh3 = new CompressedPoint(tag, dt.AddDays(5), ht + 40);
            var rampOutPh1 = new CompressedPoint(tag, dt.AddDays(6), ht - 10);
            var rampOutPh2 = new CompressedPoint(tag, dt.AddDays(7), ht - 30);
            dt = dt.AddDays(10);
            var rampInPl1 = new CompressedPoint(tag, dt.AddDays(1), lt + 60);
            var rampInPl2 = new CompressedPoint(tag, dt.AddDays(2), lt + 20);
            var excPl1 = new CompressedPoint(tag, dt.AddDays(3), lt - 20);
            var excPl2 = new CompressedPoint(tag, dt.AddDays(4), lt - 30);
            var excPl3 = new CompressedPoint(tag, dt.AddDays(5), lt - 10);
            var rampOutPl1 = new CompressedPoint(tag, dt.AddDays(6), lt + 70);
            var rampOutPl2 = new CompressedPoint(tag, dt.AddDays(7), lt + 90); 
            TestDbContext.Add(rampInPh1); TestDbContext.Add(rampInPh2);
            TestDbContext.Add(excPh1); TestDbContext.Add(excPh2); TestDbContext.Add(excPh3);
            TestDbContext.Add(rampOutPh1); TestDbContext.Add(rampOutPh2);
            TestDbContext.Add(rampInPl1); TestDbContext.Add(rampInPl2);
            TestDbContext.Add(excPl1); TestDbContext.Add(excPl2); TestDbContext.Add(excPl3);
            TestDbContext.Add(rampOutPl1); TestDbContext.Add(rampOutPl2);
            await TestDbContext.SaveChangesAsync();
            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.HiPointsCt == 3);
            Assert.IsTrue(excPointNew.LowPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue >= ht);
            Assert.IsTrue(excPointNew.LastExcValue >= ht);
            excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht)).Skip(1).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.LowPointsCt == 3);
            Assert.IsTrue(excPointNew.HiPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue < lt);
            Assert.IsTrue(excPointNew.LastExcValue < lt);

        }
    }
}
