using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once IdentifierTypo
    // ReSharper disable once InconsistentNaming
    public class fnGetInterp2Tests
    {
        [TestMethod]
        public void CommonReadingTest()
        {
            var result = TestDbContext.fnGetInterp2
                ("chamber_report_tag_1", new DateTime(2022, 10, 31), DateTime.Parse("2022-11-30"),
                TimeSpan.Parse("00:00:30"));
            Assert.IsNotNull(result);
        }
    }
}
