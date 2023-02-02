CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT sld.StageDateId, sld.StageName,T.TagId, T.TagName
, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinThreshold, sld.MaxThreshold
, pp.PaceId, pp.NextStepStartDate as PaceStartDate, pp.NextStepEndDate as PaceEndDate
, ods.StartDate, ods.EndDate
FROM 
Tags as t
INNER JOIN 
dbo.StagesLimitsAndDates AS sld ON t.TagId = sld.TagId
INNER JOIN
dbo.PointsPaces AS pp ON sld.StageDateId = pp.StageDateId
CROSS APPLY
[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE 
t.TagName IS NOT NULL AND
ods.StartDate IS NOT NULL AND
ods.EndDate IS NOT NULL AND
pp.ProcessedDate IS NULL