using System;
using System.Collections.Generic;

namespace ChambersDataModel.Entities
{
    public partial class Excursion
    {
        public int ExcursionId { get; set; }
        public int TagId { get; set; }
        public DateTime RampInDateTime { get; set; }
        public DateTime RampOutDateTime { get; set; }
        public int? RampInPointId { get; set; }
        public int? RampOutPointId { get; set; }

        public virtual ExcursionPoint? RampInPoint { get; set; }
        public virtual ExcursionPoint? RampOutPoint { get; set; }
    }
}
