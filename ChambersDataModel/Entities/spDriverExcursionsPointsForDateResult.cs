﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChambersDataModel.Entities
{
    public partial class spDriverExcursionsPointsForDateResult
    {
        public int RowID { get; set; }
        public int? CycleId { get; set; }
        public int? TagId { get; set; }
        public string TagName { get; set; }
        public int? TagExcNbr { get; set; }
        public int? StepLogId { get; set; }
        public int? StageDateId { get; set; }
        public DateTime? RampInDate { get; set; }
        public double? RampInValue { get; set; }
        public DateTime? FirstExcDate { get; set; }
        public double? FirstExcValue { get; set; }
        public DateTime? LastExcDate { get; set; }
        public double? LastExcValue { get; set; }
        public DateTime? RampOutDate { get; set; }
        public double? RampOutValue { get; set; }
        public int? HiPointsCt { get; set; }
        public int? LowPointsCt { get; set; }
        public double? MinThreshold { get; set; }
        public double? MaxThreshold { get; set; }
        public double? MinValue { get; set; }
        public double? MaxValue { get; set; }
        public double? AvergValue { get; set; }
        public double? StdDevValue { get; set; }
        public DateTime? DeprecatedDate { get; set; }
        public int? ThresholdDuration { get; set; }
        public double? SetPoint { get; set; }
    }
}
