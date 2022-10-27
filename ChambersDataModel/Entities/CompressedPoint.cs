using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class CompressedPoint
    {
        public string Tag { get; set; } = null!;
        public DateTime Time { get; set; }
        public double Value { get; set; }
    }
}
