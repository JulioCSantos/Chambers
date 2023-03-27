using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class spPivotExcursionPointsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(spPivotExcursionPointsTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task EmptyTest() {
            var result = await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (-1, new DateTime(2018, 01, 01), new DateTime(2018, 03, 31), 100, 200, null, null);
            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task HiExcursionWithPrevTagExcNbrTest()
        {
            string tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var prevDt = new DateTime(2022, 01, 01);
            await TestDbContext.SaveChangesAsync();

            var prevExcPoint = new ExcursionPoint() {
                TagId = 11, StageDateId = stageDate.StageDateId, TagName = tag, TagExcNbr = 22,
                RampInDate = prevDt.AddDays(1), RampInValue = lt + 50, FirstExcDate = prevDt.AddDays(2),
                FirstExcValue = ht + 20, LastExcDate = prevDt.AddDays(3), LastExcValue = ht + 10
                , RampOutDate = prevDt.AddDays(4), RampOutValue = lt + 50, HiPointsCt = 3, LowPointsCt = 0
            };
            TestDbContext.Add(prevExcPoint);
            var rampInP1 = new Interpolated(tag,dt.AddDays(1), lt + 20); TestDbContext.Add(rampInP1);
            var rampInP2 = new Interpolated(tag, dt.AddDays(2), lt + 60); TestDbContext.Add(rampInP2);
            var excP1 = new Interpolated(tag, dt.AddDays(3), ht + 20); TestDbContext.Add(excP1);
            var excP2 = new Interpolated(tag, dt.AddDays(4), ht + 60); TestDbContext.Add(excP2);
            var excP3 = new Interpolated(tag, dt.AddDays(5), ht + 40); TestDbContext.Add(excP3);
            var rampOutP1 = new Interpolated(tag, dt.AddDays(6), ht - 10); TestDbContext.Add(rampOutP1);
            var rampOutP2 = new Interpolated(tag, dt.AddDays(7), ht - 30); TestDbContext.Add(rampOutP2);
            //TestDbContext.Interpolateds.AddRange(TestDbContext.Interpolateds.ToInterpolatedPoints());
            await TestDbContext.SaveChangesAsync();

            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            //Assert.AreEqual(prevExcPoint.TagExcNbr + 1, excPointNew.TagExcNbr);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.HiPointsCt == 3);
            Assert.IsTrue(excPointNew.LowPointsCt == 0);
            Assert.IsNull(excPointNew.ThresholdDuration);
            Assert.IsNull(excPointNew.SetPoint);
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
        public async Task LowExcursionTest()
        {
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate); 
            var rampInP1 = new Interpolated(tag, dt.AddDays(1), lt + 60); TestDbContext.Add(rampInP1);
            var rampInP2 = new Interpolated(tag, dt.AddDays(2), lt + 20); TestDbContext.Add(rampInP2);
            var excP1 = new Interpolated(tag, dt.AddDays(3), lt - 20); TestDbContext.Add(excP1);
            var excP2 = new Interpolated(tag, dt.AddDays(4), lt - 30); TestDbContext.Add(excP2);
            var excP3 = new Interpolated(tag, dt.AddDays(5), lt - 10); TestDbContext.Add(excP3);
            var rampOutP1 = new Interpolated(tag, dt.AddDays(6), lt + 70); TestDbContext.Add(rampOutP1);
            var rampOutP2 = new Interpolated(tag, dt.AddDays(7), lt + 90); TestDbContext.Add(rampOutP2);
            //TestDbContext.Add(rampInP1); TestDbContext.Add(rampInP2);
            //TestDbContext.Add(excP1); TestDbContext.Add(excP2); TestDbContext.Add(excP3);
            //TestDbContext.Add(rampOutP1); TestDbContext.Add(rampOutP2);
            await TestDbContext.SaveChangesAsync();
            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht, null, null)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsNotNull(excPointNew.StageDateId);
            Assert.AreEqual(stageDate.StageDateId, excPointNew.StageDateId);
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
        public async Task NullableHighExcursionTest()
        {
            var tag = NewName();
            var dt = new DateTime(2023, 02, 01);
            float lt = 100; float? ht = null;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInPl1 = new Interpolated(tag, dt.AddDays(1), lt + 60); TestDbContext.Add(rampInPl1);
            var excPl1 = new Interpolated(tag, dt.AddDays(3), lt - 50); TestDbContext.Add(excPl1);
            var rampOutPl1 = new Interpolated(tag, dt.AddDays(6), lt + 70); TestDbContext.Add(rampOutPl1);
            await TestDbContext.SaveChangesAsync();
            var excPnt = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(-30), dt.AddDays(+30), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(excPnt);
            Assert.IsTrue(excPnt.LowPointsCt == 1);
            Assert.IsTrue(excPnt.HiPointsCt == 0);
            Assert.IsNotNull(excPnt.MinThreshold);
            Assert.AreEqual(excPnt.MinThreshold,lt);
            Assert.IsNull(excPnt.MaxThreshold);
        }

        [TestMethod]
        public async Task NullableLowExcursionTest() {
            var tag = NewName();
            var dt = new DateTime(2023, 02, 01);
            float? lt = null; float? ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInPl1 = new Interpolated(tag, dt.AddDays(1), (float)(ht - 60)); TestDbContext.Add(rampInPl1);
            var excPl1 = new Interpolated(tag, dt.AddDays(3), (float)(ht + 50)); TestDbContext.Add(excPl1);
            var rampOutPl1 = new Interpolated(tag, dt.AddDays(6), (float)(ht - 70)); TestDbContext.Add(rampOutPl1);
            await TestDbContext.SaveChangesAsync();
            var excPnt = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(-30), dt.AddDays(+30), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(excPnt);
            Assert.IsTrue(excPnt.LowPointsCt == 0);
            Assert.IsTrue(excPnt.HiPointsCt == 1);
            Assert.IsNull(excPnt.MinThreshold);
            Assert.AreEqual(excPnt.MaxThreshold, ht);
            Assert.IsNotNull(excPnt.MaxThreshold);
        }

        [TestMethod]
        public async Task HiLowExcursionTest()
        {
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInPh1 = new Interpolated(tag, dt.AddDays(1), lt + 20); TestDbContext.Add(rampInPh1);
            var rampInPh2 = new Interpolated(tag, dt.AddDays(2), lt + 60); TestDbContext.Add(rampInPh2);
            var excPh1 = new Interpolated(tag, dt.AddDays(3), ht + 20); TestDbContext.Add(excPh1);
            var excPh2 = new Interpolated(tag, dt.AddDays(4), ht + 60); TestDbContext.Add(excPh2);
            var excPh3 = new Interpolated(tag, dt.AddDays(5), ht + 40); TestDbContext.Add(excPh3);
            var rampOutPh1 = new Interpolated(tag, dt.AddDays(6), ht - 10); TestDbContext.Add(rampOutPh1);
            var rampOutPh2 = new Interpolated(tag, dt.AddDays(7), ht - 30); TestDbContext.Add(rampOutPh2);
            dt = dt.AddDays(10);
            var rampInPl1 = new Interpolated(tag, dt.AddDays(1), lt + 60); TestDbContext.Add(rampInPl1);
            var rampInPl2 = new Interpolated(tag, dt.AddDays(2), lt + 20); TestDbContext.Add(rampInPl2);
            var excPl1 = new Interpolated(tag, dt.AddDays(3), lt - 20); TestDbContext.Add(excPl1);
            var excPl2 = new Interpolated(tag, dt.AddDays(4), lt - 30); TestDbContext.Add(excPl2);
            var excPl3 = new Interpolated(tag, dt.AddDays(5), lt - 10); TestDbContext.Add(excPl3);
            var rampOutPl1 = new Interpolated(tag, dt.AddDays(6), lt + 70); TestDbContext.Add(rampOutPl1);
            var rampOutPl2 = new Interpolated(tag, dt.AddDays(7), lt + 90); TestDbContext.Add(rampOutPl2);
            await TestDbContext.SaveChangesAsync();

            var excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.HiPointsCt == 3);
            Assert.IsTrue(excPointNew.LowPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue >= ht);
            Assert.IsTrue(excPointNew.LastExcValue >= ht);
            Assert.IsNull(excPointNew.ThresholdDuration);
            Assert.IsNull(excPointNew.SetPoint);
            excPointNew = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), lt, ht,null, null)).Skip(1).FirstOrDefault();
            Assert.IsNotNull(excPointNew);
            Assert.IsTrue(excPointNew.TagName == tag);
            Assert.IsTrue(excPointNew.LowPointsCt == 3);
            Assert.IsTrue(excPointNew.HiPointsCt == 0);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.RampInValue >= lt && excPointNew.RampInValue < ht);
            Assert.IsTrue(excPointNew.FirstExcValue < lt);
            Assert.IsTrue(excPointNew.LastExcValue < lt);
        }

        [TestMethod]
        public async Task LengthyHiExcursionTest()
        {
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInP1 = new Interpolated(tag, dt, ht - 60); TestDbContext.Add(rampInP1);
            var excP1 = new Interpolated(tag, dt.AddDays(1), ht + 20); TestDbContext.Add(excP1);
            var excP2 = new Interpolated(tag, dt.AddDays(5), ht + 30); TestDbContext.Add(excP2);
            var excP3 = new Interpolated(tag, dt.AddDays(9), ht + 10); TestDbContext.Add(excP3);
            var rampOutP1 = new Interpolated(tag, dt.AddDays(10), ht - 60); TestDbContext.Add(rampOutP1);
            await TestDbContext.SaveChangesAsync();

            var rampInExc = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt, dt.AddDays(2), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(rampInExc);
            Assert.AreEqual(1, rampInExc.TagExcNbr);
            Assert.IsTrue(rampInExc.TagName == tag);
            Assert.IsTrue(rampInExc.HiPointsCt == 1);
            Assert.IsTrue(rampInExc.RampInValue >= lt && rampInExc.RampInValue < ht);
            Assert.IsTrue(Equals(rampInExc.FirstExcValue!, excP1.Value));
            Assert.IsNotNull(rampInExc.LastExcValue);
            Assert.IsNotNull(rampInExc.LastExcDate);

            var ep = rampInExc.ToExcursionPoint();
            await TestDbContext.ExcursionPoints.AddAsync(ep);
            await TestDbContext.SaveChangesAsync();

            var rampOutPoint = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(2), dt.AddDays(11), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(rampOutPoint);
            Assert.AreEqual(2,rampOutPoint.HiPointsCt);
            Assert.AreEqual(excP3.Time,rampOutPoint.LastExcDate);
            Assert.AreEqual(rampOutP1.Time,rampOutPoint.RampOutDate);
        }


        [TestMethod]
        public async Task LengthyHiExcursionTest2() {
            //TestDbContext.IsPreservedForTest = true;
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            var lt = 100; var ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInP1 = new Interpolated(tag, dt, ht - 60); TestDbContext.Add(rampInP1);
            var excP1 = new Interpolated(tag, dt.AddDays(1), ht + 20); TestDbContext.Add(excP1);
            var excP2 = new Interpolated(tag, dt.AddDays(5), ht + 30); TestDbContext.Add(excP2);
            var excP3 = new Interpolated(tag, dt.AddDays(9), ht + 10); TestDbContext.Add(excP3);
            var rampOutP1 = new Interpolated(tag, dt.AddDays(10), ht - 60); TestDbContext.Add(rampOutP1);
            await TestDbContext.SaveChangesAsync();
            var rampInPoint = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt, dt.AddDays(2), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(rampInPoint);
            Assert.AreEqual(1, rampInPoint.TagExcNbr);
            Assert.IsTrue(rampInPoint.TagName == tag);
            Assert.IsTrue(rampInPoint.HiPointsCt == 1);
            Assert.IsTrue(rampInPoint.RampInValue >= lt && rampInPoint.RampInValue < ht);
            Assert.IsTrue(Equals(rampInPoint.FirstExcValue!, excP1.Value));
            Assert.IsNotNull(rampInPoint.LastExcValue);
            Assert.IsNotNull(rampInPoint.LastExcDate);

            var savingdRampInPoint = rampInPoint.ToExcursionPoint();
            await TestDbContext.ExcursionPoints.AddAsync(savingdRampInPoint);
            await TestDbContext.SaveChangesAsync();

            var middleExcPoint = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(2), dt.AddDays(6), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(middleExcPoint);
            Assert.AreEqual(1, middleExcPoint.HiPointsCt);
            Assert.IsNotNull(middleExcPoint.LastExcDate);
            Assert.IsNull(middleExcPoint.RampOutDate);

            var savedRampInPoint = TestDbContext.ExcursionPoints.Single(ep => ep.CycleId == savingdRampInPoint.CycleId);
            TestDbContext.Remove(savedRampInPoint);
            await TestDbContext.SaveChangesAsync();
            await TestDbContext.ExcursionPoints.AddAsync(middleExcPoint.ToExcursionPoint());
            await TestDbContext.SaveChangesAsync();

            var rampOutPoint = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(6), dt.AddDays(11), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(rampOutPoint!.LastExcDate);
            Assert.IsNotNull(rampOutPoint.RampOutDate);
        }

        [TestMethod]
        public async Task LengthyHiExcursionWithNullThreshold() {
            var tag = NewName();
            var dt = new DateTime(2022, 01, 31);
            float? lt = null; var ht = 200;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInP1 = new Interpolated(tag, dt, ht - 60); TestDbContext.Add(rampInP1);
            var excP1 = new Interpolated(tag, dt.AddDays(1), ht + 20); TestDbContext.Add(excP1);
            var excP2 = new Interpolated(tag, dt.AddDays(5), ht + 30); TestDbContext.Add(excP2);
            var excP3 = new Interpolated(tag, dt.AddDays(9), ht + 10); TestDbContext.Add(excP3);
            var rampOutP1 = new Interpolated(tag, dt.AddDays(10), ht - 60); TestDbContext.Add(rampOutP1);
            await TestDbContext.SaveChangesAsync();

            var rampInResult = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                    (stageDate.StageDateId, dt, dt.AddDays(2), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(rampInResult);
            Assert.IsNotNull(rampInResult.StageDateId);
            Assert.AreEqual(1, rampInResult.TagExcNbr);
            Assert.IsTrue(rampInResult.TagName == tag);
            Assert.IsTrue(rampInResult.HiPointsCt == 1);
            Assert.IsTrue(rampInResult.RampInValue < ht);
            Assert.IsTrue(Equals(rampInResult.FirstExcValue!, excP1.Value));
            Assert.IsNotNull(rampInResult.LastExcValue);
            Assert.IsNotNull(rampInResult.LastExcDate);

            var rampInExc = rampInResult.ToExcursionPoint();
            await TestDbContext.ExcursionPoints.AddAsync(rampInExc);
            await TestDbContext.SaveChangesAsync();

            var middleExcPoint = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(2), dt.AddDays(6), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(middleExcPoint);
            Assert.AreEqual(1, middleExcPoint.HiPointsCt);
            Assert.IsNotNull(middleExcPoint.LastExcDate);
            Assert.IsNull(middleExcPoint.RampOutDate);

            await TestDbContext.ExcursionPoints.AddAsync(middleExcPoint.ToExcursionPoint());
            await TestDbContext.SaveChangesAsync();

            var rampOutPoint = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                    (stageDate.StageDateId, dt.AddDays(6), dt.AddDays(11), lt, ht,null, null)).FirstOrDefault();
            Assert.IsNotNull(rampOutPoint!.LastExcDate);
            Assert.IsNotNull(rampOutPoint.RampOutDate);
        }

        [TestMethod]
        public async Task CheckReturnValueTest() {
            var tag = NewName();
            var dt = new DateTime(2023, 02, 01);
            float lt = 100; float? ht = null;
            var stageDate = new StagesDate(tag, dt);
            stageDate.Stage.SetThresholds(lt, ht);
            TestDbContext.Add(stageDate);
            var rampInPl1 = new Interpolated(tag, dt.AddDays(1), lt + 60); TestDbContext.Add(rampInPl1);
            var excPl1 = new Interpolated(tag, dt.AddDays(3), lt - 50); TestDbContext.Add(excPl1);
            var rampOutPl1 = new Interpolated(tag, dt.AddDays(6), lt + 70); TestDbContext.Add(rampOutPl1);
            await TestDbContext.SaveChangesAsync();
            OutputParameter<int> retValue = new();
            var excPnt = (await TestDbContext.Procedures.spPivotExcursionPointsAsync
                (stageDate.StageDateId, dt.AddDays(-30), dt.AddDays(+30), lt, ht, null, retValue)).FirstOrDefault();
            Assert.AreEqual(0,retValue.Value);
            Assert.IsNotNull(excPnt);
            Assert.IsTrue(excPnt.LowPointsCt == 1);
            Assert.IsTrue(excPnt.HiPointsCt == 0);
            Assert.IsNotNull(excPnt.MinThreshold);
            Assert.AreEqual(excPnt.MinThreshold, lt);
            Assert.IsNull(excPnt.MaxThreshold);
        }
    }
}
