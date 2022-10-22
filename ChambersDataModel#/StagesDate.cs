using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class StagesDate
    {
        public StagesDate()
        {
            PointsPacesLogs = new HashSet<PointsPacesLog>();
        }

        public int StageDateId { get; set; }
        public int StageId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        public virtual Stage Stage { get; set; } = null!;
        public virtual ICollection<PointsPacesLog> PointsPacesLogs { get; set; }
    }
}
