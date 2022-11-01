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

        public string ExcType { get; set; } = null!;
        public string? Predicate { get; set; }
        public string? ExcDescription { get; set; }

        public virtual ICollection<ExcursionPoint> ExcursionPoints { get; set; }
    }
}
