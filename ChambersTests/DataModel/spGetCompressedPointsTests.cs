using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class SpGetCompressedPointsTests
    {
        [TestMethod]
        public async Task GetCompressedPointTest1()
        {
            List<spGetCompressedPointsResult> result;
            try
            {
                var entityType = TestDbContext.Model.FindEntityType(typeof(CompressedPoint));
                Debug.Assert(entityType != null, nameof(entityType) + " != null");
                //var schema = entityType.GetSchema();
                var tableName = entityType.GetTableName();
                var cmd = $"Truncate Table [dbo].[{tableName}]";
                await TestDbContext.Database.ExecuteSqlRawAsync(cmd);
                await TestDbContext.SaveChangesAsync();

                TestDbContext.CompressedPoints.Add(new CompressedPoint() { Tag = "T1", Time = new DateTime(2022, 01, 09), Value = 150 });
                TestDbContext.CompressedPoints.Add(new CompressedPoint() { Tag = "T1", Time = new DateTime(2022, 01, 20), Value = 170 });
                TestDbContext.CompressedPoints.Add(new CompressedPoint() { Tag = "T1", Time = new DateTime(2022, 01, 12), Value = 220 });
                TestDbContext.CompressedPoints.Add(new CompressedPoint() { Tag = "T1", Time = new DateTime(2022, 01, 08), Value = 140 });
                TestDbContext.CompressedPoints.Add(new CompressedPoint() { Tag = "T1", Time = new DateTime(2022, 01, 21), Value = 160 });
                TestDbContext.CompressedPoints.Add(new CompressedPoint() { Tag = "T1", Time = new DateTime(2022, 01, 10), Value = 210 });
                await TestDbContext.SaveChangesAsync();
                result = await TestDbContext.Procedures.spGetCompressedPointsAsync(
                    "T1", new DateTime(2022, 01, 01), new DateTime(2022, 01, 30), 100, 200);
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }
;
            Assert.AreEqual(4, result.Count);
            Assert.IsTrue(result.First().excType.StartsWith("RampIn"));
            Assert.IsTrue(result.Last().excType.StartsWith("RampOut"));
            Assert.AreEqual(2, result.Where(r => r.excType == "HiExcursion") );
        }
    } 
}
