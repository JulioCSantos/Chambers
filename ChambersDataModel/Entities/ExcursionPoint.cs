﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class ExcursionPoint
    {
        public int CycleId { get; set; }
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
        public int HiPointsCt { get; set; }
        public int LowPointsCt { get; set; }
        public double? MinValue { get; set; }
        public double? MaxValue { get; set; }
    }
}