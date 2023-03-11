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
    public class BuildingsAreasUnitTests
    {

        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(BuildingsAreasUnitTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task ConfirmPopulatedTableTest()
        {
            var bauHasRecords = await TestDbContext.BuildingsAreasUnits.AnyAsync();
            Assert.IsTrue(bauHasRecords);
        }

        [TestMethod]
        public async Task CreateDuplicatedRecordTest() {
            var bauRec = await TestDbContext.BuildingsAreasUnits.FirstOrDefaultAsync();
            var prevCount = await TestDbContext.BuildingsAreasUnits.CountAsync();
            Assert.IsNotNull(bauRec);
            var newBauRec = (BuildingsAreasUnit)bauRec.ShallowCopy();
            newBauRec.LTagId *= 10;
            newBauRec.Tag = "_" + NewName();
            if (TestDbContext.BuildingsAreasUnits.Any(b => b.LTagId == newBauRec.LTagId) == true) {
                Assert.Inconclusive(); /* record already inserted */
            }
            TestDbContext.BuildingsAreasUnits.Add(newBauRec);
            await TestDbContext.SaveChangesAsync();
            var currCount = await TestDbContext.BuildingsAreasUnits.CountAsync();
            Assert.IsTrue(currCount > prevCount);
        }

        [TestMethod]
        public async Task CreateDuplicatedRecord2Test() {
            var bauRec = await TestDbContext.BuildingsAreasUnits
                .OrderByDescending(b => b.LTagId).FirstOrDefaultAsync();
            Assert.IsNotNull(bauRec);
            var prevCount = await TestDbContext.BuildingsAreasUnits.CountAsync();
            var newBauRec = bauRec.AddCopy(TestDbContext, bauRec.LTagId * 10, bauRec.Tag = "_" + NewName());
            if (TestDbContext.BuildingsAreasUnits.Any(b => b.LTagId == newBauRec.LTagId) == true) {
                Assert.Inconclusive(); /* record already inserted */
            }
            await TestDbContext.SaveChangesAsync();
            var currCount = await TestDbContext.BuildingsAreasUnits.CountAsync();
            Assert.IsTrue(currCount > prevCount);
        }
    }
}
