CREATE VIEW DefaultPointsPaces
AS
SELECT SLDs.TagId, DATEADD(year, - 1, GETDATE()) AS NextStepStartDate
FROM  dbo.StagesLimitsAndDates AS SLDs LEFT OUTER JOIN
         dbo.PointsPaces AS PPs ON SLDs.TagId = PPs.TagId
WHERE (PPs.PaceId IS NULL)