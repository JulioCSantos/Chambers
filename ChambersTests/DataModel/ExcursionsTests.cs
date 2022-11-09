using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel
{
    [TestClass]
    public class ExcursionsTests
    {
        private static string NewName([CallerMemberName] string? name = null) {
            var newName = nameof(ExcursionsTests) + "_" + name;
            return newName;
        }

        [TestMethod]
        public void RampInTest() {
            var name = NewName();
            var tag = new Tag(name + "_T1");
            var excPoint = new ExcursionPoint() { ExcNbr = 1, ExcType = ExcursionType.ExcEnum.RampIn
                , TagId = tag.TagId, Value = 110, ValueDate = new DateTime(2022,02,01), TagName = tag.TagName };
            TestDbContext.ExcursionPoints.Add(excPoint);
            var count = TestDbContext.SaveChanges();
            Assert.AreEqual(1, count);
            Assert.AreEqual(1, TestDbContext.ExcursionPoints.Count(ep => ep.ExcNbr == excPoint.ExcNbr));
            var results = TestDbContext.Excursions.FirstOrDefault(ex => ex.RampInPointNbr == excPoint.PointNbr);
            Assert.AreEqual(excPoint.PointNbr, results?.RampInPointNbr);
            Assert.AreEqual(null, results?.RampOutPointNbr);
        }

        [TestMethod]
        public void RampOutTest() {
            var name = NewName();
            var tag = new Tag(name + "_T2");
            var excPoint = new ExcursionPoint() {
                ExcNbr = 2, ExcType = ExcursionType.ExcEnum.RampOut
                , TagId = tag.TagId, Value = 120, ValueDate = new DateTime(2022, 02, 02), TagName = tag.TagName
            };
            TestDbContext.ExcursionPoints.Add(excPoint);
            var count = TestDbContext.SaveChanges();
            Assert.AreEqual(1, count);
            Assert.AreEqual(1, TestDbContext.ExcursionPoints.Count(ep => ep.ExcNbr == excPoint.ExcNbr));
            var results = TestDbContext.Excursions.FirstOrDefault(ex => ex.RampOutPointNbr == excPoint.PointNbr);
            Assert.AreEqual(excPoint.PointNbr, results?.RampOutPointNbr);
            Assert.AreEqual(null, results?.RampInPointNbr);
        }

                [TestMethod]
        public void OneHiExcursionTest() {
            var name = NewName();
            var tag = new Tag(name + "_T3");
            var excNbr = 3;
            var excPoint1 = new ExcursionPoint() { TagId = tag.TagId, ExcNbr = excNbr, TagName = tag.TagName
                , ExcType = ExcursionType.ExcEnum.RampIn, Value = 130, ValueDate = new DateTime(2022, 02, 01) };
            var excPoint2 = new ExcursionPoint() { TagId = tag.TagId, ExcNbr = excNbr, TagName = tag.TagName
                , ExcType = ExcursionType.ExcEnum.HiExcursion, Value = 210, ValueDate = new DateTime(2022, 02, 02) };
            var excPoint3= new ExcursionPoint() { TagId = tag.TagId, ExcNbr = excNbr, TagName = tag.TagName
                , ExcType = ExcursionType.ExcEnum.RampOut, Value = 140, ValueDate = new DateTime(2022, 03, 02) };
            TestDbContext.ExcursionPoints.Add(excPoint1);
            TestDbContext.ExcursionPoints.Add(excPoint2);
            TestDbContext.ExcursionPoints.Add(excPoint3);
            var count = TestDbContext.SaveChanges();
            Assert.AreEqual(3, count);
            var excursion = TestDbContext.Excursions.FirstOrDefault(ex => ex.TagId == tag.TagId);
            Assert.IsNotNull(excursion);
            Assert.AreEqual(excPoint1.PointNbr, excursion.RampInPointNbr);
            Assert.AreEqual(excPoint3.PointNbr, excursion.RampOutPointNbr);
        }

        [TestMethod]
        public void OneHiOneLowExcursion()
        {
            var name = NewName();

            // insert High-Excursion
            var hName = name + "_T4_Hi";
            var hTag = new Tag(hName);
            var hExcNbr = 3;
            var excPoint1 = new ExcursionPoint() { TagId = hTag.TagId, ExcNbr = hExcNbr, TagName = hTag.TagName
                , ExcType = ExcursionType.ExcEnum.RampIn, Value = 150, ValueDate = new DateTime(2022, 02, 01) };
            var excPoint2 = new ExcursionPoint() { TagId = hTag.TagId, ExcNbr = hExcNbr, TagName = hTag.TagName
                , ExcType = ExcursionType.ExcEnum.HiExcursion, Value = 220, ValueDate = new DateTime(2022, 02, 02) };
            var excPoint3 = new ExcursionPoint() { TagId = hTag.TagId, ExcNbr = hExcNbr, TagName = hTag.TagName
                , ExcType = ExcursionType.ExcEnum.RampOut, Value = 160, ValueDate = new DateTime(2022, 03, 02) };
            TestDbContext.ExcursionPoints.Add(excPoint1);
            TestDbContext.ExcursionPoints.Add(excPoint2);
            TestDbContext.ExcursionPoints.Add(excPoint3);
            var hCount = TestDbContext.SaveChanges();
            Assert.AreEqual(3, hCount);

            // insert Low-Excursion
            var lName = name + "_T4_Low";
            var lTag = new Tag(lName);
            var lExcNbr = 4;
            var excPoint4 = new ExcursionPoint() { TagId = lTag.TagId, ExcNbr = lExcNbr, TagName = lTag.TagName
                , ExcType = ExcursionType.ExcEnum.RampIn, Value = 170, ValueDate = new DateTime(2022, 02, 01) };
            var excPoint5 = new ExcursionPoint() { TagId = lTag.TagId, ExcNbr = lExcNbr, TagName = lTag.TagName
                , ExcType = ExcursionType.ExcEnum.LowExcursion, Value = 90, ValueDate = new DateTime(2022, 02, 02) };
            var excPoint6 = new ExcursionPoint() { TagId = lTag.TagId, ExcNbr = lExcNbr, TagName = lTag.TagName
                , ExcType = ExcursionType.ExcEnum.RampOut, Value = 180, ValueDate = new DateTime(2022, 03, 02) };
            TestDbContext.ExcursionPoints.Add(excPoint4);
            TestDbContext.ExcursionPoints.Add(excPoint5);
            TestDbContext.ExcursionPoints.Add(excPoint6);
            var count = TestDbContext.SaveChanges();
            Assert.AreEqual(3, count);

            var excursions = TestDbContext.Excursions.Where(ex => ex.TagName.StartsWith(name)).ToList();
            Assert.AreEqual(2,excursions.Count);
            Assert.AreNotEqual(excursions[0].RampInPointNbr, excursions[0].RampOutPointNbr);
            Assert.IsTrue(excursions[0].RampInDate <= excursions[0].RampOutDate);
            Assert.AreNotEqual(excursions[1].RampInPointNbr, excursions[1].RampOutPointNbr);
            Assert.IsTrue(excursions[1].RampInDate <= excursions[1].RampOutDate);
        }
    }
}
