﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class PointsPace
    {
        public int PaceId { get; set; }
        public int StageDateId { get; set; }
        public DateTime NextStepStartDate { get; set; }
        public int StepSizeDays { get; set; }
        public DateTime? NextStepEndDate { get; set; }

        public virtual StagesDate StageDate { get; set; }
    }
}