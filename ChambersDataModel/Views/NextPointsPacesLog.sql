CREATE VIEW [dbo].[NextPointsPacesLog]
AS
SELECT sld.StageDateId, sld.TagId, sld.StageName, sld.StartDate AS StageStartDate
        , sld.EndDate AS StageEndDate, sld.MinValue, sld.MaxValue
        , cpp.PaceId, cpp.NextStepStartDate, cpp.NextStepEndDate, ods.StartDate, ods.EndDate
FROM  dbo.StagesLimitsAndDates AS sld 
        INNER JOIN
      dbo.PointsPaces AS cpp ON sld.TagId = cpp.TagId 
        CROSS APPLY
      [dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, cpp.NextStepStartDate, cpp.NextStepEndDate) AS ods
WHERE ods.StartDate IS NOT NULL OR ods.EndDate IS NOT NULL
GO