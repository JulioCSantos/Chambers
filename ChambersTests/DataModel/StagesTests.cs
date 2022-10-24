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
        //private static ChambersDbContext imContext = BootStrap.InMemoryDbcontext;
        private static ChambersDbContext context = BootStrap.GetNamedContext("ChambersTest");
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
            context.Stages.Add(newStage);
            context.SaveChanges();
            Assert.AreEqual(1, context.Stages.Count());
            Assert.AreEqual(name, context.Stages.First((st) => st.StageId == newStage.StageId).StageName);
            CascadeDelete(name);
        }

        public void CascadeDelete(string nameOnTest)
        {
            var stage = context.Stages.FirstOrDefault((st) => st.StageName == nameOnTest);
            if (stage != null) { context.Remove(stage); }

            var tag = context.Tags.FirstOrDefault((t) => t.TagName == nameOnTest);
            if (tag != null) { context.Remove(tag); }

            context.SaveChanges();

        }
    }
}
