CREATE VIEW [dbo].[StagesLimitsAndDatesCore]
AS
SELECT t .TagId, t .TagName, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold, std.StartDate, std.EndDate, st.TimeStep, st.StageId
, st.ThresholdDuration, st.SetPoint, st.DeprecatedDate AS StageDeprecatedDate, std.DeprecatedDate AS StageDateDeprecatedDate, st.ProductionDate
, COALESCE(st.DeprecatedDate, std.DeprecatedDate) as DeprecatedDate
, IIF((st.DeprecatedDate IS NULL AND std.DeprecatedDate IS NULL), Cast(0 as bit), Cast(1 as bit)) AS IsDeprecated
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t .TagId
WHERE (MinThreshold IS NOT NULL or MaxThreshold IS NOT NULL)