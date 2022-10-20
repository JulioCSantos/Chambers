using ChambersDataModel;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class CollectionPointsPaceTests
    {
        private static ChambersDbContext? _context;

        public static ChambersDbContext Context {
            get {
                if (_context != null) { return _context; }

                var contextOptions = new DbContextOptionsBuilder<ChambersDbContext>()
                    .UseInMemoryDatabase(nameof(TagTests)).Options;
                _context = new ChambersDbContext(contextOptions);

                return _context;
            }
        }

        [TestMethod]
        public void InstantiationTest()
        {
            var target = new CollectionPointsPace();
            Assert.IsNotNull(target);
            
        }

        [TestMethod]
        public void InsertTest() {
            PreTest();
            var target = new CollectionPointsPace();
            Assert.IsNotNull(target);

        }

        public void PreTest()
        {
            
        }
    }
}
