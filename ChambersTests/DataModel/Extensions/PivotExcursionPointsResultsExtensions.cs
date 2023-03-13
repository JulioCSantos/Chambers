using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChambersTests.DataModel.Extensions
{
    public static class SpPivotExcursionPointsResultExtensions
    {
        public static ExcursionPoint ToExcursionPoint(this spPivotExcursionPointsResult pepr)
        {
            var ep = new ExcursionPoint();
            ep.TagId = pepr.TagId;
            ep.TagName = pepr.TagName;
            ep.StepLogId = pepr.StepLogId;
            ep.TagExcNbr = pepr.TagExcNbr ?? -1;
            ep.RampInDate = pepr.RampInDate;
            ep.RampInValue = pepr.RampInValue;
            ep.FirstExcDate = pepr.FirstExcDate;
            ep.FirstExcValue = pepr.FirstExcValue;
            ep.LastExcDate = pepr.LastExcDate;
            ep.LastExcValue = pepr.LastExcValue;
            ep.RampOutDate = pepr.RampOutDate;
            ep.RampOutValue = pepr.RampOutValue;
            ep.MinValue = pepr.MinValue;
            ep.MaxValue = pepr.MaxValue;
            ep.AvergValue = pepr.AvergValue;
            ep.StdDevValue = pepr.StdDevValue;
            ep.MinThreshold = pepr.MinThreshold;
            ep.MaxThreshold = pepr.MaxThreshold;
            ep.LowPointsCt = pepr.LowPointsCt ?? 0;
            ep.HiPointsCt = pepr.HiPointsCt ?? 0;
            ep.ThresholdDuration = pepr.ThresholdDuration;
            ep.SetPoint = pepr.SetPoint;

            return ep;
        }
    }
}
