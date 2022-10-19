using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class Tag
    {
        public Tag()
        {
            CollectionPointsPaces = new HashSet<CollectionPointsPace>();
            Stages = new HashSet<Stage>();
        }

        public int TagId { get; set; }
        public string? TagName { get; set; }

        public virtual ICollection<CollectionPointsPace> CollectionPointsPaces { get; set; }
        public virtual ICollection<Stage> Stages { get; set; }
    }
}
