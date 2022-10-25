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
        public static Stage NewStageLimits(string stageName) {
            var tag = TagTests.NewTag(stageName);
            var stage = new Stage() { Tag = tag, StageName = stageName };
            return stage;
        }

        public static StagesDate NewStageDates(string stageName)
        {
            Stage stage = NewStageLimits(stageName);
            StagesDate stageDate = new() { Stage = stage };

            return stageDate;
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
            TestDbContext.SaveChanges();
            Assert.AreEqual(1, TestDbContext.Stages.Count());
            Assert.AreEqual(name, TestDbContext.Stages.First((st) => st.StageId == newStage.StageId).StageName);
        }

        [TestMethod]
        public void InsertStageDatesTest() {
            var name = NewName();
            var stageDate = NewStageDates(name);
            stageDate.Stage.MinValue = 20;
            stageDate.Stage.MaxValue = 200;
            stageDate.StartDate = new DateTime(2022, 01, 01);
            stageDate.EndDate = new DateTime(2022, 12, 31);
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            Assert.IsTrue(TestDbContext.StagesDates.Any());
            Assert.AreEqual(3, savedCount);
            Assert.IsNotNull(TestDbContext.StagesDates.First(sd => sd.Stage.StageName == name));
        }

        [TestMethod]
        public void ReadStagesLimitsAndDatesViewTest() {
            var name = NewName();
            var stageDate = NewStageDates(name);
            stageDate.Stage.MinValue = 30;
            stageDate.Stage.MaxValue = 300;
            stageDate.StartDate = new DateTime(2022, 02, 01);
            stageDate.EndDate = new DateTime(2022, 02, 28);
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDates.ToList();
            Assert.IsNotNull(viewResults);
        }
    }
}
