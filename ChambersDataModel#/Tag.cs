using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class Tag
    {
        public Tag()
        {
            PointsPaces = new HashSet<PointsPace>();
            Stages = new HashSet<Stage>();
        }

        public int TagId { get; set; }
        public string? TagName { get; set; }

        public virtual ICollection<PointsPace> PointsPaces { get; set; }
        public virtual ICollection<Stage> Stages { get; set; }
    }
}
