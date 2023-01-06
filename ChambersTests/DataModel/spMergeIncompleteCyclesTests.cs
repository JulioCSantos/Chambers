using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class spMergeIncompleteCyclesTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(spMergeIncompleteCyclesTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task EmptyTest1() {
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task EmptyTest2()
        {
            var excPoints = TestDbContext.NewExcursionPoint(nameof(EmptyTest2), 1, 0, 0);
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task EmptyTest3() {
            var excPoints = TestDbContext.NewExcursionPoint(nameof(EmptyTest3), 1, 0, 0
                , new DateTime(2022,1,1), 110, null, null);
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task CycleTest1()
        {
            var rampInDt = new DateTime(2022, 1, 1);
            var rampOutDt = rampInDt.AddDays(1);
            var riExcPoints = TestDbContext.NewExcursionPoint(nameof(CycleTest1), 1, 1, 0
                , rampInDt, 110, null, null);
            var roExcPoints = TestDbContext.NewExcursionPoint(nameof(CycleTest1), 2, 2, 0
                , null, null, rampOutDt, 120);
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            var mergedExc = result.First();
            Assert.AreEqual(1, result.Count);
            Assert.AreEqual(riExcPoints.HiPointsCt + roExcPoints.HiPointsCt, mergedExc.HiPointsCt);
        }

        [TestMethod]
        public async Task CycleTest2() {
            var rampInDt = new DateTime(2022, 1, 1);
            var rampOutDt = rampInDt.AddDays(2);
            var riExcPoints = TestDbContext.NewExcursionPoint(nameof(CycleTest2), 2, 1, 0
                , rampInDt, 110, null, null);
            var midExcPoints = TestDbContext.NewExcursionPoint(nameof(CycleTest2), 3, 3, 0
                , null, null, null, null);
            var roExcPoints = TestDbContext.NewExcursionPoint(nameof(CycleTest2), 4, 5, 0
                , null, null, rampOutDt, 120);
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            var mergedExc = result.First();
            Assert.AreEqual(1, result.Count);
            var expected = riExcPoints.HiPointsCt + midExcPoints.HiPointsCt + roExcPoints.HiPointsCt;
            Assert.AreEqual(expected, mergedExc.HiPointsCt);
        }

        [TestMethod]
        public async Task TwoCyclesTest1() {
            var dt1 = new DateTime(2022, 1, 1);
            var dt2 = dt1.AddDays(2);
            var dt3 = dt1.AddDays(3);
            var dt4 = dt1.AddDays(4);
            var dt5 = dt1.AddDays(5);
            var exc1 = TestDbContext.NewExcursionPoint(nameof(TwoCyclesTest1), 3, 11, 0
                , dt1, 110, null, null);
            var exc2 = TestDbContext.NewExcursionPoint(nameof(TwoCyclesTest1), 5, 22, 0
                , null, null, dt2, 120);
            var exc3 = TestDbContext.NewExcursionPoint(nameof(TwoCyclesTest1), 20, 1, 0
                , dt3, 110, null, null);
            var exc4 = TestDbContext.NewExcursionPoint(nameof(TwoCyclesTest1), 22, 3, 0
                , null, null, null, null);
            var exc5 = TestDbContext.NewExcursionPoint(nameof(TwoCyclesTest1), 24, 5, 0
                , null, null, dt5, 120);
            await TestDbContext.SaveChangesAsync();
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            Assert.AreEqual(2, result.Count);
            var merged1 = result.First();
            var merged2 = result.Skip(1).First();
            var expected1 = exc1.HiPointsCt + exc2.HiPointsCt;
            Assert.AreEqual(expected1, merged1.HiPointsCt);
            var expected2 = exc3.HiPointsCt + exc4.HiPointsCt + exc5.HiPointsCt;
            Assert.AreEqual(expected2, merged2.HiPointsCt);
        }

        [TestMethod]
        public async Task TwoCyclesTwoTagsTest() {
            var dt1 = new DateTime(2022, 1, 1);
            var dt2 = dt1.AddDays(2);
            var tagName1 = nameof(TwoCyclesTwoTagsTest) + "_a";
            var tagName2 = nameof(TwoCyclesTwoTagsTest) + "_b";

            var excRIn1 = TestDbContext.NewExcursionPoint(tagName1, 3, 1, 0
                , dt1, 110, null, null);
            var excROut1 = TestDbContext.NewExcursionPoint(tagName1, 5, 2, 0
                , null, null, dt2, 120);

            var excRIn2 = TestDbContext.NewExcursionPoint(tagName2, 3, 3, 0
                , dt1, 110, null, null);
            var excROut2 = TestDbContext.NewExcursionPoint(tagName2, 5, 4, 0
                , null, null, dt2, 120);

            var insertedRows = await TestDbContext.SaveChangesAsync();
            Assert.AreEqual(4, insertedRows);
            var result = await TestDbContext.Procedures.spMergeIncompleteCyclesAsync();
            Assert.AreEqual(2, result.Count);
            var merged1 = result.First(e => e.TagName == tagName1);
            var merged2 = result.First(e => e.TagName == tagName2);
            var expected1 = excRIn1.HiPointsCt + excROut1.HiPointsCt;
            Assert.AreEqual(expected1, merged1.HiPointsCt);
            var expected2 = excRIn2.HiPointsCt + excROut2.HiPointsCt;
            Assert.AreEqual(expected2, merged2.HiPointsCt);

        }
    }
}
