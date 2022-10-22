using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class CompValue
    {
        public string Tag { get; set; } = null!;
        public DateTime Time { get; set; }
        public double Value { get; set; }
    }
}
