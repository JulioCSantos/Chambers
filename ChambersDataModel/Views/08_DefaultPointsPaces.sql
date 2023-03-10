CREATE VIEW DefaultPointsPaces
AS
SELECT SLDs.StageDateId, DATEADD(year, - 1, GETDATE()) AS NextStepStartDate, 2 AS StepSizeDays
FROM  dbo.StagesLimitsAndDates AS SLDs LEFT OUTER JOIN
         dbo.PointsPaces AS PPs ON SLDs.StageDateId = PPs.StageDateId
WHERE (PPs.PaceId IS NULL)