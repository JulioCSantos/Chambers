using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class spGetStatsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(spGetStatsTests) + "_" + name;
            return newName;
        }
        [TestMethod]
        public async Task EmptyTest()
        {
            var minValue = new OutputParameter<double?>();
            var maxValue = new OutputParameter<double?>();
            var avrgValue = new OutputParameter<double?>();
            var stdDevValue = new OutputParameter<double?>();
            var result = await TestDbContext.Procedures.spGetStatsAsync("", null, null
                , minValue, maxValue, avrgValue, stdDevValue);
            Assert.AreEqual(-1, result);
            Assert.IsNull(minValue.Value);
        }
    }
}
