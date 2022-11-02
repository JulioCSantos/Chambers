using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    //For step-in debug tests
    //EXECUTE  [dbo].[spGetCompressedPoints] 'T1', '2022-01-01', '2022-03-31', 100, 200

    [TestClass]
    public class SpGetCompressedPointsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(SpGetCompressedPointsTests) + "_" + name;
            return newName;
        }

        [TestInitialize]
        public void InitializeTests()
        {
            var dbContext = BootStrap.TestDbContext;
            dbContext.Truncate<CompressedPoint>();
            dbContext.SaveChanges();

        }

        [TestMethod]
        public async Task EmptyTableTest() {
            var dbContext = BootStrap.TestDbContext;
            var tag = NewName();

            await dbContext.SaveChangesAsync();
            var result = await dbContext.Procedures.spGetCompressedPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), 100, 200);

            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task MissingTagTest() {
            var dbContext = BootStrap.TestDbContext;
            var tag = NewName();
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 12), Value = 220 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 10), Value = 210 });

            await dbContext.SaveChangesAsync();
            var result = await dbContext.Procedures.spGetCompressedPointsAsync(
                "Wrong Tag", new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), 100, 200);

            Assert.AreEqual(0, result.Count);
        }

        [TestMethod]
        public async Task OutOfOrderTest()
        {
            var dbContext = BootStrap.TestDbContext;
            var tag = NewName();

            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 09), Value = 150 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 20), Value = 170 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 12), Value = 220 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 08), Value = 140 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 21), Value = 160 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 10), Value = 210 });
            await dbContext.SaveChangesAsync();
            var result = await dbContext.Procedures.spGetCompressedPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), 100, 200);

            Assert.AreEqual(4, result.Count);
            Assert.IsTrue(result.First().excType.StartsWith("RampIn"));
            Assert.IsTrue(result.Last().excType.StartsWith("RampOut"));
            Assert.AreEqual(2, result.Count(r => r.excType == "HiExcursion") );
        }

        [TestMethod]
        public async Task LowExcursionTest() {
            var dbContext = BootStrap.TestDbContext;
            var tag = NewName();

            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 08), Value = 150 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 09), Value = 110 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 10), Value = 50 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 12), Value = 60 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 20), Value = 120 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 21), Value = 130 });
            await dbContext.SaveChangesAsync();
            var result = await dbContext.Procedures.spGetCompressedPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), 100, 200);
            
            Assert.AreEqual(4, result.Count);
            Assert.IsTrue(result.First().excType.StartsWith("RampIn"));
            Assert.IsTrue(result.Last().excType.StartsWith("RampOut"));
            Assert.AreEqual(2, result.Count(r => r.excType == "LowExcursion"));
        }

        [TestMethod]
        public async Task TwoCyclesTest() {
            var dbContext = BootStrap.TestDbContext;
            var tag = NewName();

            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 08), Value = 140 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 09), Value = 150 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 10), Value = 210 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 12), Value = 220 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 20), Value = 170 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 01, 21), Value = 160 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 02, 08), Value = 141 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 02, 09), Value = 151 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 02, 10), Value = 211 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 02, 12), Value = 221 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 02, 20), Value = 171 });
            dbContext.CompressedPoints.Add(new CompressedPoint() { Tag = tag, Time = new DateTime(2022, 02, 21), Value = 161 });
            await dbContext.SaveChangesAsync();
            var result = await dbContext.Procedures.spGetCompressedPointsAsync(
                tag, new DateTime(2022, 01, 01), new DateTime(2022, 03, 31), 100, 200);
            
            Assert.AreEqual(8, result.Count);
            Assert.IsTrue(result.First().excType.StartsWith("RampIn"));
            Assert.IsTrue(result.Last().excType.StartsWith("RampOut"));
            Assert.AreEqual(4, result.Count(r => r.excType == "HiExcursion"));
        }

        [TestCleanup]
        public void CleanUpBetweenTests() {

        }
    } 
}
