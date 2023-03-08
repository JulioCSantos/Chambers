using System.Runtime.CompilerServices;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class StageDatesTests
    {
        //public static StagesDate NewStageDates(string stageName, DateTime? startDate = null, DateTime? endDate = null) {
        //    Stage stage = StagesTests.NewStageLimits(stageName);
        //    StagesDate stageDate = new() { Stage = stage };
        //    StagesDateSetDates(stageDate, startDate, endDate);

        //    return stageDate;
        //}

        //public static StagesDate NewStageDates(Tag tag, DateTime? startDate = null, DateTime? endDate = null) {
        //    Stage stage = new Stage(tag);
        //    StagesDate stageDate = new() { Stage = stage };
        //    StagesDateSetDates(stageDate, startDate, endDate);

        //    return stageDate;
        //}

        //public static void StagesDateSetDates(StagesDate stagesDate, DateTime? startDate, DateTime? endDate)
        //{
        //    if (startDate != null) { stagesDate.StartDate = (DateTime)startDate; }
        //    if (endDate != null) { stagesDate.EndDate = (DateTime)endDate; }
        //}


        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(StageDatesTests) + "_" + name;
            return newName;
        }


        [TestMethod]
        public void InsertStageDatesTest() {
            var name = NewName();
            var stage = new Stage(name, 20, 200);
            var stageDate = new StagesDate(stage, new DateTime(2022, 01, 01), new DateTime(2022, 12, 31));
            stageDate.Stage.SetValues(20, 200);
            TestDbContext.StagesDates.Add(stageDate);
            var savedCount = TestDbContext.SaveChanges();
            Assert.IsTrue(TestDbContext.StagesDates.Any());
            Assert.AreEqual(3, savedCount);
            Assert.IsNotNull(TestDbContext.StagesDates.First(sd => sd.Stage.StageName == name));
        }

        [TestMethod]
        public void ReadStagesLimitsAndDatesViewTest() {
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();
            var viewResults = TestDbContext.StagesLimitsAndDates
            .Where(std => std.StageName == name).ToList();
            Assert.IsNotNull(viewResults);
            Assert.AreEqual(1, viewResults.Count);
        }

        [TestMethod]
        public void SpGetStagesLimitsAndDatesTest() {
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();

            var tagId = stageDate.Stage.TagId;
            //var soughtDate = "'2022-02-15'";
            //var result = TestDbContext.StagesLimitsAndDates
            //    .FromSqlRaw($"EXECUTE [dbo].[spGetStagesLimitsAndDates] {tagId}, {soughtDate}");
            //Assert.IsNotNull(result);
            //Assert.AreEqual(tagId, result.AsEnumerable().FirstOrDefault()?.TagId);

        }

        [TestMethod]
        public void SpGetStagesLimitsAndDatesPowerToolTest() {
            var name = NewName();
            var stageDate = new StagesDate(name, new DateTime(2022, 02, 01), new DateTime(2022, 02, 28));
            stageDate.Stage.SetValues(30, 300);
            TestDbContext.StagesDates.Add(stageDate);
            TestDbContext.SaveChanges();

            var tagId = stageDate.Stage.TagId;
            var soughtDate = new DateTime(2022,02,15);

            var result = TestDbContext.StagesLimitsAndDates
                .Where(sld => sld.TagId == tagId);

            //var result = await TestDbContext.Procedures
            //    .spGetStagesLimitsAndDatesAsync(tagId, soughtDate);

            Assert.IsNotNull(result);
            Assert.AreEqual(1, result.Count());
            Assert.AreEqual(stageDate.StartDate, result.First().StartDate);
            Assert.AreEqual(stageDate.EndDate, result.First().EndDate);

        }
    }
}
