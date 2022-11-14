using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests
{
    [TestClass]
    public class Initialize
    {
        [AssemblyInitialize]
        public static void AssemblyInitialize(TestContext context) { }

        [AssemblyCleanup]
        public static void AssemblyCleanup() {
            Parallel.ForEach(BootStrapper.ChambersDictionary.Values
                , db => { if (db.IsPreservedForTest == false) {db.Database.EnsureDeleted();} });
        }
    }
}
