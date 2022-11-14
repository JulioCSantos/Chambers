USE [master]
GO
/****** Object:  Database [ELChambers]    Script Date: 11/14/2022 5:10:18 PM ******/
CREATE DATABASE [ELChambers]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'ELChambers', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ELChambers.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'ELChambers_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ELChambers_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [ELChambers] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ELChambers].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ELChambers] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ELChambers] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ELChambers] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ELChambers] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ELChambers] SET ARITHABORT OFF 
GO
ALTER DATABASE [ELChambers] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ELChambers] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ELChambers] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ELChambers] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ELChambers] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ELChambers] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ELChambers] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ELChambers] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ELChambers] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ELChambers] SET  ENABLE_BROKER 
GO
ALTER DATABASE [ELChambers] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ELChambers] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ELChambers] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ELChambers] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ELChambers] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ELChambers] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [ELChambers] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ELChambers] SET RECOVERY FULL 
GO
ALTER DATABASE [ELChambers] SET  MULTI_USER 
GO
ALTER DATABASE [ELChambers] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ELChambers] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ELChambers] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ELChambers] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ELChambers] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ELChambers] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ELChambers', N'ON'
GO
ALTER DATABASE [ELChambers] SET QUERY_STORE = OFF
GO
USE [ELChambers]
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetOverlappingDates] 
(	
	-- Add the parameters for the function here
	@StartDate1 DateTime 
	, @endDate1 DateTime
	, @StartDate2 DateTime 
	, @endDate2 DateTime
)
RETURNS @OverlappingSates TABLE ( StartDate DateTime NULL, EndDate DateTime NULL )
AS
BEGIN
	DECLARE @StartDate DateTime , @EndDate DateTime ;
	
	SELECT 
		@StartDate = 
			CASE
				WHEN @StartDate1 > @EndDate2 THEN NULL
				WHEN @StartDate1 < @StartDate2 THEN @StartDate2
				ELSE @StartDate1
			END,
		@EndDate = 
			CASE
				WHEN @EndDate1 < @StartDate2 THEN NULL
				WHEN @EndDate1 > @EndDate2 THEN @EndDate2
				ELSE @EndDate1
			END;
	IF @StartDate IS NULL OR @EndDate IS NULL
		BEGIN INSERT @OverlappingSates SELECT NULL, NULL END
	ELSE 
		BEGIN INSERT @OverlappingSates SELECT @StartDate, @EndDate END

	RETURN;
