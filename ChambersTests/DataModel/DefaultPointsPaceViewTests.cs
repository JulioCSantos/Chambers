using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class DefaultPointsPaceViewTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(DefaultPointsPaceViewTests) + "_" + name;
            return newName;
        }

        private readonly CountdownEvent syncMethods1And2 = new (1);

        [TestMethod]
        public void GetOneRowTest()
        {
            var name = NewName();
            var stage = new Stage(name, 20, 200);
            var stageDate = new StagesDate(stage, new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            stageDate.Stage.StageSetValues(20, 200);
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            var viewResults = TestDbContext.DefaultPointsPaces.ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
            syncMethods1And2.Signal(1);
        }

        [TestMethod]
        public void DoNotGetNewlyInsertedRowTest() {

            syncMethods1And2.Wait(); // will return when cde count reaches 0
            var name = NewName();
            var stage = new Stage(name, 20, 200);
            var stageDate = new StagesDate(stage, new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            stageDate.Stage.StageSetValues(20, 200);
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            var newRow = TestDbContext.DefaultPointsPaces.First();
            // insert row
            Debug.Assert(newRow.NextStepStartDate != null, "newRow.NextStepStartDate != null");
            var pointPace = new PointsPace() { NextStepStartDate = (DateTime)newRow.NextStepStartDate, TagId = newRow.TagId };
            TestDbContext.PointsPaces.Add(pointPace);
            TestDbContext.SaveChanges();
            // try again. It should get an empty list
            var viewResults = TestDbContext.DefaultPointsPaces.ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(0, viewResults.Count);
        }
    }
}
