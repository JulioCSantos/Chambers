CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT std.TagId, std.TagName, std.StageDateId, std.StageName, std.MinThreshold, std.MaxThreshold, std.StartDate, std.EndDate
, std.TimeStep, std.StageId, std.ThresholdDuration, std.SetPoint
FROM  StagesLimitsAndDatesCore as std
WHERE (std.DeprecatedDate is null)