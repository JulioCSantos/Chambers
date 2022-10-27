using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class PointsStespLogNextValue
    {
        public int StageDateId { get; set; }
        public int TagId { get; set; }
        public string? StageName { get; set; }
        public DateTime StageStartDate { get; set; }
        public DateTime? StageEndDate { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }
        public int PaceId { get; set; }
        public DateTime NextStepStartDate { get; set; }
        public DateTime? NextStepEndDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}
