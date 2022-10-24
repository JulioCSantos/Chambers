using ChambersDataModel;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class PointsPaceTests
    {

        #region Context
        private static ChambersDbContext InMemoryContext = BootStrap.InMemoryDbcontext;
        private static ChambersDbContext Context = BootStrap.DbContext;
        #endregion Context

        public static Stage NewPointsPace(string stageName) {
            var tag = TagTests.NewTag(stageName);
            InMemoryContext.Tags.Add(tag);
            var stage = new Stage() { TagId = tag.TagId, StageName = stageName };
            return stage;
        }
        [TestMethod]
        public void InsertTest()
        {

        }

        [TestMethod]
        public void ReadTest() {
            var pointPace = Context.PointsPaces.FirstOrDefault();
            if (Context.DatabaseName == null) { Assert.IsNotNull(pointPace); }
            else { Assert.IsNull(pointPace);}
        }
    }
}
