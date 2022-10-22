using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class CollectionPointsPaceLogCalc
    {
        public int PaceId { get; set; }
        public int TagId { get; set; }
        public string? StageName { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }
        public DateTime StepStartTime { get; set; }
        public DateTime? StepEndTime { get; set; }
    }
}
