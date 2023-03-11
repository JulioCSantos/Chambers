using Microsoft.EntityFrameworkCore;
﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    // ReSharper disable once InconsistentNaming
    public class BAUExcursionsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StagesLimitsAndDatesCoreTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void ReadingTest() {
            //TODO: complete BAUExcursionsTests 
            var viewResults = TestDbContext.Bauexcursions.ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(0, viewResults.Count);
        }
    }
}
