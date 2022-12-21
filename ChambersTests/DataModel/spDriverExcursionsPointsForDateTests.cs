using System;
using System.Collections.Generic;
using System.Linq;
using System.Resources;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class spDriverExcursionsPointsForDateTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(spDriverExcursionsPointsForDateTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task EmptyTest() {
            //var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
            //    ForDate:new DateTime(2222,02,22),, StageDateId:-1, TagName:NewName());
           OutputParameter<int> outputParm = new OutputParameter<int>();
           var result = await TestDbContext.Procedures.spDriverExcursionsPointsForDateAsync(
               ForDate: new DateTime(2222, 1, 22), StageDateId: -1, TagName: "");
            Assert.AreEqual(0, result.Count);
        }
    }
}
