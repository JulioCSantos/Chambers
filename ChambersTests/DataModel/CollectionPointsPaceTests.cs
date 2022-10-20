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

        public static int Id { get; private set; } = 1000;

        public static Func<int> NextId = () => { Id++; return Id; };

        public static Lazy<Tag> InsertPointPace = new Lazy<Tag>(
            () => new Tag() { TagId = NextId(), TagName = nameof(InsertPointPace) }
        );

        public static Lazy<CollectionPointsPace> InsertPointsPace = new (
            () => new CollectionPointsPace() { TagId = InsertPointPace.Value.TagId, }
        );


        [TestMethod]
        public void InstantiationTest() {
            var target = new CollectionPointsPace();
            Assert.IsNotNull(target);
        }

        [TestMethod]
        public void InsertPointsPaceTest() {
            PreTest();
            var target = new CollectionPointsPace();
            Assert.IsNotNull(target);

        }

        public void PreTest()
        {
            
        }
    }
}
