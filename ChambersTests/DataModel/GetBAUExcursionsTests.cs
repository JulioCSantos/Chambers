using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class GetBAUExcursionsTests
    {
        [TestMethod]
        public void GetExcursions1Test()
        {
            //TODO: Complete test GetBAUExcursions
            //var tagIds = TestDbContext.ExcursionPoints.Select(ep => ep.TagId).Distinct().ToList();
            var tagIds = TestDbContext.ExcursionPoints.Select(ep => ep.TagId).ToList();
        }
    }
}
