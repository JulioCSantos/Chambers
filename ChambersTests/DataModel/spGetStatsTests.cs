using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class spGetStatsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(spGetStatsTests) + "_" + name;
            return newName;
        }
        public async void EmptyTest()
        {
            var result = await TestDbContext.Procedures.spGetStatsAsync(null, null);
            Assert.AreEqual(0, result.Count);
        }
    }
}
