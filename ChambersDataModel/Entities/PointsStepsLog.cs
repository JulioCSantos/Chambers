﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class PointsStepsLog
    {
        public int StepLogId { get; set; }
        public int StageDateId { get; set; }
        public string StageName { get; set; }
        public int TagId { get; set; }
        public string TagName { get; set; }
        public DateTime StageStartDate { get; set; }
        public DateTime? StageEndDate { get; set; }
        public double MinThreshold { get; set; }
        public double MaxThreshold { get; set; }
        public int PaceId { get; set; }
        public DateTime PaceStartDate { get; set; }
        public DateTime PaceEndDate { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }
}