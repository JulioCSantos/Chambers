using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel.Extensions
{
    [TestClass]
    public class ExcursionPointsTests
    {


        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(ExcursionPointsTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public async Task DurationTests1() {
            var tag = NewName();
            var excPoint = new ExcursionPoint() {
                TagName = tag, TagExcNbr = 1
                , FirstExcDate = new DateTime(2022, 01, 01, 0, 0, 0), LastExcDate = new DateTime(2022, 01, 01, 0, 1, 30)
            };
            TestDbContext.ExcursionPoints.Add(excPoint);
            var result = await TestDbContext.SaveChangesAsync();
            Assert.IsTrue(excPoint.Duration > 0);
            //var duration = excPoint.LastExcDate
            Assert.AreEqual(90, excPoint.Duration);
        }
    }
}
