using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class fnGetOverlappingDatesTests
    {
        [TestMethod]
        public void IntersectionTest1() {
            DateTime d20220101 = new (2022, 01, 01);
            DateTime d20220131 = new (2022, 01, 31);
            DateTime d20220102 = new (2022, 01, 02);
            DateTime d20220103 = new (2022, 01, 03);
            var result = 
                TestDbContext.fnGetOverlappingDates(d20220101, d20220131, d20220102, d20220103);
            Assert.IsNotNull(result);
            Assert.AreEqual(d20220102, result.First().StartDate);
            Assert.AreEqual(d20220103, result.First().EndDate);
        }

        [TestMethod]
        public void IntersectionTest2() {
            DateTime d20220101 = new(2022, 01, 01);
            DateTime d20220131 = new(2022, 01, 31);
            DateTime d20220102 = new(2022, 01, 02);
            DateTime d20220203 = new(2022, 02, 03);
            var result =
                TestDbContext.fnGetOverlappingDates(d20220101, d20220131, d20220102, d20220203);
            Assert.IsNotNull(result);
            Assert.AreEqual(d20220102, result.First().StartDate);
            Assert.AreEqual(d20220131, result.First().EndDate);
        }

        [TestMethod]
        public void IntersectionTest3() {
            DateTime d20220101 = new(2022, 01, 01);
            DateTime d20220131 = new(2022, 01, 31);
            DateTime d20220201 = new(2022, 02, 01);
            DateTime d20220202 = new(2022, 02, 02);
            var result =
                TestDbContext.fnGetOverlappingDates(d20220101, d20220131, d20220201, d20220202);
            Assert.IsTrue(result.Any());
            Assert.IsNull(result.First().StartDate);
            Assert.IsNull(result.First().EndDate);
        }

    }
}
