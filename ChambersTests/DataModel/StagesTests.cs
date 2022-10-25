using ChambersDataModel;
using Microsoft.EntityFrameworkCore;
using System.Linq;
using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class StagesTests
    {
        public static Stage NewStageLimits(string stageName) {
            var tag = TagTests.NewTag(stageName);
            var stage = new Stage() { Tag = tag, StageName = stageName };
            return stage;
        }

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void InsertStageLimitsTest() {
            var name = NewName();
            var newStage = NewStageLimits(name); newStage.MinValue = 10; newStage.MaxValue = 100;
            TestDbContext.Stages.Add(newStage);
            Assert.IsNull(TestDbContext.Stages.FirstOrDefault(st => st.StageName == newStage.StageName)?.Tag);
            TestDbContext.SaveChanges();
            Assert.AreEqual(name, TestDbContext.Stages.First((st) => st.StageId == newStage.StageId).StageName);
            Assert.IsNotNull(TestDbContext.Stages.FirstOrDefault(st => st.StageName == newStage.StageName)?.Tag);
            var entries = TestDbContext.ChangeTracker.Entries();
        }


        [TestMethod]
        public void DuplicatedStageNameNegativeTest() {
            var name = NewName();
            var stage1 = NewStageLimits(name); stage1.MinValue = 40; stage1.MaxValue = 400;
            var stage2 = NewStageLimits(name); stage2.MinValue = 50; stage2.MaxValue = 500;

            // Duplicated StageName for the same Tag is invalid. Will test this exception
            stage2.Tag = stage1.Tag;
            stage2.StageName = stage1.StageName;

            TestDbContext.Stages.Add(stage1);
            TestDbContext.Stages.Add(stage2);
            
            var ex = Assert.ThrowsException<DbUpdateException>(() => TestDbContext.SaveChanges());
            Assert.IsTrue(ex.InnerException?.Message.Contains("duplicate"));
            
            //rollback
            //var savedTag = stage1.Tag;
            //TestDbContext.Stages.Remove(stage2);
            //TestDbContext.Stages.Remove(stage1);
            //TestDbContext.Tags.Remove(savedTag);
            TestDbContext.RollBack();
            var entries = TestDbContext.ChangeTracker.Entries();
        }
    }
}
