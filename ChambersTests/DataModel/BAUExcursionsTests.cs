using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class BAUExcursionsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesLimitsAndDatesCoreTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void ReadingTest() {
            //TODO: complete BAUExcursionsTests 
            var viewResults = TestDbContext.Bauexcursions.ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(0, viewResults.Count);
        }
    }
}
