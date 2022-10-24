using ChambersDataModel;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class StagesTests
    {
        public static Stage NewStage(string stageName) {
            var tag = TagTests.NewTag(stageName);
            var stage = new Stage() { Tag = tag, StageName = stageName };
            return stage;
        }

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void InsertTest() {
            var name = NewName();
            var newStage = NewStage(name); newStage.MinValue = 10; newStage.MaxValue = 100;
            TestDbContext.Stages.Add(newStage);
            TestDbContext.SaveChanges();
            Assert.AreEqual(1, TestDbContext.Stages.Count());
            Assert.AreEqual(name, TestDbContext.Stages.First((st) => st.StageId == newStage.StageId).StageName);
        }
    }
}
