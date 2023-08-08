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

            //var exc1 = new ExcursionPoint() {
            //    StageDateId = stageDate1.StageDateId
            //    , TagId = tag.TagId, TagName = tag.TagName, FirstExcDate = stage1.ProductionDate
            //    , LastExcDate = stage1.ProductionDate!.Value.AddDays(20)
            //};
            //TestDbContext.Add(exc1);
            TestDbContext.SaveChanges();
            var result = TestDbContext.Procedures
                .spPropagateDeprecatedDecomissionedAsync(stageDate1.StageDateId).Result;
            Assert.AreEqual(0, result.Count);

        }

        [TestMethod]
        public void PropagateDeprecatedDate() {
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

            var exc1 = new ExcursionPoint() { StageDateId = stageDate1.StageDateId
                , TagId = tag.TagId, TagName = tag.TagName, FirstExcDate = stage1.ProductionDate
                , LastExcDate = stage1.ProductionDate!.Value.AddDays(20)
            };
            TestDbContext.Add(exc1);
            TestDbContext.SaveChanges();
            var result =
                TestDbContext.Procedures.spPropagateDeprecatedDecomissionedAsync(stageDate1.StageDateId).Result;
            Assert.AreEqual(1, result.Count);

        }
    }
}
