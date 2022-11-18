using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class GetScheduleDatesTests
    {
        [TestMethod]
        public void WeekMonthTest()
        {
            DateTime forDate = new(2022, 11, 03);
            DateTime startDate = new(2022, 10, 02);
            var result =
                TestDbContext.fnGetScheduleDates(forDate, startDate, 1, "week", 1, "month").FirstOrDefault();
            Assert.IsNotNull(result);
            Assert.AreEqual(new DateTime(2022,11,02), result?.StartDate);
            Assert.AreEqual(new DateTime(2022,11,09), result?.EndDate);
        }

        [TestMethod]
        public void OutOfCoverageTest() {
            DateTime forDate = new(2022, 11, 10);
            DateTime startDate = new(2022, 10, 02);
            var result =
                TestDbContext.fnGetScheduleDates(forDate, startDate, 1, "week", 1, "month").FirstOrDefault();
            Assert.IsNotNull(result);
            Assert.IsNull(result?.StartDate);
            Assert.IsNull(result?.EndDate);
        }
    }
}
