using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class CollectionPointsPaceLog
    {
        public CollectionPointsPaceLog()
        {
            ExcursionPoints = new HashSet<ExcursionPoint>();
        }

        public int PaceLogId { get; set; }
        public int PaceId { get; set; }
        public int StageDatesId { get; set; }
        public DateTime StepStartTime { get; set; }
        public DateTime StepEndTime { get; set; }

        public virtual PointsPace Pace { get; set; } = null!;
        public virtual StagesDate StageDates { get; set; } = null!;
        public virtual ICollection<ExcursionPoint> ExcursionPoints { get; set; }
    }
}
