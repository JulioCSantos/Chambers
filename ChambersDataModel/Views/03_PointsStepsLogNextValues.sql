CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT sld.StageDateId, sld.StageName, T .TagId, T .TagName, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinThreshold, sld.MaxThreshold, pp.PaceId, pp.NextStepStartDate AS PaceStartDate, pp.NextStepEndDate AS PaceEndDate
, ods.StartDate, ods.EndDate, sld.ThresholdDuration, sld.SetPoint 
FROM  Tags AS t 
INNER JOIN dbo.StagesLimitsAndDates AS sld ON t .TagId = sld.TagId 
INNER JOIN dbo.PointsPaces AS pp ON sld.StageDateId = pp.StageDateId 
CROSS APPLY[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE t .TagName IS NOT NULL AND ods.StartDate IS NOT NULL AND ods.EndDate IS NOT NULL AND pp.ProcessedDate IS NULL