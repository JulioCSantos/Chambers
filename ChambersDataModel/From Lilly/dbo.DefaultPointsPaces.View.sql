/****** Object:  View [dbo].[DefaultPointsPaces]    Script Date: 03/07/2023 00:12:30 ******/
DROP VIEW [dbo].[DefaultPointsPaces]
GO
/****** Object:  View [dbo].[DefaultPointsPaces]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DefaultPointsPaces]
AS
SELECT SLDs.StageDateId, DATEADD(year, - 1, GETDATE()) AS NextStepStartDate, 2 AS StepSizeDays
FROM  dbo.StagesLimitsAndDates AS SLDs LEFT OUTER JOIN
         dbo.PointsPaces AS PPs ON SLDs.StageDateId = PPs.StageDateId
WHERE (PPs.PaceId IS NULL)
GO
