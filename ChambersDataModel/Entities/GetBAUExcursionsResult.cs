﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChambersDataModel.Entities
{
    public partial class GetBAUExcursionsResult
    {
        public string Building { get; set; }
        public int lAreaID { get; set; }
        public int lUnitID { get; set; }
        public string Area { get; set; }
        public string Unit { get; set; }
        public int? TagId { get; set; }
        public string TagName { get; set; }
        public int TagExcNbr { get; set; }
        public int? StepLogId { get; set; }
        public DateTime? RampInDate { get; set; }
        public double? RampInValue { get; set; }
        public DateTime? FirstExcDate { get; set; }
        public double? FirstExcValue { get; set; }
        public DateTime? LastExcDate { get; set; }
        public double? LastExcValue { get; set; }
        public DateTime? RampOutDate { get; set; }
        public double? RampOutValue { get; set; }
        public long? HiPointsCt { get; set; }
        public long? LowPointsCt { get; set; }
        public double? MinThreshold { get; set; }
        public double? MaxThreshold { get; set; }
        public double? MinValue { get; set; }
        public double? MaxValue { get; set; }
        public double? AvergValue { get; set; }
        public double? StdDevValue { get; set; }
        public int? Duration { get; set; }
        public int? ThresholdDuration { get; set; }
        public double? SetPoint { get; set; }
        public string sTagDesc { get; set; }
        public string sEGU { get; set; }
        public DateTime? StageDeprecatedDate { get; set; }
        public DateTime? StageDateDeprecatedDate { get; set; }
        public DateTime? ProductionDate { get; set; }
        public string ExcType { get; set; }
        public string StructDuration { get; set; }
    }
}
