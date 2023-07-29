using ChambersDataModel;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Runtime.CompilerServices;
using Chambers.Common;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class StagesTests
    {
        public static Stage NewStageLimits(string stageName, double? minThreshold = null, double? maxThreshold = null) {
            var tag = new Tag(IntExtensions.NextId(), stageName);
            var stage = new Stage(tag, minThreshold, maxThreshold);
            return stage;
        }

        //public static Stage NewStageLimits(Tag tag, double? minValue = null, double? maxValue = null) {
        //    var stage = new Stage(tag, minValue, maxValue);
        //    return stage;
        //}

        //public static void StageSetValues(Stage stage, double? minValue, double? maxValue) {
        //    if (minValue != null) {stage.MinValue = (double)minValue; }
        //    if (maxValue != null) {stage.MaxValue = (double)maxValue; }
        //}


        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void InsertStageLimitsTest() {
            var name = NewName();
            var newStage = NewStageLimits(name, 10, 100);
            TestDbContext.Stages.Add(newStage);
            Assert.IsNull(TestDbContext.Stages.FirstOrDefault(st => st.StageName == newStage.StageName)?.Tag);
            TestDbContext.SaveChanges();
            Assert.AreEqual(name, TestDbContext.Stages.First((st) => st.StageId == newStage.StageId).StageName);
            Assert.IsNotNull(TestDbContext.Stages.FirstOrDefault(st => st.StageName == newStage.StageName)?.Tag);
            var entries = TestDbContext.ChangeTracker.Entries();
        }


        [TestMethod]
        public void DeprecatedStageTest() {
            var name = NewName();
            var stage1 = NewStageLimits(name, 40, 400); 
            stage1.DeprecatedDate = DateTime.UtcNow;
            var stage2 = NewStageLimits(name, 50 , 500); 

            // Duplicated StageName for the same Tag is invalid. Will test this exception
            stage2.Tag = stage1.Tag;
            stage2.StageName = stage1.StageName;

            TestDbContext.Stages.Add(stage1);
            TestDbContext.Stages.Add(stage2);

            //var ex = Assert.ThrowsException<DbUpdateException>(() => TestDbContext.SaveChanges());
            //Assert.IsTrue(ex.InnerException?.Message.Contains("duplicate"));
            TestDbContext.SaveChanges();

            //rollback
            //var savedTag = stage1.Tag;
            //TestDbContext.Stages.Remove(stage2);
            //TestDbContext.Stages.Remove(stage1);
            //TestDbContext.Tags.Remove(savedTag);
            //TestDbContext.RollBack();
            //var entries = TestDbContext.ChangeTracker.Entries();
            var dupStages = TestDbContext.Stages.Where(st => st.StageName == stage1.StageName);
            Assert.AreEqual(2, dupStages.Count());
        }
    }
}
