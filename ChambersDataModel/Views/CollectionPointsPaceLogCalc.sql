SELECT cpp.PaceId, cpp.TagId, sld.StageName, sld.StartDate as StageStartDate, sld.EndDate as StageEndDate, sld.MinValue, sld.MaxValue
		, cpp.NextStepStartTime, cpp.NestStepEndTime, ods.StartDate, ods.EndDate
FROM  dbo.StagesLimitsAndDates AS sld INNER JOIN
         dbo.PointsPaces AS cpp ON sld.TagId = cpp.TagId
		 CROSS APPLY
		 [dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, cpp.NextStepStartTime, cpp.NestStepEndTime) as ods
WHERE ods.StartDate IS NOT NULL