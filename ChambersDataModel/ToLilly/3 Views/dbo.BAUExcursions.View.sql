/****** Object:  View [dbo].[BAUExcursions]    Script Date: 3/14/2023 11:44:42 AM ******/
DROP VIEW [dbo].[BAUExcursions]
GO
/****** Object:  View [dbo].[BAUExcursions]    Script Date: 3/14/2023 11:44:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BAUExcursions]
AS
SELECT        BAU.Building, BAU.lAreaID, BAU.lUnitID, BAU.Area, BAU.Unit, EP.TagId, EP.TagName, EP.TagExcNbr, EP.StepLogId, EP.RampInDate, EP.RampInValue, EP.FirstExcDate, EP.FirstExcValue, EP.LastExcDate, 
                         EP.LastExcValue, EP.RampOutDate, EP.RampOutValue, EP.HiPointsCt, EP.LowPointsCt, EP.MinThreshold, EP.MaxThreshold, EP.MinValue, EP.MaxValue, EP.AvergValue, EP.StdDevValue, EP.Duration, 
                         EP.ThresholdDuration, EP.SetPoint, BAU.sTagDesc, BAU.sEGU
						 , STDC.StageDeprecatedDate, STDC.StageDateDeprecatedDate, STDC.ProductionDate
						 , IIF(EP.HiPointsCt > 0,'HI','LOW') AS ExcType
						 , [dbo].[fnToStructDuration](Duration)  as StructDuration
FROM            dbo.BuildingsAreasUnits AS BAU 
				INNER JOIN dbo.ExcursionPoints AS EP ON BAU.lTagID = EP.TagId 
				INNER JOIN dbo.StagesLimitsAndDatesCore as STDC ON STDC.TagId = EP.TagId
GO
