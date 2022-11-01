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

        public string ExcursionType1 { get; set; } = null!;
        public string Predicate { get; set; } = null!;
        public string? ExcursionDescription { get; set; }

        public virtual ICollection<ExcursionPoint> ExcursionPoints { get; set; }
    }
}
