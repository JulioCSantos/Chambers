CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT t.TagId, t.TagName, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold
, std.StartDate, std.EndDate, st.TimeStep, st.StageId, st.ThresholdDuration, st.SetPoint
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t.TagId
WHERE (std.DeprecatedDate IS NULL) AND (st.DeprecatedDate IS NULL)