﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
#nullable disable
using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class Excursion
    {
        public int? TagId { get; set; }
        public string TagName { get; set; }
        public int? ExcNbr { get; set; }
        public DateTime? RampInDate { get; set; }
        public DateTime? RampOutDate { get; set; }
        public int? RampInPointNbr { get; set; }
        public int? RampOutPointNbr { get; set; }
    }
}