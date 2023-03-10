CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT TagId, TagName, StageDateId, StageName, MinThreshold, MaxThreshold
, StartDate, EndDate, TimeStep, StageId, ThresholdDuration, SetPoint
FROM  [dbo].[StagesLimitsAndDatesCore]
WHERE (StageDateDeprecatedDate IS NULL) AND (StageDeprecatedDate IS NULL)