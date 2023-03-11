using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel.Extensions
{
    public static class BuildingsAreasUnitExtended
    {
        public static BuildingsAreasUnit AddCopy(this BuildingsAreasUnit bauRec, ChambersDbContext dbContext
            , int tagId, string tagName) {
            var newBauRec = (BuildingsAreasUnit)bauRec.ShallowCopy();
            newBauRec.LTagId = tagId;
            newBauRec.Tag = tagName;
            dbContext.BuildingsAreasUnits.Add(newBauRec);
            return newBauRec;
        }
    }
}
