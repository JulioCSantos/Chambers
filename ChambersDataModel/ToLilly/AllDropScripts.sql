/****** Object:  StoredProcedure [dbo].[spPivotExcursionPoints]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP PROCEDURE [dbo].[spPivotExcursionPoints]
GO
/****** Object:  StoredProcedure [dbo].[spGetStats]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP PROCEDURE [dbo].[spGetStats]
GO
/****** Object:  StoredProcedure [dbo].[spGetInterop2]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP PROCEDURE [dbo].[spGetInterop2]
GO
/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP PROCEDURE [dbo].[spDriverExcursionsPointsForDate]
GO
ALTER TABLE [dbo].[StagesDates] DROP CONSTRAINT [FkStagesStageId_StageId]
GO
ALTER TABLE [dbo].[Stages] DROP CONSTRAINT [TagsTagId2StagesTagId]
GO
ALTER TABLE [dbo].[PointsPaces] DROP CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId]
GO
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 3/17/2023 11:45:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PointsStepsLog]') AND type in (N'U'))
DROP TABLE [dbo].[PointsStepsLog]
GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 3/17/2023 11:45:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PointsPaces]') AND type in (N'U'))
DROP TABLE [dbo].[PointsPaces]
GO
/****** Object:  View [dbo].[BAUExcursions]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP VIEW [dbo].[BAUExcursions]
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 3/17/2023 11:45:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ExcursionPoints]') AND type in (N'U'))
DROP TABLE [dbo].[ExcursionPoints]
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP VIEW [dbo].[StagesLimitsAndDates]
GO
/****** Object:  View [dbo].[StagesLimitsAndDatesCore]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP VIEW [dbo].[StagesLimitsAndDatesCore]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 3/17/2023 11:45:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[StagesDates]') AND type in (N'U'))
DROP TABLE [dbo].[StagesDates]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 3/17/2023 11:45:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stages]') AND type in (N'U'))
DROP TABLE [dbo].[Stages]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 3/17/2023 11:45:31 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tags]') AND type in (N'U'))
DROP TABLE [dbo].[Tags]
GO
/****** Object:  UserDefinedFunction [dbo].[fnToStructDuration]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP FUNCTION [dbo].[fnToStructDuration]
GO
/****** Object:  UserDefinedFunction [dbo].[fnToDuration]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP FUNCTION [dbo].[fnToDuration]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP FUNCTION [dbo].[fnGetOverlappingDates]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetInterp2]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP FUNCTION [dbo].[fnGetInterp2]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetBAUExcursions]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP FUNCTION [dbo].[fnGetBAUExcursions]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCalcTimeStep]    Script Date: 3/17/2023 11:45:31 AM ******/
DROP FUNCTION [dbo].[fnCalcTimeStep]
GO
