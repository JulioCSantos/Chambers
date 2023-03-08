/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 03/07/2023 00:12:30 ******/
DROP VIEW [dbo].[StagesLimitsAndDates]
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT TagId, TagName, StageDateId, StageName, MinThreshold, MaxThreshold
, StartDate, EndDate, TimeStep, StageId, ThresholdDuration, SetPoint
FROM  dbo.[StagesLimitsAndDatesCore]
WHERE (StageDateDeprecatedDate IS NULL) AND (StageDeprecatedDate IS NULL)


GO
