﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class StagesLimitsAndDatesChanged
    {
        public int TagId { get; set; }
        public string TagName { get; set; }
        public DateTime? DecommissionedDate { get; set; }
        public int StageDateId { get; set; }
        public string StageName { get; set; }
        public double? MinThreshold { get; set; }
        public double? MaxThreshold { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public double? TimeStep { get; set; }
        public int StageId { get; set; }
        public int? ThresholdDuration { get; set; }
        public double? SetPoint { get; set; }
        public DateTime? StageDeprecatedDate { get; set; }
        public DateTime? StageDateDeprecatedDate { get; set; }
        public DateTime? ProductionDate { get; set; }
        public DateTime? DeprecatedDate { get; set; }
        public bool? IsDeprecated { get; set; }
    }
}