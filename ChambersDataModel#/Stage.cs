using System;
using System.Collections.Generic;

namespace ChambersDataModel
{
    public partial class Stage
    {
        public Stage()
        {
            StagesDates = new HashSet<StagesDate>();
        }

        public int StageId { get; set; }
        public int TagId { get; set; }
        public string? StageName { get; set; }
        public double MinValue { get; set; }
        public double MaxValue { get; set; }

        public virtual Tag Tag { get; set; } = null!;
        public virtual ICollection<StagesDate> StagesDates { get; set; }
    }
}
