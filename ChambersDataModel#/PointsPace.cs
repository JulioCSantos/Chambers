using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class PointsPace
    {
        public PointsPace()
        {
            PointsPacesLogs = new HashSet<PointsPacesLog>();
        }

        public int PaceId { get; set; }
        public int TagId { get; set; }
        public DateTime NextStepStartTime { get; set; }
        public int StepSizeDays { get; set; }
        public DateTime? NestStepEndTime { get; set; }

        public virtual Tag Tag { get; set; } = null!;
        public virtual ICollection<PointsPacesLog> PointsPacesLogs { get; set; }
    }
}
