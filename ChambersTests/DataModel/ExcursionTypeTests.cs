using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{

    [TestClass]
    public class ExcursionTypeTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(ExcursionTypeTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void GetAllTypes()
        {
            var excTypesAll = TestDbContext.ExcursionTypes;
            Assert.AreEqual(4, excTypesAll.Count());

        }

        [TestMethod]
        public void ValidateEnums() {
            var excTypesAll = TestDbContext.ExcursionTypes;
            Assert.IsNotNull(excTypesAll.Where(ex => ex.ExcType == ExcursionType.ExcEnum.RampIn));
            Assert.IsNotNull(excTypesAll.Where(ex => ex.ExcType == ExcursionType.ExcEnum.HiExcursion));
            Assert.IsNotNull(excTypesAll.Where(ex => ex.ExcType == ExcursionType.ExcEnum.LowExcursion));
            Assert.IsNotNull(excTypesAll.Where(ex => ex.ExcType == ExcursionType.ExcEnum.RampOut));

        }
    }
}
