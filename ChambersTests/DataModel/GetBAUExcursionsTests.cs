using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    //TODO: Complete test GetBAUExcursionsTests
    // ReSharper disable once InconsistentNaming
    public class GetBAUExcursionsTests
    {
        [TestMethod]
        public void GetExcursions1Test()
        {
            //var tagIds = TestDbContext.ExcursionPoints.Select(ep => ep.TagId).Distinct().ToList();
            var tagIds = TestDbContext.ExcursionPoints.Select(ep => ep.TagId).ToList();
        }
    }
}
