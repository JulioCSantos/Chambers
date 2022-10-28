using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class Stage
    {
        public Stage(Tag tag, double? minValue = null, double? maxValue = null) : this() {
            Tag = tag;
            StageName = tag.TagName;
            StageSetValues(minValue, maxValue);
        }

        public Stage(string stageName, double? minValue = null, double? maxValue = null) : this() {
            StageName = stageName;
            Tag = new Tag(stageName);
            StageSetValues(minValue, maxValue);
        }
        public void StageSetValues( double? minValue, double? maxValue) {
            if (minValue != null) { MinValue = (double)minValue; }
            if (maxValue != null) { MaxValue = (double)maxValue; }
        }
    }
}
