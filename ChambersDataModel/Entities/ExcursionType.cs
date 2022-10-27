using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class ExcursionType
    {
        public ExcursionType()
        {
            ExcursionPoints = new HashSet<ExcursionPoint>();
        }

        public int ExcursionType1 { get; set; }
        public string? ExcursionDescription { get; set; }

        public virtual ICollection<ExcursionPoint> ExcursionPoints { get; set; }
    }
}
