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
        public static async Task<List<spGetStagesLimitsAndDatesResult>> GetStagesLimitsAndDates(
            this ChambersDbContext context, int tagId, DateTime? forDate = null) {
            var result = await context.Procedures.spGetStagesLimitsAndDatesAsync(tagId, forDate);
            return result;
        }

        public static PointsPace NewPointsPace(this ChambersDbContext context, string stageName, DateTime? nextStartDate = null
            , int? stepSizeDays = null, int? minValue = 100, int? maxValue = 200) {
            var tag = new Tag(IntExtensions.NextId(), tagName: stageName);
            var stage = new Stage(tag, minValue, maxValue);
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
    }
}
