﻿// <auto-generated> This file has been auto generated by EF Core Power Tools. </auto-generated>
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace ChambersDataModel.Entities
{
    public partial class fnGetInterp2Result
    {
        public string tag { get; set; }
        public DateTime? time { get; set; }
        public double? value { get; set; }
        public string svalue { get; set; }
        public int? status { get; set; }
        public TimeSpan? timestep { get; set; }
    }
}