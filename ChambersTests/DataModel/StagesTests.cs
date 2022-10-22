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
        private static ChambersDbContext Context = BootStrap.InMemoryDbcontext;
        #endregion Context

        public static Stage NewStage(string stageName)
        {
            var tag = TagTests.NewTag(stageName);
            Context.Tags.Add(tag);
            var stage = new Stage() { TagId = tag.TagId, StageName = stageName };
            return stage;
        }

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void InsertTest() {
            var name = NewName();
            RemoveNameInStageTests(name);
            var newStage = NewStage(name);
            newStage.MinValue = 10;
            newStage.MaxValue = 100;
            Context.Stages.Add(newStage);
            Context.SaveChanges();
            Assert.AreEqual(1, Context.Stages.Count());
            Assert.AreEqual(name, Context.Stages.First((st) => st.StageId == newStage.StageId).StageName);
            RemoveNameInStageTests(name);
        }

        public void RemoveNameInStageTests(string nameOnTest)
        {
            var stage = Context.Stages.FirstOrDefault((st) => st.StageName == nameOnTest);
            if (stage != null) { Context.Remove(stage); }

            var tag = Context.Tags.FirstOrDefault((t) => t.TagName == nameOnTest);
            if (tag != null) { Context.Remove(tag); }

            Context.SaveChanges();

        }
    }
}
