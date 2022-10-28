using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class StagesDate
    {
        public StagesDate() { } //must have an empty constructor
        public int StageDateId { get; set; }
        public int StageId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }

        public virtual Stage Stage { get; set; } = null!;
    }
}
