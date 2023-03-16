using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class StagesLimitsAndDatesCoreTests
    {
        private static string NewName([CallerMemberName] string? name = null)
        {
            var newName = nameof(StagesLimitsAndDatesCoreTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void ReadingTest()
        {
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesCores
                .Where(std => std.StageName == name).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
            Assert.IsFalse(viewResults.First().IsDeprecated);
        }

        [TestMethod]
        public void StageDeprecatedTest()
        {
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            stageDate.Stage.DeprecatedDate = DateTime.Now;
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesCores
                .Where(std => std.StageName == name).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
            Assert.IsTrue(viewResults.First().IsDeprecated);
            Assert.AreEqual(stageDate.Stage.DeprecatedDate.Value.Date, viewResults.First().StageDeprecatedDate!.Value.Date);

        }

        [TestMethod]
        public void StageDateDeprecatedTest()
        {
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            stageDate.DeprecatedDate = DateTime.Now;
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesCores
                .Where(std => std.StageName == name).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
            Assert.IsTrue(viewResults.First().IsDeprecated);
            Assert.AreEqual(stageDate.DeprecatedDate.Value.Date, viewResults.First().StageDateDeprecatedDate!.Value.Date);
        }
    }
}
