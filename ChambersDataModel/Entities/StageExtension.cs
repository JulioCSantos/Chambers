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
            SetValues(minThreshold, maxThreshold);
        }

        public Stage(string stageName, double? minThreshold = null, double? maxThreshold = null) : this() {
            StageName = stageName;
            Tag = new Tag(stageName);
            SetValues(minThreshold, maxThreshold);
        }
        public void SetValues( double? minValue, double? maxValue) {
            if (minValue != null) { MinThreshold = (double)minValue; }
            if (maxValue != null) { MaxThreshold = (double)maxValue; }
        }
    }
}
