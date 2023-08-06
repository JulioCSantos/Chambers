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
    public class PropagateChangesTests
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
        public void PropagateDeprecatedDate() {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var baseDate = DateTime.Now.AddDays(-30);
            var stageDate1 = NewStageDate(name, baseDate, 40, 400);
            stageDate1.Stage.DeprecatedDate = stageDate1.Stage.ProductionDate!.Value.AddDays(10);
            var tag = stageDate1.Stage.Tag;
            var stage2 = new Stage(tag, 50, 500);
            var stageDate2 = new StagesDate(stage2, stageDate1.Stage.DeprecatedDate);
            //var excursion = new ExcursionPoint() {TagName = tag.TagName, }


            TestDbContext.Add(stageDate1);
            TestDbContext.Add(stageDate2);

            TestDbContext.SaveChanges();
        }
    }
}
