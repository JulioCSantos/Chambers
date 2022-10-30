using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class PointsStepsLog
    {
        public PointsStepsLog()
        {
            ExcursionPoints = new HashSet<ExcursionPoint>();
        }

        public int StepLogId { get; set; }
        public int StageDateId { get; set; }
        public int TagId { get; set; }
        public string StageName { get; set; } = null!;
        public DateTime StageStartDate { get; set; }
        public DateTime? StageEndDate { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }
        public int PaceId { get; set; }
        public DateTime PaceStartDate { get; set; }
        public DateTime PaceEndDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public string TagName { get; set; } = null!;

        public virtual ICollection<ExcursionPoint> ExcursionPoints { get; set; }
    }
}
