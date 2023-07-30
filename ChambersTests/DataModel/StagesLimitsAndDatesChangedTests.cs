using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using Humanizer;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class StagesLimitsAndDatesChangedTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesLimitsAndDatesCoreTests) + "_" + name;
            return newName;
        }
        [TestMethod]
        public void StageDeprecatedTest() {
            var tag1 = new Tag(NewName());
            var baseDate = DateTime.Today.AddMonths(-3);
            var stage1 = new Stage(tag1, baseDate,100,200) { DeprecatedDate = baseDate.AddMonths(1) };
            var stageDate1 = new StagesDate(stage1);
            var stage2 = new Stage(tag1, baseDate.AddMonths(1), 111, 222);
            var stageDate2 = new StagesDate(stage2);
            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesChangeds
                .Where(std => std.TagName == tag1.TagName)
                .OrderBy(t => t.TagId)
                .ThenBy(s => s.StageDateId).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(2, viewResults.Count);
            Assert.IsTrue(viewResults.First().IsDeprecated);
            Assert.AreEqual(stage1.DeprecatedDate.Value, viewResults.First().StageDeprecatedDate!.Value);
        }
        [TestMethod]
        public void StageDateDeprecatedTest() {
            TestDbContext.IsPreservedForTest = true;
            var tag1 = new Tag(NewName());
            var baseDate = DateTime.Today.AddMonths(-3);
            var stage1 = new Stage(tag1, baseDate, 100, 200) ;
            var stageDate1 = new StagesDate(stage1) { DeprecatedDate = baseDate.AddMonths(1) };
            //one month idle
            var stageDate2 = new StagesDate(stage1) {StartDate = baseDate.AddMonths(2)} ;
            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesChangeds
                .Where(std => std.TagName == tag1.TagName)
                .OrderBy(t => t.TagId)
                .ThenBy(s => s.StageDateId).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(2, viewResults.Count);
            Assert.IsTrue(viewResults.First().IsDeprecated);
            Assert.AreEqual(stageDate1.DeprecatedDate.Value, viewResults.First().StageDateDeprecatedDate!.Value);
        }

        [TestMethod]
        public void TagDecommissionedTest() {
            TestDbContext.IsPreservedForTest = true;
            var baseDate = DateTime.Today.AddMonths(-3);
            var tag1 = new Tag(NewName()){ DecommissionedDate = DateTime.Now };
            var stage1 = new Stage(tag1, baseDate, 100, 200);
            var stageDate1 = new StagesDate(stage1);
            TestDbContext.Add(stageDate1);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesChangeds
                .Where(std => std.TagName == tag1.TagName)
                .OrderBy(t => t.TagId)
                .ThenBy(s => s.StageDateId).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
            var timeSpan = tag1.DecommissionedDate.Value - viewResults.First().DecommissionedDate!.Value;
            Assert.AreEqual(tag1.DecommissionedDate.Value.Date, viewResults.First().DecommissionedDate!.Value.Date);
        }

        [TestMethod]
        public void DecommissionedDeprecatedTest() {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var baseDate = DateTime.Now.AddDays(-3);
            var tag1 = new Tag(NewName());
            var stage1 = new Stage(tag1, baseDate, 100, 200) { DeprecatedDate = baseDate.AddMonths(1) };
            var stageDate1 = new StagesDate(stage1, stage1.ProductionDate);
            var stage2 = new Stage(tag1, stage1.DeprecatedDate!.Value, 111, 222);
            var stageDate2 = new StagesDate(stage2, stage1.DeprecatedDate);
            var tag2 = new Tag(NewName() + "2") { DecommissionedDate = baseDate.AddMonths(2) };
            var stage3 = new Stage(tag2, baseDate, 200, 300);
            var stageDate3 = new StagesDate(stage3, stage3.ProductionDate);
            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);
            TestDbContext.Add(stageDate3);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesChangeds
                .Where(std => std.StageName.StartsWith(name)).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(3, viewResults.Count);
            var deprecatedStage = viewResults.First();
            Assert.IsTrue(deprecatedStage.IsDeprecated);
            Assert.AreEqual(stageDate1.Stage.DeprecatedDate!.Value.Date, deprecatedStage.StageDeprecatedDate!.Value.Date);
            var replacementStage = viewResults.Skip(1).First();
            Assert.IsFalse(replacementStage.IsDeprecated);
            Assert.AreEqual(replacementStage.TagId, deprecatedStage.TagId);
            var decommissionedTag = viewResults.Skip(2).First();
            Assert.IsNotNull(decommissionedTag.DecommissionedDate);
        }
    }
}
