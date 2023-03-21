using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Chambers.Common;
using ChambersDataModel.Entities;

namespace ChambersTests.DataModel.Extensions
{
    public static class ContextExtensions
    {
        public static PointsPace NewPointsPace(this ChambersDbContext context, string stageName, DateTime? nextStartDate = null
            , int? stepSizeDays = null, int? minThreshold = 100, int? maxThreshold = 200) {
            var tag = new Tag(IntExtensions.NextId(), tagName: stageName);
            var stage = new Stage(tag, minThreshold, maxThreshold);
            var stageDate = new StagesDate(stage);
            context.Tags.Add(tag);
            context.Stages.Add(stage);
            context.StagesDates.Add(stageDate);
            var pointsPace = new PointsPace() { StageDate = stageDate };
            if (nextStartDate != null) { pointsPace.NextStepStartDate = (DateTime)nextStartDate; }
            if (stepSizeDays != null) { pointsPace.StepSizeDays = (int)stepSizeDays; }

            return pointsPace;
        }

        public static CompressedPoint NewCompressedPoint(this ChambersDbContext context
            ,string tagName, DateTime time, float value) {
            var highExcursionPoint = new CompressedPoint(tagName, time, value);
            context.CompressedPoints.Add(highExcursionPoint);

            return highExcursionPoint;
        }

        public static Interpolated NewInterpolatedPoint(this ChambersDbContext context
            , string tagName, DateTime time, float value) {
            var highExcursionPoint = new Interpolated(tagName, time, value);
            context.Add(highExcursionPoint);

            return highExcursionPoint;
        }

        public static ExcursionPoint NewExcursionPoint(this ChambersDbContext context
            , string tagName, int tagExcNbr, int hiPointsCt, int lowPointsCt) {
            var excursionPoint = new ExcursionPoint() {
                TagName = tagName, TagExcNbr = tagExcNbr, HiPointsCt = hiPointsCt, LowPointsCt = lowPointsCt
            };
            
            context.ExcursionPoints.Add(excursionPoint);

            return excursionPoint;
        }

        public static ExcursionPoint NewExcursionPoint(this ChambersDbContext context
            , string tagName, int tagExcNbr, int hiPointsCt, int lowPointsCt
            , DateTime? rampInDate, float? rampInValue, DateTime? rampOutDate, float? rampOutValue) {
            var excursionPoint = new ExcursionPoint() {
                TagName = tagName, TagExcNbr = tagExcNbr, HiPointsCt = hiPointsCt, LowPointsCt = lowPointsCt
                , RampInDate = rampInDate, RampInValue = rampInValue, RampOutDate = rampOutDate, RampOutValue = rampOutValue
            };

            context.ExcursionPoints.Add(excursionPoint);

            return excursionPoint;
        }
    }
}