END;
GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsPaces](
	[PaceId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[NextStepStartDate] [datetime] NOT NULL,
	[StepSizeDays] [int] NOT NULL,
	[NextStepEndDate]  AS (dateadd(day,[StepSizeDays],[NextStepStartDate])),
 CONSTRAINT [pkPointsPacesPointId] PRIMARY KEY CLUSTERED 
(
	[PaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stages](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NULL,
	[MinValue] [float] NOT NULL,
	[MaxValue] [float] NOT NULL,
	[TimeStep] [float] NULL,
 CONSTRAINT [PK_Stages] PRIMARY KEY CLUSTERED 
(
	[StageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StagesDates](
	[StageDateId] [int] IDENTITY(1,1) NOT NULL,
	[StageId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [pkStagesDatesStageDateId] PRIMARY KEY CLUSTERED 
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT dbo.StagesDates.StageDateId, dbo.Stages.TagId, dbo.Stages.StageName, dbo.Stages.MinValue, dbo.Stages.MaxValue, dbo.StagesDates.StartDate, dbo.StagesDates.EndDate, dbo.Stages.TimeStep
FROM  dbo.Stages INNER JOIN
         dbo.StagesDates ON dbo.Stages.StageId = dbo.StagesDates.StageId
GO
/****** Object:  View [dbo].[DefaultPointsPaces]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DefaultPointsPaces]
AS
SELECT SLDs.TagId, DATEADD(year, - 1, GETDATE()) AS NextStepStartDate
FROM  dbo.StagesLimitsAndDates AS SLDs LEFT OUTER JOIN
         dbo.PointsPaces AS PPs ON SLDs.TagId = PPs.TagId
WHERE (PPs.PaceId IS NULL)
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[TagId] [int] NOT NULL,
	[TagName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PointsStepsLogNextValues]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT T.TagId, T.TagName
, sld.StageDateId, sld.StageName, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinValue, sld.MaxValue
, pp.PaceId, pp.NextStepStartDate as PaceStartDate, pp.NextStepEndDate as PaceEndDate
, ods.StartDate, ods.EndDate
FROM 
Tags as t
INNER JOIN 
dbo.StagesLimitsAndDates AS sld ON t.TagId = sld.TagId
INNER JOIN
dbo.PointsPaces AS pp ON sld.TagId = pp.TagId 
CROSS APPLY
[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE 
t.TagName IS NOT NULL AND
ods.StartDate IS NOT NULL AND
ods.EndDate IS NOT NULL
GO
/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompressedPoints](
	[tag] [varchar](255) NOT NULL,
	[time] [datetime] NOT NULL,
	[value] [float] NOT NULL,
 CONSTRAINT [pkCompressedPoints] PRIMARY KEY CLUSTERED 
(
	[tag] ASC,
	[time] ASC,
	[value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionPoints](
	[CycleId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[TagName] [varchar](255) NOT NULL,
	[TagExcNbr] [int] NOT NULL,
	[StepLogId] [int] NULL,
	[RampInDate] [datetime] NULL,
	[RampInValue] [float] NULL,
	[FirstExcDate] [datetime] NULL,
	[FirstExcValue] [float] NULL,
	[LastExcDate] [datetime] NULL,
	[LastExcValue] [float] NULL,
	[RampOutDate] [datetime] NULL,
	[RampOutValue] [float] NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL,
	[HiPointsCt] [int] NOT NULL,
	[LowPointsCt] [int] NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsTagNameTagExcNbr]    Script Date: 11/14/2022 5:10:18 PM ******/
CREATE CLUSTERED INDEX [ixExcursionPointsTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsStepsLog](
	[StepLogId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL,
	[StageEndDate] [datetime] NULL,
	[MinValue] [float] NOT NULL,
	[MaxValue] [float] NOT NULL,
	[PaceId] [int] NOT NULL,
	[PaceStartDate] [datetime] NOT NULL,
	[PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[TagName] [varchar](255) NOT NULL,
 CONSTRAINT [pkPointsStepsLogPaceLogId] PRIMARY KEY CLUSTERED 
(
	[StepLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-02-01T00:00:00.000' AS DateTime), 120)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-02-02T00:00:00.000' AS DateTime), 160)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-02-03T00:00:00.000' AS DateTime), 220)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-02-04T00:00:00.000' AS DateTime), 250)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-02-05T00:00:00.000' AS DateTime), 230)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-03-03T00:00:00.000' AS DateTime), 80)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-03-04T00:00:00.000' AS DateTime), 70)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-03-05T00:00:00.000' AS DateTime), 90)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-03-06T00:00:00.000' AS DateTime), 190)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'T1', CAST(N'2022-03-07T00:00:00.000' AS DateTime), 170)
GO
INSERT [dbo].[Tags] ([TagId], [TagName]) VALUES (1001, N'TagTests_InsertTest')
GO
/****** Object:  Index [pkExcursionPointsCycleId]    Script Date: 11/14/2022 5:10:18 PM ******/
ALTER TABLE [dbo].[ExcursionPoints] ADD  CONSTRAINT [pkExcursionPointsCycleId] PRIMARY KEY NONCLUSTERED 
(
	[CycleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_CollectionPointsPace_TagId]    Script Date: 11/14/2022 5:10:18 PM ******/
CREATE NONCLUSTERED INDEX [IX_CollectionPointsPace_TagId] ON [dbo].[PointsPaces]
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IxTagStageName]    Script Date: 11/14/2022 5:10:18 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName] ON [dbo].[Stages]
(
	[TagId] ASC,
	[StageName] ASC
)
WHERE ([StageName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 11/14/2022 5:10:18 PM ******/
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
(
	[StageId] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixTagsTagName]    Script Date: 11/14/2022 5:10:18 PM ******/
CREATE NONCLUSTERED INDEX [ixTagsTagName] ON [dbo].[Tags]
(
	[TagName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stages] ADD  DEFAULT ((3.4000000000000000e+038)) FOR [MaxValue]
GO
ALTER TABLE [dbo].[StagesDates] ADD  DEFAULT ('9999-12-31 11:11:59') FOR [EndDate]
GO
ALTER TABLE [dbo].[PointsPaces]  WITH CHECK ADD  CONSTRAINT [fkTagsTagId_PointsPacesTagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([TagId])
GO
ALTER TABLE [dbo].[PointsPaces] CHECK CONSTRAINT [fkTagsTagId_PointsPacesTagId]
GO
ALTER TABLE [dbo].[Stages]  WITH CHECK ADD  CONSTRAINT [TagsTagId2StagesTagId] FOREIGN KEY([TagId])
REFERENCES [dbo].[Tags] ([TagId])
GO
ALTER TABLE [dbo].[Stages] CHECK CONSTRAINT [TagsTagId2StagesTagId]
GO
ALTER TABLE [dbo].[StagesDates]  WITH CHECK ADD  CONSTRAINT [FkStagesStageId_StageId] FOREIGN KEY([StageId])
REFERENCES [dbo].[Stages] ([StageId])
GO
ALTER TABLE [dbo].[StagesDates] CHECK CONSTRAINT [FkStagesStageId_StageId]
GO
/****** Object:  StoredProcedure [dbo].[spGetStagesLimitsAndDates]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetStagesLimitsAndDates]
	@TagId int,
	@DateTime DateTime
AS
	SELECT * FROM StagesLimitsAndDates
	WHERE TagId = @TagId AND @DateTime BETWEEN [StartDate] AND [EndDate]
RETURN 0
GO
/****** Object:  StoredProcedure [dbo].[spPivotExcursionPoints]    Script Date: 11/14/2022 5:10:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (	
	  @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
	, @LowThreashold float, @HiThreashold float 
)
AS
BEGIN

	--Declare input cursor values
	DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 0; 
	DECLARE @IsHiExc int = -1;

	-- Output results
	DECLARE @ExcPoint1 as TABLE ( 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  );
	DECLARE @ExcPoints as TABLE ( 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  );
	DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
	DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
	DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
	DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
	DECLARE  @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	PRINT 'GET initial TagExcNbr'
	SELECT TOP 1 @TagExcNbr = ISNULL(TagExcNbr,0) + 1 FROM [dbo].[ExcursionPoints] 
		WHERE TagName = @tag
		ORDER BY TagId, TagExcNbr Desc
	PRINT 'Create Output record'
	INSERT INTO @ExcPoint1 VALUES (@TagName, @TagExcNbr
	, NULL, NULL -- RampIn
	, NULL, NULL -- FirstExc
	, NULL, NULL -- LastExc
	, NULL, NULL -- RampOut
	, @HiPointsCt, @LowPointsCt);

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

	OPEN CPoint;
	PRINT Concat('Fetch First Excursion point. Value ', @Value);
	FETCH NEXT FROM CPoint INTO @tag, @time, @value;

	PRINT 'Loop through Excursion points in the time period if any'
	WHILE @@FETCH_STATUS = 0  BEGIN
			
		IF (@FirstExcDate IS NULL) BEGIN
			PRINT 'Get First Excursion Point'
			UPDATE @ExcPoint1 SET FirstExcDate = @time, FirstExcValue = @value;
			SELECT TOP 1 @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue FROM @ExcPoint1;
			PRINT 'Determine if cycle is for Hi or Low Excursion'
			IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
			ELSE SET @IsHiExc = 0;
		END

		PRINT 'Increase Excursion Counter'
		IF (@IsHiExc = 1) SET @HiPointsCt = @HiPointsCt + 1;
		ELSE SET @LowPointsCt = @LowPointsCt + 1;
		UPDATE @ExcPoint1 SET HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt;

		IF (@FirstExcDate IS NOT NULL AND @RampInDate IS NULL) BEGIN
			PRINT 'Get RampIn point'
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time <= @FirstExcDate 
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Desc;
			IF (@RampInDate IS NOT NULL) UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
		END

		PRINT 'Always Reset Last Excursion Point until end of cursor'
		UPDATE @ExcPoint1 SET LastExcDate = @time, LastExcValue = @value;
		SELECT TOP 1 @LastExcDate = LastExcDate, @LastExcValue = LastExcValue FROM @ExcPoint1;

		PRINT 'Get RampOut point'
		IF (@RampOutDate IS NULL AND @LastExcDate IS NOT NULL ) BEGIN
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time >= @LastExcDate 
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Asc;
			IF (@RampOutDate IS NOT NULL) UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
		END

		PRINT Concat('Next High Excursion point. Value ', @Value);
		FETCH NEXT FROM CPoint INTO @tag, @time, @value; 

		PRINT 'Set up a new Excursion Cycle if ..'
		PRINT '.. Next Excursion date is after RampOut date or ..'
		PRINT '.. Excursion type changed from Hi to Low or vice-versa'
		IF (@@FETCH_STATUS = 0 ) BEGIN
			IF (@time > @RampOutDate OR (@IsHiExc = 1 AND @value < @HiThreashold) OR (@IsHiExc = 0 AND @value >= @LowThreashold) ) BEGIN
				INSERT INTO @ExcPoints Select * FROM @ExcPoint1;
				DELETE FROM @ExcPoint1;
				SET @TagExcNbr = @TagExcNbr + 1;
				SET @RampInDate = NULL; SET @RampInValue = NULL; SET @FirstExcDate = NULL; SET @FirstExcValue = NULL;
				SET @LastExcDate = NULL; SET @LastExcValue = NULL; SET @RampOutDate = NULL; SET @RampOutValue = NULL;
				SET @HiPointsCt = 0; SET @LowPointsCt = 0;
				INSERT INTO @ExcPoint1 VALUES (@TagName, @TagExcNbr
					, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @HiPointsCt, @LowPointsCt);
			END
		END
	END;

	CLOSE CPoint;
	DEALLOCATE CPoint;
	
	INSERT INTO @ExcPoints Select * FROM @ExcPoint1;

	PRINT 'RETURN ALL Full Excursion Cycles'
	SELECT * FROM @ExcPoints WHERE HiPointsCt > 0 OR LowPointsCt > 0;
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SLDs"
            Begin Extent = 
               Top = 15
               Left = 96
               Bottom = 324
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PPs"
            Begin Extent = 
               Top = 15
               Left = 520
               Bottom = 324
               Right = 896
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DefaultPointsPaces'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'DefaultPointsPaces'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
         Width = 600
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PointsStepsLogNextValues'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PointsStepsLogNextValues'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Stages"
            Begin Extent = 
               Top = 15
               Left = 96
               Bottom = 456
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "StagesDates"
            Begin Extent = 
               Top = 164
               Left = 692
               Bottom = 473
               Right = 1059
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StagesLimitsAndDates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StagesLimitsAndDates'
GO
USE [master]
GO
ALTER DATABASE [ELChambers] SET  READ_WRITE 
GO
