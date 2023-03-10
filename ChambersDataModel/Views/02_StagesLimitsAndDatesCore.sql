CREATE VIEW [dbo].[StagesLimitsAndDatesCore]
AS
SELECT t.TagId, t.TagName, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold
, std.StartDate, std.EndDate, st.TimeStep, st.StageId, st.ThresholdDuration, st.SetPoint
, st.DeprecatedDate as StageDeprecatedDate, std.DeprecatedDate as StageDateDeprecatedDate
, st.ProductionDate, IIF((st.DeprecatedDate is NULL AND std.DeprecatedDate IS NULL),0,1) as IsDeprecated
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t.TagId