using ChambersDataModel;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class PointsPaceTests
    {
        public static Stage NewPointsPace(string stageName) {
            var tag = TagTests.NewTag(stageName);
            TestDbContext.Tags.Add(tag);
            var stage = new Stage() { TagId = tag.TagId, StageName = stageName };
            return stage;
        }

        [TestMethod]
        public void InsertTest()
        {

        }

        [TestMethod]
        public void ReadTest() {
            var pointPace = TestDbContext.PointsPaces.FirstOrDefault();
            if (TestDbContext.DatabaseName == null) { Assert.IsNotNull(pointPace); }
            else { Assert.IsNull(pointPace);}
        }
    }
}
