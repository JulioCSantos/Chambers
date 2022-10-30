CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT T.TagId, T.TagName
, sld.StageDateId, sld.StageName, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinValue, sld.MaxValue
, pp.PaceId, pp.NextStepStartDate as PaceStartDate, pp.NextStepEndDate as PaceEndDate
, ods.StartDate, ods.EndDate
FROM 
Tags as t
INNER JOIN 
dbo.StagesLimitsAndDates AS sld ON t.TagId = sld.TagId
INNER JOIN
dbo.PointsPaces AS pp ON sld.TagId = pp.TagId 
CROSS APPLY
[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE 
t.TagName IS NOT NULL AND
ods.StartDate IS NOT NULL AND
ods.EndDate IS NOT NULL