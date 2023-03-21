using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersDataModel.Entities
{
    public partial class Interpolated
    {
        public Interpolated() { }
        public Interpolated(string tag, DateTime time, float value) {
            Tag = tag;
            Time = time;
            Value = value;
        }
    }
}
