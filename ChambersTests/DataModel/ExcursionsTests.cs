using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    public class ExcursionsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(ExcursionsTests) + "_" + name;
            return newName;
        }

        public void FullExcursionTest()
        {
            
        }
    }
}
