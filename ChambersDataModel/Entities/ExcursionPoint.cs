using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class ExcursionPoint
    {
        public int PointId { get; set; }
        public DateTime ValueDate { get; set; }
        public double Value { get; set; }
        public int TagId { get; set; }
        public int ExcursionType { get; set; }
        public int StepLogId { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }

        public virtual ExcursionType ExcursionTypeNavigation { get; set; } = null!;
        public virtual PointsStepsLog StepLog { get; set; } = null!;
    }
}
