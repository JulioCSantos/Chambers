using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChambersDataModel
{
    [Table("PointsPaces")]
    public partial class CollectionPointsPace
    {
        public CollectionPointsPace()
        {
            CollectionPointsPaceLogs = new HashSet<CollectionPointsPaceLog>();
        }

        public int PaceId { get; set; }
        public int TagId { get; set; }
        public DateTime NextStepStartTime { get; set; }
        public int StepSizeDays { get; set; }
        public DateTime? NestStepEndTime { get; set; }

        public virtual Tag Tag { get; set; } = null!;
        public virtual ICollection<CollectionPointsPaceLog> CollectionPointsPaceLogs { get; set; }
    }
}
