using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class StagesLimitsAndDate
    {
        public int StageDateId { get; set; }
        public int TagId { get; set; }
        public string? StageName { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
