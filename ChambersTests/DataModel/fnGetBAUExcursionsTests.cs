using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    //TODO: Complete fnGetBAUExcursionsTests tests
    // ReSharper disable once InconsistentNaming
    public class fnGetBAUExcursionsTests
    {
        [TestMethod]
        public void CreatedTest()
        {
            var result = TestDbContext.fnGetBAUExcursions
                (DateTime.Today.Subtract(TimeSpan.FromDays(30)), DateTime.Today, "", 10 * 60,0).ToList();
            Assert.IsNotNull(result);
            
        }
    }
}
