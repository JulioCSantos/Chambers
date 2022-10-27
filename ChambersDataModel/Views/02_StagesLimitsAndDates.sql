CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT dbo.StagesDates.StageDateId, dbo.Stages.TagId, dbo.Stages.StageName
	, dbo.Stages.MinValue, dbo.Stages.MaxValue
	, dbo.StagesDates.StartDate, dbo.StagesDates.EndDate
FROM  dbo.Stages INNER JOIN
         dbo.StagesDates ON dbo.Stages.StageId = dbo.StagesDates.StageId
