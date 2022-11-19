CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT std.StageDateId, st.TagId, st.StageName, st.MinValue, st.MaxValue, std.StartDate, std.EndDate, st.TimeStep
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId
WHERE (std.DeprecatedDate IS NULL) AND (st.DeprecatedDate IS NULL)
