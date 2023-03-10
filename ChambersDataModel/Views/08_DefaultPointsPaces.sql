CREATE VIEW DefaultPointsPaces
AS
	-----------------------------------------------
	-------- THIS IS NOT AN EMBEDDED RESOURCE - wont be found on test database
	-----------------------------------------------
SELECT SLDs.StageDateId, DATEADD(year, - 1, GETDATE()) AS NextStepStartDate, 2 AS StepSizeDays
FROM  dbo.StagesLimitsAndDates AS SLDs LEFT OUTER JOIN
         dbo.PointsPaces AS PPs ON SLDs.StageDateId = PPs.StageDateId
WHERE (PPs.PaceId IS NULL)