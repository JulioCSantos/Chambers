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
            Assert.IsTrue(timeSpan < TimeSpan.FromSeconds(1));
        }
    }

}
