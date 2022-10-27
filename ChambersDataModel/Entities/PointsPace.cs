﻿using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class PointsPace
    {
        public int PaceId { get; set; }
        public int TagId { get; set; }
        public DateTime NextStepStartDate { get; set; }
        public int StepSizeDays { get; set; }
        public DateTime? NextStepEndDate { get; set; }

        public virtual Tag Tag { get; set; } = null!;
    }
}