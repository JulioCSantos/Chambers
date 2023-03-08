using ChambersTests.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests
{
    [TestClass]
    public class StagesLimitsAndDatesCoreTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesLimitsAndDatesCoreTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void Reading1Test()
        {
            TestDbContext.IsPreservedForTest = true;
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDatesCores
                .Where(std => std.StageName == name).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
        }
    }
}
