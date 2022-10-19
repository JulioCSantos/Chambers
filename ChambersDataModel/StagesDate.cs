using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class StagesDate
    {
        public StagesDate()
        {
            CollectionPointsPaceLogs = new HashSet<CollectionPointsPaceLog>();
        }

        public int StageDateId { get; set; }
        public int StageId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        public virtual Stage Stage { get; set; } = null!;
        public virtual ICollection<CollectionPointsPaceLog> CollectionPointsPaceLogs { get; set; }
    }
}
