using System.Diagnostics;
using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class DefaultPointsPaceViewTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(DefaultPointsPaceViewTests) + "_" + name;
            return newName;
        }

        private static readonly Object syncObj = new ();


        [TestMethod]
        public void GetOneRowTest() {
            
            Monitor.Enter(syncObj);
            try {
                var name = NewName();
                var stage = new Stage(name, 20, 200);
                var stageDate = new StagesDate(stage, new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
                stageDate.Stage.SetValues(20, 200);
                TestDbContext.StagesDates.Add(stageDate);
                var savedCount = TestDbContext.SaveChanges();
                var viewResults = TestDbContext.DefaultPointsPaces.ToList();
                TestDbContext.Remove(stageDate);
                TestDbContext.Remove(stage);
                TestDbContext.SaveChanges();
                Assert.IsNotNull(viewResults);
                Assert.AreEqual(1, viewResults.Count);
            }
            catch (Exception ) { Assert.Fail(); }
            finally { Monitor.Exit(syncObj); }

        }

        [TestMethod]
        public void DoNotGetNewlyInsertedRowTest() {
            Monitor.Enter(syncObj);
            try
            {
                var name = NewName();
                var stage = new Stage(name, 20, 200);
                var stageDate = new StagesDate(stage, new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
                stageDate.Stage.SetValues(20, 200);
                TestDbContext.StagesDates.Add(stageDate);
                var savedCount = TestDbContext.SaveChanges();
                var newRow = TestDbContext.DefaultPointsPaces.First();
                // insert row
                Debug.Assert(newRow.NextStepStartDate != null, "newRow.NextStepStartDate != null");
                var pointPace = new PointsPace()
                    { NextStepStartDate = (DateTime)newRow.NextStepStartDate, StageDate = stageDate};
                TestDbContext.PointsPaces.Add(pointPace);
                TestDbContext.SaveChanges();
                // try again. It should get an empty list
                var viewResults = TestDbContext.DefaultPointsPaces.ToList();
                TestDbContext.Remove(pointPace);
                TestDbContext.Remove(stageDate);
                TestDbContext.Remove(stage);
                TestDbContext.SaveChanges();
                Assert.IsNotNull(viewResults);
                Assert.AreEqual(0, viewResults.Count);
            }
            catch (Exception ) { Assert.Fail(); }
            finally { Monitor.Exit(syncObj); }

        }

        public void SyncMethods()
        {
        }
    }
}
