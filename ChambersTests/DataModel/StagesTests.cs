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
        #region Context
        private static ChambersDbContext imContext = BootStrap.InMemoryDbcontext;
        #endregion Context

        public static Stage NewStage(string stageName)
        {
            var tag = TagTests.NewTag(stageName);
            //imContext.Tags.Add(tag);
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
            CascadeDelete(name);
            var newStage = NewStage(name); newStage.MinValue = 10; newStage.MaxValue = 100;
            imContext.Stages.Add(newStage);
            imContext.SaveChanges();
            Assert.AreEqual(1, imContext.Stages.Count());
            Assert.AreEqual(name, imContext.Stages.First((st) => st.StageId == newStage.StageId).StageName);
            CascadeDelete(name);
        }

        public void CascadeDelete(string nameOnTest)
        {
            var stage = imContext.Stages.FirstOrDefault((st) => st.StageName == nameOnTest);
            if (stage != null) { imContext.Remove(stage); }

            var tag = imContext.Tags.FirstOrDefault((t) => t.TagName == nameOnTest);
            if (tag != null) { imContext.Remove(tag); }

            imContext.SaveChanges();

        }
    }
}
