using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class Stage
    {
        public Stage(Tag tag, double? minThreshold = null, double? maxThreshold = null) : this() {
            Tag = tag;
            StageName = tag.TagName;
            SetThresholds(minThreshold, maxThreshold);
        }
        public Stage(Tag tag, DateTime productionDate, double? minThreshold = null, double? maxThreshold = null) : this(tag, minThreshold, maxThreshold) {
            ProductionDate = productionDate;
        }

        public Stage(string stageName, double? minThreshold = null, double? maxThreshold = null) : this() {
            StageName = stageName;
            Tag = new Tag(stageName);
            SetThresholds(minThreshold, maxThreshold);
        }
        public void SetThresholds( double? minValue, double? maxValue) {
            if (minValue != null) { MinThreshold = (double)minValue; }
            if (maxValue != null) { MaxThreshold = (double)maxValue; }
        }
    }
}
