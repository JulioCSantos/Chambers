using Chambers.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class spPropagateDeprecatedDecomissionedTests
    {
        #region aux methods
        public static StagesDate NewStageDate(string stageName, DateTime startDate
            , double? minThreshold = null, double? maxThreshold = null) {
            var tag = new Tag(IntExtensions.NextId(), stageName);
            Stage stage = new (tag, minThreshold, maxThreshold) {ProductionDate = startDate};
            var stageDate = new StagesDate(stage, startDate, DateTime.MaxValue);
            return stageDate;
        }
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesTests) + "_" + name;
            return newName;
        }
        #endregion aux methods

        [TestMethod]
        public void NoExcursionsTest() {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var baseDate = DateTime.Now.AddDays(-30);
            var stageDate1 = NewStageDate(name, baseDate, 40, 400);
            var stage1 = stageDate1.Stage;
            stageDate1.Stage.DeprecatedDate = stageDate1.Stage.ProductionDate!.Value.AddDays(10);
            var tag = stageDate1.Stage.Tag;
            var stage2 = new Stage(tag, 50, 500);
            var stageDate2 = new StagesDate(stage2, stageDate1.Stage.DeprecatedDate!.Value.AddDays(-2));
            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);
            TestDbContext.SaveChanges();
            
            var result = TestDbContext.Procedures
                .spPropagateDeprecatedDecomissionedAsync(stageDate1.StageDateId).Result;
            Assert.AreEqual(0, result.Count);

        }

        [TestMethod]
        public void OneExcursionDeprecated() {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var baseDate = DateTime.Now.AddDays(-30);
            var stageDate1 = NewStageDate(name, baseDate, 40, 400);
            var stage1 = stageDate1.Stage;
            stageDate1.Stage.DeprecatedDate = stageDate1.Stage.ProductionDate!.Value.AddDays(10);
            var tag = stageDate1.Stage.Tag;
            var stage2 = new Stage(tag, 50, 500);
            var stageDate2 = new StagesDate(stage2, stageDate1.Stage.DeprecatedDate!.Value.AddDays(-2));
            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);
            var exc1 = new ExcursionPoint() {
                StageDateId = stageDate1.StageDateId
                , TagId = tag.TagId, TagName = tag.TagName, FirstExcDate = stage1.ProductionDate
                , LastExcDate = stage1.DeprecatedDate!.Value
            };
            TestDbContext.Add(exc1);
            var exc2 = new ExcursionPoint() {
                StageDateId = stageDate1.StageDateId
                , TagId = tag.TagId, TagName = tag.TagName, FirstExcDate = stage1.ProductionDate
                , LastExcDate = stage1.DeprecatedDate!.Value.AddDays(2)
            };
            TestDbContext.Add(exc2);
            TestDbContext.SaveChanges();

            var result = TestDbContext.Procedures
                .spPropagateDeprecatedDecomissionedAsync(stageDate1.StageDateId).Result;
            Assert.AreEqual(1, result.Count);
            var dateDiff = (stage1.DeprecatedDate!.Value - result.First().DeprecatedDate!.Value).TotalSeconds;
            Assert.IsTrue(dateDiff < 1);
        }

        [TestMethod]
        public void OneExcursionDecommissioned() {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var baseDate = DateTime.Now.AddDays(-30);
            var stageDate1 = NewStageDate(name, baseDate, 40, 400);
            var stage1 = stageDate1.Stage;
            var tag = stageDate1.Stage.Tag;
            tag.DecommissionedDate = stageDate1.Stage.ProductionDate!.Value.AddDays(10);
            var stage2 = new Stage(tag, 50, 500);
            var stageDate2 = new StagesDate(stage2, tag.DecommissionedDate!.Value.AddDays(-2));
            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);
            var exc1 = new ExcursionPoint() { StageDateId = stageDate1.StageDateId
                , TagId = tag.TagId, TagName = tag.TagName, FirstExcDate = stage1.ProductionDate
                , LastExcDate = tag.DecommissionedDate!.Value };
            TestDbContext.Add(exc1);
            var exc2 = new ExcursionPoint() {
                StageDateId = stageDate1.StageDateId
                , TagId = tag.TagId, TagName = tag.TagName, FirstExcDate = stage1.ProductionDate
                , LastExcDate = tag.DecommissionedDate!.Value.AddDays(2)
            };
            TestDbContext.Add(exc2);
            TestDbContext.SaveChanges();

            var result = TestDbContext.Procedures
                .spPropagateDeprecatedDecomissionedAsync(stageDate1.StageDateId).Result;
            Assert.AreEqual(1, result.Count);
            var dateDiff = (tag.DecommissionedDate!.Value - result.First().DecommissionedDate!.Value).TotalSeconds;
            Assert.IsTrue(dateDiff < 1);
        }


        [TestMethod]
        public void TwoExcursionDeprecated() {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var baseDate = DateTime.Now.AddDays(-60);

            var stageDate1 = NewStageDate(name, baseDate, 40, 400);
            var stage1 = stageDate1.Stage;
            var tag = stage1.Tag;
            stageDate1.Stage.DeprecatedDate = stage1.ProductionDate!.Value.AddDays(5);
            TestDbContext.Add(stageDate1);
            
            var stageDate2 = NewStageDate(name, stage1.DeprecatedDate!.Value.AddDays(-3), 50, 500);
            var stage2 = stageDate2.Stage;
            stage2.Tag = tag;
            stageDate2.Stage.DeprecatedDate = stage2.ProductionDate!.Value.AddDays(5);
            TestDbContext.Add(stageDate2);


            var stageDate3 = NewStageDate(name, stage2.DeprecatedDate!.Value.AddDays(-3), 60, 600);
            var stage3 = stageDate3.Stage;
            stage3.Tag = tag;
            TestDbContext.Add(stageDate3);

            //not deprecated Excursion because it precedes the deprecated date 
            var exc1 = new ExcursionPoint() { StageDateId = stageDate1.StageDateId, TagId = tag.TagId, TagName = tag.TagName
                , FirstExcDate = stage1.DeprecatedDate!.Value.AddDays(-6)
                , LastExcDate = stage1.DeprecatedDate!.Value.AddDays(-3)
            };
            TestDbContext.Add(exc1);

            //deprecated Excursion because it happened between production and after Deprecated
            var exc2 = new ExcursionPoint() { StageDateId = stageDate1.StageDateId, TagId = tag.TagId, TagName = tag.TagName
                , FirstExcDate = stage1.ProductionDate
                , LastExcDate = stage1.DeprecatedDate!.Value.AddDays(2)
            };
            TestDbContext.Add(exc2);

            //deprecated Excursion because it happened between production and after Deprecated
            var exc3 = new ExcursionPoint() { StageDateId = stageDate2.StageDateId, TagId = tag.TagId, TagName = tag.TagName
                , FirstExcDate = stage2.ProductionDate
                , LastExcDate = stage2.DeprecatedDate!.Value.AddDays(2)
            };
            TestDbContext.Add(exc3);

            var ct = TestDbContext.SaveChanges();

            var result = TestDbContext.Procedures
                .spPropagateDeprecatedDecomissionedAsync(stageDate1.StageDateId).Result;
            Assert.AreEqual(2, result.Count);
            var dateDiff1 = (stage1.DeprecatedDate!.Value - result.First().DeprecatedDate!.Value).TotalSeconds;
            Assert.IsTrue(dateDiff1 < 1);
            var dateDiff2 = (stage2.DeprecatedDate!.Value - result.Skip(1).First().DeprecatedDate!.Value).TotalSeconds;
            Assert.IsTrue(dateDiff2 < 1);

        }

    }
}
