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

        [TestMethod]
        public async Task Retrieving1Test()
        {
            var tag = "chamber_report_tag_1";
            var strDt = new DateTime(2022, 10, 31);
            var endDt = new DateTime(2022, 11, 30);
            TestDbContext.CompressedPoints.Add(new CompressedPoint(tag, strDt.AddDays(1), 10));
            TestDbContext.CompressedPoints.Add(new CompressedPoint(tag, strDt.AddDays(2), 20));
            TestDbContext.CompressedPoints.Add(new CompressedPoint(tag, strDt.AddDays(3), 30));
            await TestDbContext.SaveChangesAsync();

            var minValue = new OutputParameter<double?>();
            var maxValue = new OutputParameter<double?>();
            var avrgValue = new OutputParameter<double?>();
            var stdDevValue = new OutputParameter<double?>();
            var result = await TestDbContext.Procedures.spGetStatsAsync(tag, strDt, endDt
                , minValue, maxValue, avrgValue, stdDevValue);
            Assert.AreEqual(10,minValue.Value);
            Assert.AreEqual(30,maxValue.Value);
            Assert.AreEqual(20, avrgValue.Value);
            Assert.IsNotNull(stdDevValue.Value);
        }
    }
}
