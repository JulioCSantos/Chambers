using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ChambersDataModel;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class ChambersDbContextTests
    {
        [TestMethod]
        public void InstantiationTest() {
            var target = new ChambersDbContext();
            Assert.IsNotNull(target);
        }

        [TestMethod]
        public void InMemoryInstantiationTest() {
            var contextOptions = new DbContextOptionsBuilder<ChambersDbContext>()
                .UseInMemoryDatabase(nameof(InMemoryInstantiationTest)).Options;
            var target = new ChambersDbContext(contextOptions);
            Assert.IsNotNull(target);
        }

        [TestMethod]
        public void ContextFactoryTest()
        {
            Assert.IsNotNull(BootStrap.DbContext);
            Assert.IsNotNull(BootStrap.InMemoryDbcontext);
        }

        [TestMethod]
        public void NamedContextTest()
        {
            var context = BootStrap.GetNamedContext(nameof(NamedContextTest));
            Assert.IsNotNull(context);
            Assert.AreEqual(context, BootStrap.GetNamedContext(nameof(NamedContextTest)));
        }
    }
}
