USE [master]
GO
/****** Object:  Database [ELChambers]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetScheduleDates]    Script Date: 11/18/2022 1:35:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- GetScheduleDates('2022-11-03', '2022-10-02', 1, week, 1, month) returns '2022-10-30', '2022-11-05'
-- find schedule dates for date 2022-11-03 when schedule starts on 2022-10-02 (Sunday) and is active for one week 
-- when it repeats every month (first Sunday of the month for a full week)
CREATE FUNCTION [dbo].[fnGetScheduleDates] 
(	
	-- Add the parameters for the function here
	@ForDate date, 
	@StartDate date,
	@CoverageValue int,
	@CoverageIntervalUnit varchar(16),
	@RepeatEveryValue int,
	@RepeatEveryIntervalUnit varchar(16)
)
RETURNS @ScheduleDates TABLE (StartDate date NULL, EndDate date NULL)
AS
BEGIN
	DECLARE @SchedStartDate Date , @SchedEndDate Date ;

	-- Compute the RepeatEveryInterval in days
	DECLARE @FirstIntervalEndDate datetime;
	SELECT @FirstIntervalEndDate = (
    CASE 
        WHEN  @RepeatEveryIntervalUnit = 'year' THEN DATEADD(year, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'quarter' THEN DATEADD(quarter, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'month' THEN DATEADD(month, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'dayofyear' THEN DATEADD(dayofyear, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'day' THEN DATEADD(day, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'week' THEN DATEADD(week, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'weekday' THEN DATEADD(weekday, @RepeatEveryValue,@StartDate)
	END)

	DECLARE @DaysInInterval int;
	
	-- Determine how many RepeatEvery intervals fit between ForDate and StartDate

	-- days in Repeat Every Interval
	SET @DaysInInterval = DATEDIFF(DAY, @StartDate, @FirstIntervalEndDate);

	-- ForDate minus StartDate in days
	DECLARE @DaysBetweenForDateAndStartDate int = DATEDIFF(DAY,@StartDate, @ForDate);

	-- Number of intervals from StartDate to ForDate
	DECLARE @NbrOfIntervals int = FLOOR(@DaysBetweenForDateAndStartDate/@DaysInInterval);

	-- Determine if adjusted StartDate is in Coverage interval (fuzzy logic)

	-- adjusted StartDate is the closest StartDate to ForDate 
	SET @SchedStartDate  = DATEADD(day,@NbrOfIntervals * @DaysInInterval,@StartDate);

	SELECT @SchedEndDate = (
    CASE 
        WHEN @CoverageIntervalUnit = 'year' THEN DATEADD(year, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'quarter' THEN DATEADD(quarter, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'month' THEN DATEADD(month, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'dayofyear' THEN DATEADD(dayofyear, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'day' THEN DATEADD(day, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'week' THEN DATEADD(week, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'weekday' THEN DATEADD(weekday, @CoverageValue, @SchedStartDate)
	END)

	-- Add the SELECT statement with parameter references here
	if (@SchedStartDate <= @ForDate AND @ForDate <= @SchedEndDate) BEGIN
		INSERT @ScheduleDates
		SELECT  @SchedStartDate,  @SchedEndDate;
	END
	ELSE BEGIN
		INSERT @ScheduleDates
		SELECT  NULL,  NULL;
	END

	RETURN ;

END
--DateAdd's interval The time/date interval to add. Can be one of the following values:
--year, yyyy, yy = Year"
--quarter, qq, q = Quarter
--month, mm, m = month
--dayofyear, dy, y = Day of the year
--day, dd, d = Day
--week, ww, wk = Week
--weekday, dw, w = Weekday
--hour, hh = hour
--minute, mi, n = Minute
--second, ss, s = Second
--millisecond, ms = Millisecond

GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  Table [dbo].[Stages]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  Table [dbo].[StagesDates]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  View [dbo].[DefaultPointsPaces]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  Table [dbo].[Tags]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  View [dbo].[PointsStepsLogNextValues]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 11/18/2022 1:35:07 PM ******/
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
	[HiPointsCt] [int] NOT NULL,
	[LowPointsCt] [int] NOT NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsTagNameTagExcNbr]    Script Date: 11/18/2022 1:35:07 PM ******/
CREATE CLUSTERED INDEX [ixExcursionPointsTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HiExcursion]    Script Date: 11/18/2022 1:35:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HiExcursion](
	[XdateStr] [datetime2](7) NOT NULL,
	[FSValN] [float] NOT NULL,
 CONSTRAINT [PK_HiExcursion] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LowExcursion]    Script Date: 11/18/2022 1:35:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LowExcursion](
	[XdateStr] [datetime2](7) NOT NULL,
	[FlatVal] [float] NOT NULL,
 CONSTRAINT [PK_LowExcursion] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 11/18/2022 1:35:07 PM ******/
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
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:00:00.000' AS DateTime), 114.84999847412109)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:01:00.000' AS DateTime), 115.36837768554688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:02:00.000' AS DateTime), 115.77350616455078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:03:00.000' AS DateTime), 118.83537292480469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:04:00.000' AS DateTime), 114.74398040771484)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:05:00.000' AS DateTime), 119.88928985595703)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:06:00.000' AS DateTime), 115.35129547119141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:07:00.000' AS DateTime), 119.06996154785156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:08:00.000' AS DateTime), 115.39525604248047)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:09:00.000' AS DateTime), 119.25714111328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:10:00.000' AS DateTime), 115.8355712890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:11:00.000' AS DateTime), 118.72050476074219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:12:00.000' AS DateTime), 118.63188171386719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:13:00.000' AS DateTime), 116.10964965820313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:14:00.000' AS DateTime), 117.22373199462891)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:15:00.000' AS DateTime), 117.86408233642578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:16:00.000' AS DateTime), 119.81060791015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:17:00.000' AS DateTime), 118.84323883056641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:18:00.000' AS DateTime), 119.49188995361328)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:19:00.000' AS DateTime), 120.92647552490234)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:20:00.000' AS DateTime), 119.97690582275391)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:21:00.000' AS DateTime), 118.21307373046875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:22:00.000' AS DateTime), 118.50489044189453)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:23:00.000' AS DateTime), 123.28223419189453)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:24:00.000' AS DateTime), 122.11499786376953)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:25:00.000' AS DateTime), 121.5230712890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:26:00.000' AS DateTime), 124.39632415771484)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:27:00.000' AS DateTime), 120.504638671875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:28:00.000' AS DateTime), 124.69788360595703)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:29:00.000' AS DateTime), 125.16591644287109)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:30:00.000' AS DateTime), 124.38860321044922)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:31:00.000' AS DateTime), 127.95579528808594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:32:00.000' AS DateTime), 123.82735443115234)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:33:00.000' AS DateTime), 123.67311859130859)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:34:00.000' AS DateTime), 123.90293121337891)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:35:00.000' AS DateTime), 126.00663757324219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:36:00.000' AS DateTime), 125.38406372070313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:37:00.000' AS DateTime), 128.8050537109375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:38:00.000' AS DateTime), 130.79940795898438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:39:00.000' AS DateTime), 132.64697265625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:40:00.000' AS DateTime), 130.03755187988281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:41:00.000' AS DateTime), 128.08097839355469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:42:00.000' AS DateTime), 128.79702758789063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:43:00.000' AS DateTime), 131.23554992675781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:44:00.000' AS DateTime), 132.36631774902344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:45:00.000' AS DateTime), 133.27912902832031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:46:00.000' AS DateTime), 132.81379699707031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:47:00.000' AS DateTime), 133.65008544921875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:48:00.000' AS DateTime), 136.33781433105469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:49:00.000' AS DateTime), 139.24674987792969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:50:00.000' AS DateTime), 134.4666748046875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:51:00.000' AS DateTime), 135.807373046875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:52:00.000' AS DateTime), 136.72862243652344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:53:00.000' AS DateTime), 136.70018005371094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:54:00.000' AS DateTime), 138.03181457519531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:55:00.000' AS DateTime), 141.42329406738281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:56:00.000' AS DateTime), 143.06439208984375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:57:00.000' AS DateTime), 142.28485107421875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:58:00.000' AS DateTime), 141.98443603515625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T10:59:00.000' AS DateTime), 146.71290588378906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:00:00.000' AS DateTime), 147.77999877929688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:01:00.000' AS DateTime), 143.84547424316406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:02:00.000' AS DateTime), 149.54905700683594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:03:00.000' AS DateTime), 145.43052673339844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:04:00.000' AS DateTime), 150.75958251953125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:05:00.000' AS DateTime), 146.44599914550781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:06:00.000' AS DateTime), 147.15948486328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:07:00.000' AS DateTime), 152.47978210449219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:08:00.000' AS DateTime), 152.65663146972656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:09:00.000' AS DateTime), 149.90975952148438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:10:00.000' AS DateTime), 153.95889282226563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:11:00.000' AS DateTime), 155.82374572753906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:12:00.000' AS DateTime), 157.37406921386719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:13:00.000' AS DateTime), 155.70954895019531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:14:00.000' AS DateTime), 159.93994140625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:15:00.000' AS DateTime), 159.04495239257813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:16:00.000' AS DateTime), 159.75430297851563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:17:00.000' AS DateTime), 160.92768859863281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:18:00.000' AS DateTime), 159.03485107421875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:19:00.000' AS DateTime), 163.60549926757813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:20:00.000' AS DateTime), 162.56935119628906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:21:00.000' AS DateTime), 164.8861083984375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:22:00.000' AS DateTime), 167.84547424316406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:23:00.000' AS DateTime), 163.20718383789063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:24:00.000' AS DateTime), 165.47093200683594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:25:00.000' AS DateTime), 169.39643859863281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:26:00.000' AS DateTime), 169.68339538574219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:27:00.000' AS DateTime), 168.03152465820313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:28:00.000' AS DateTime), 172.25053405761719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:29:00.000' AS DateTime), 169.08012390136719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:30:00.000' AS DateTime), 170.52000427246094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:31:00.000' AS DateTime), 171.61988830566406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:32:00.000' AS DateTime), 176.63946533203125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:33:00.000' AS DateTime), 175.28848266601563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:34:00.000' AS DateTime), 175.18659973144531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:35:00.000' AS DateTime), 177.38356018066406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:36:00.000' AS DateTime), 175.4190673828125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:37:00.000' AS DateTime), 180.39280700683594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:38:00.000' AS DateTime), 180.06451416015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:39:00.000' AS DateTime), 181.80389404296875)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:40:00.000' AS DateTime), 180.70065307617188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:41:00.000' AS DateTime), 184.26449584960938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:42:00.000' AS DateTime), 186.16514587402344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:43:00.000' AS DateTime), 187.82231140136719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:44:00.000' AS DateTime), 184.86570739746094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:45:00.000' AS DateTime), 186.13504028320313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:46:00.000' AS DateTime), 185.85005187988281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:47:00.000' AS DateTime), 186.3304443359375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:48:00.000' AS DateTime), 186.75593566894531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:49:00.000' AS DateTime), 187.74624633789063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:50:00.000' AS DateTime), 190.60110473632813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:51:00.000' AS DateTime), 191.990234375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:52:00.000' AS DateTime), 194.11335754394531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:53:00.000' AS DateTime), 195.25021362304688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:54:00.000' AS DateTime), 192.4105224609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:55:00.000' AS DateTime), 195.59400939941406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:56:00.000' AS DateTime), 198.08041381835938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:57:00.000' AS DateTime), 197.78947448730469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:58:00.000' AS DateTime), 198.60093688964844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T11:59:00.000' AS DateTime), 198.61453247070313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:00:00.000' AS DateTime), 197.1300048828125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:01:00.000' AS DateTime), 201.42709350585938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:02:00.000' AS DateTime), 199.93556213378906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:03:00.000' AS DateTime), 205.44514465332031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:04:00.000' AS DateTime), 200.35560607910156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:05:00.000' AS DateTime), 203.17669677734375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:06:00.000' AS DateTime), 204.59819030761719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:07:00.000' AS DateTime), 205.50982666015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:08:00.000' AS DateTime), 205.14138793945313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:09:00.000' AS DateTime), 205.75262451171875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:10:00.000' AS DateTime), 205.88331604003906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:11:00.000' AS DateTime), 208.79324340820313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:12:00.000' AS DateTime), 207.92218017578125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:13:00.000' AS DateTime), 210.95991516113281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:14:00.000' AS DateTime), 209.44621276855469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:15:00.000' AS DateTime), 212.25086975097656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:16:00.000' AS DateTime), 212.18368530273438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:17:00.000' AS DateTime), 214.72445678710938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:18:00.000' AS DateTime), 210.61296081542969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:19:00.000' AS DateTime), 214.30902099609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:20:00.000' AS DateTime), 213.6324462890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:21:00.000' AS DateTime), 216.28303527832031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:22:00.000' AS DateTime), 215.70059204101563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:23:00.000' AS DateTime), 217.05494689941406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:24:00.000' AS DateTime), 215.9559326171875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:25:00.000' AS DateTime), 219.76336669921875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:26:00.000' AS DateTime), 220.19706726074219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:27:00.000' AS DateTime), 216.056884765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:28:00.000' AS DateTime), 218.03263854980469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:29:00.000' AS DateTime), 219.96420288085938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:30:00.000' AS DateTime), 222.08139038085938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:31:00.000' AS DateTime), 221.18408203125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:32:00.000' AS DateTime), 221.31211853027344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:33:00.000' AS DateTime), 218.6253662109375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:34:00.000' AS DateTime), 223.86367797851563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:35:00.000' AS DateTime), 222.11692810058594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:36:00.000' AS DateTime), 222.22500610351563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:37:00.000' AS DateTime), 223.07777404785156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:38:00.000' AS DateTime), 226.22511291503906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:39:00.000' AS DateTime), 224.70692443847656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:40:00.000' AS DateTime), 224.61309814453125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:41:00.000' AS DateTime), 222.99351501464844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:42:00.000' AS DateTime), 225.64810180664063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:43:00.000' AS DateTime), 224.46676635742188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:44:00.000' AS DateTime), 225.72940063476563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:45:00.000' AS DateTime), 226.25592041015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:46:00.000' AS DateTime), 226.98626708984375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:47:00.000' AS DateTime), 226.53034973144531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:48:00.000' AS DateTime), 225.48811340332031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:49:00.000' AS DateTime), 225.18949890136719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:50:00.000' AS DateTime), 227.36442565917969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:51:00.000' AS DateTime), 227.8028564453125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:52:00.000' AS DateTime), 226.63475036621094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:53:00.000' AS DateTime), 227.30003356933594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:54:00.000' AS DateTime), 226.34870910644531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:55:00.000' AS DateTime), 228.51071166992188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:56:00.000' AS DateTime), 225.83602905273438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:57:00.000' AS DateTime), 230.41462707519531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:58:00.000' AS DateTime), 228.906494140625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T12:59:00.000' AS DateTime), 225.40162658691406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:00:00.000' AS DateTime), 229.66000366210938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:01:00.000' AS DateTime), 227.13162231445313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:02:00.000' AS DateTime), 227.48649597167969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:03:00.000' AS DateTime), 224.87461853027344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:04:00.000' AS DateTime), 227.76602172851563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:05:00.000' AS DateTime), 224.96070861816406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:06:00.000' AS DateTime), 229.0487060546875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:07:00.000' AS DateTime), 228.7900390625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:08:00.000' AS DateTime), 226.12474060058594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:09:00.000' AS DateTime), 225.45286560058594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:10:00.000' AS DateTime), 224.75442504882813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:11:00.000' AS DateTime), 226.05949401855469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:12:00.000' AS DateTime), 227.51811218261719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:13:00.000' AS DateTime), 225.17034912109375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:14:00.000' AS DateTime), 228.31626892089844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:15:00.000' AS DateTime), 226.46592712402344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:16:00.000' AS DateTime), 225.39939880371094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:17:00.000' AS DateTime), 227.65676879882813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:18:00.000' AS DateTime), 223.39810180664063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:19:00.000' AS DateTime), 224.80352783203125)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:20:00.000' AS DateTime), 225.81309509277344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:21:00.000' AS DateTime), 222.29692077636719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:22:00.000' AS DateTime), 221.89511108398438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:23:00.000' AS DateTime), 220.457763671875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:24:00.000' AS DateTime), 223.42500305175781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:25:00.000' AS DateTime), 223.64692687988281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:26:00.000' AS DateTime), 223.8836669921875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:27:00.000' AS DateTime), 224.245361328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:28:00.000' AS DateTime), 223.72212219238281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:29:00.000' AS DateTime), 218.58409118652344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:30:00.000' AS DateTime), 217.48139953613281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:31:00.000' AS DateTime), 219.27420043945313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:32:00.000' AS DateTime), 220.32264709472656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:33:00.000' AS DateTime), 218.53688049316406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:34:00.000' AS DateTime), 219.737060546875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:35:00.000' AS DateTime), 217.49336242675781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:36:00.000' AS DateTime), 219.89593505859375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:37:00.000' AS DateTime), 217.54495239257813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:38:00.000' AS DateTime), 217.39059448242188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:39:00.000' AS DateTime), 213.16302490234375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:40:00.000' AS DateTime), 217.48243713378906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:41:00.000' AS DateTime), 214.06903076171875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:42:00.000' AS DateTime), 215.36296081542969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:43:00.000' AS DateTime), 210.41445922851563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:44:00.000' AS DateTime), 211.51368713378906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:45:00.000' AS DateTime), 209.15087890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:46:00.000' AS DateTime), 209.42620849609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:47:00.000' AS DateTime), 208.2899169921875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:48:00.000' AS DateTime), 210.12217712402344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:49:00.000' AS DateTime), 207.84324645996094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:50:00.000' AS DateTime), 209.48332214355469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:51:00.000' AS DateTime), 206.72262573242188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:52:00.000' AS DateTime), 209.33137512207031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:53:00.000' AS DateTime), 205.26982116699219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:54:00.000' AS DateTime), 202.75819396972656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:55:00.000' AS DateTime), 206.50669860839844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:56:00.000' AS DateTime), 202.60560607910156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:57:00.000' AS DateTime), 203.80514526367188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:58:00.000' AS DateTime), 198.72555541992188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T13:59:00.000' AS DateTime), 197.86709594726563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:00:00.000' AS DateTime), 201.47000122070313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:01:00.000' AS DateTime), 198.99452209472656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:02:00.000' AS DateTime), 195.93093872070313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:03:00.000' AS DateTime), 194.66947937011719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:04:00.000' AS DateTime), 199.36041259765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:05:00.000' AS DateTime), 197.66400146484375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:06:00.000' AS DateTime), 195.71051025390625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:07:00.000' AS DateTime), 191.82020568847656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:08:00.000' AS DateTime), 193.28335571289063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:09:00.000' AS DateTime), 190.32023620605469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:10:00.000' AS DateTime), 189.08110046386719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:11:00.000' AS DateTime), 192.07624816894531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:12:00.000' AS DateTime), 190.62593078613281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:13:00.000' AS DateTime), 189.42044067382813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:14:00.000' AS DateTime), 186.64006042480469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:15:00.000' AS DateTime), 188.06504821777344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:16:00.000' AS DateTime), 188.095703125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:17:00.000' AS DateTime), 186.92230224609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:18:00.000' AS DateTime), 183.15513610839844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:19:00.000' AS DateTime), 184.8544921875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:20:00.000' AS DateTime), 180.78065490722656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:21:00.000' AS DateTime), 181.243896484375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:22:00.000' AS DateTime), 180.5145263671875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:23:00.000' AS DateTime), 177.36280822753906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:24:00.000' AS DateTime), 178.42906188964844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:25:00.000' AS DateTime), 176.74356079101563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:26:00.000' AS DateTime), 173.49661254882813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:27:00.000' AS DateTime), 174.07847595214844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:28:00.000' AS DateTime), 173.34947204589844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:29:00.000' AS DateTime), 172.7598876953125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:30:00.000' AS DateTime), 171.27000427246094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:31:00.000' AS DateTime), 172.90011596679688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:32:00.000' AS DateTime), 172.13052368164063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:33:00.000' AS DateTime), 167.88151550292969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:34:00.000' AS DateTime), 171.59339904785156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:35:00.000' AS DateTime), 169.81643676757813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:36:00.000' AS DateTime), 163.85093688964844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:37:00.000' AS DateTime), 164.4871826171875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:38:00.000' AS DateTime), 166.87547302246094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:39:00.000' AS DateTime), 161.39610290527344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:40:00.000' AS DateTime), 159.96934509277344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:41:00.000' AS DateTime), 164.7655029296875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:42:00.000' AS DateTime), 163.32485961914063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:43:00.000' AS DateTime), 162.76768493652344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:44:00.000' AS DateTime), 160.19429016113281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:45:00.000' AS DateTime), 160.02494812011719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:46:00.000' AS DateTime), 159.83995056152344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:47:00.000' AS DateTime), 153.6695556640625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:48:00.000' AS DateTime), 155.76406860351563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:49:00.000' AS DateTime), 155.19375610351563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:50:00.000' AS DateTime), 156.04888916015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:51:00.000' AS DateTime), 155.54975891113281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:52:00.000' AS DateTime), 151.43663024902344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:53:00.000' AS DateTime), 151.23979187011719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:54:00.000' AS DateTime), 148.55947875976563)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:55:00.000' AS DateTime), 149.81599426269531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:56:00.000' AS DateTime), 150.68959045410156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:57:00.000' AS DateTime), 146.87052917480469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:58:00.000' AS DateTime), 149.59906005859375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T14:59:00.000' AS DateTime), 148.37547302246094)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:00:00.000' AS DateTime), 146.57000732421875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:01:00.000' AS DateTime), 142.6029052734375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:02:00.000' AS DateTime), 144.95443725585938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:03:00.000' AS DateTime), 139.87484741210938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:04:00.000' AS DateTime), 144.08439636230469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:05:00.000' AS DateTime), 140.7532958984375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:06:00.000' AS DateTime), 142.99180603027344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:07:00.000' AS DateTime), 139.98017883300781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:08:00.000' AS DateTime), 138.76861572265625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:09:00.000' AS DateTime), 138.41737365722656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:10:00.000' AS DateTime), 138.28668212890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:11:00.000' AS DateTime), 136.38674926757813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:12:00.000' AS DateTime), 134.65782165527344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:13:00.000' AS DateTime), 136.02009582519531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:14:00.000' AS DateTime), 133.0037841796875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:15:00.000' AS DateTime), 136.58912658691406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:16:00.000' AS DateTime), 132.17631530761719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:17:00.000' AS DateTime), 131.98554992675781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:18:00.000' AS DateTime), 130.717041015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:19:00.000' AS DateTime), 131.79096984863281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:20:00.000' AS DateTime), 131.72755432128906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:21:00.000' AS DateTime), 128.65696716308594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:22:00.000' AS DateTime), 128.84941101074219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:23:00.000' AS DateTime), 127.53504943847656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:24:00.000' AS DateTime), 126.06406402587891)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:25:00.000' AS DateTime), 130.12663269042969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:26:00.000' AS DateTime), 124.36293029785156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:27:00.000' AS DateTime), 125.12311553955078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:28:00.000' AS DateTime), 126.12735748291016)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:29:00.000' AS DateTime), 124.42579650878906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:30:00.000' AS DateTime), 125.53860473632813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:31:00.000' AS DateTime), 121.57591247558594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:32:00.000' AS DateTime), 126.00788116455078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:33:00.000' AS DateTime), 122.62464141845703)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:34:00.000' AS DateTime), 120.11632537841797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:35:00.000' AS DateTime), 124.43307495117188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:36:00.000' AS DateTime), 124.18499755859375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:37:00.000' AS DateTime), 122.71223449707031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:38:00.000' AS DateTime), 119.62488555908203)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:39:00.000' AS DateTime), 120.58307647705078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:40:00.000' AS DateTime), 121.71690368652344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:41:00.000' AS DateTime), 121.136474609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:42:00.000' AS DateTime), 122.45188903808594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:43:00.000' AS DateTime), 120.54323577880859)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:44:00.000' AS DateTime), 117.67060852050781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:45:00.000' AS DateTime), 121.86408233642578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:46:00.000' AS DateTime), 118.02373504638672)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:47:00.000' AS DateTime), 120.59964752197266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:48:00.000' AS DateTime), 120.89188385009766)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:49:00.000' AS DateTime), 116.04050445556641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:50:00.000' AS DateTime), 116.35557556152344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:51:00.000' AS DateTime), 120.07714080810547)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:52:00.000' AS DateTime), 119.99525451660156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:53:00.000' AS DateTime), 120.71996307373047)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:54:00.000' AS DateTime), 118.79129791259766)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:55:00.000' AS DateTime), 115.36929321289063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:56:00.000' AS DateTime), 118.58397674560547)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:57:00.000' AS DateTime), 119.43537902832031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:58:00.000' AS DateTime), 118.81350708007813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T15:59:00.000' AS DateTime), 120.14837646484375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-01T16:00:00.000' AS DateTime), 117.05999755859375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:00:00.000' AS DateTime), 116.64499664306641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:04:00.000' AS DateTime), 116.08771514892578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:08:00.000' AS DateTime), 116.48586273193359)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:12:00.000' AS DateTime), 118.85944366455078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:16:00.000' AS DateTime), 118.25846099853516)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:20:00.000' AS DateTime), 118.40292358398438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:24:00.000' AS DateTime), 116.84282684326172)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:28:00.000' AS DateTime), 117.75819396972656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:32:00.000' AS DateTime), 117.66902160644531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:36:00.000' AS DateTime), 116.12532806396484)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:40:00.000' AS DateTime), 118.14711761474609)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:44:00.000' AS DateTime), 115.91440582275391)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:48:00.000' AS DateTime), 116.35721588134766)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:52:00.000' AS DateTime), 118.23055267333984)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T08:56:00.000' AS DateTime), 115.77943420410156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:00:00.000' AS DateTime), 115.87388610839844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:04:00.000' AS DateTime), 117.70392608642578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:08:00.000' AS DateTime), 118.11956787109375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:12:00.000' AS DateTime), 116.91085052490234)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:16:00.000' AS DateTime), 116.76777648925781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:20:00.000' AS DateTime), 116.98538970947266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:24:00.000' AS DateTime), 117.47370910644531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:28:00.000' AS DateTime), 115.68775939941406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:32:00.000' AS DateTime), 116.19257354736328)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:36:00.000' AS DateTime), 115.61817932128906)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:40:00.000' AS DateTime), 117.41461944580078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:44:00.000' AS DateTime), 115.38690948486328)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:48:00.000' AS DateTime), 116.07009887695313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:52:00.000' AS DateTime), 114.47921752929688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T09:56:00.000' AS DateTime), 114.36929321289063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:00:00.000' AS DateTime), 116.78038024902344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:04:00.000' AS DateTime), 116.40750885009766)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:08:00.000' AS DateTime), 114.92072296142578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:12:00.000' AS DateTime), 115.07006072998047)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:16:00.000' AS DateTime), 114.22556304931641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:20:00.000' AS DateTime), 114.18727874755859)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:24:00.000' AS DateTime), 113.34525299072266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:28:00.000' AS DateTime), 113.79453277587891)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:32:00.000' AS DateTime), 115.10015869140625)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:36:00.000' AS DateTime), 114.42218780517578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:40:00.000' AS DateTime), 112.64066314697266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:44:00.000' AS DateTime), 113.48564147949219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:48:00.000' AS DateTime), 113.12717437744141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:52:00.000' AS DateTime), 113.95030212402344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T10:56:00.000' AS DateTime), 113.89509582519531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:00:00.000' AS DateTime), 112.70660400390625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:04:00.000' AS DateTime), 111.59987640380859)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:08:00.000' AS DateTime), 113.55997467041016)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:12:00.000' AS DateTime), 113.85695648193359)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:16:00.000' AS DateTime), 113.52588653564453)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:20:00.000' AS DateTime), 113.49681091308594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:24:00.000' AS DateTime), 112.07980346679688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:28:00.000' AS DateTime), 111.34492492675781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:32:00.000' AS DateTime), 111.30722808837891)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:36:00.000' AS DateTime), 112.45677947998047)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:40:00.000' AS DateTime), 111.99864959716797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:44:00.000' AS DateTime), 109.77289581298828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:48:00.000' AS DateTime), 110.70958709716797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:52:00.000' AS DateTime), 110.42878723144531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T11:56:00.000' AS DateTime), 109.26557159423828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:00:00.000' AS DateTime), 110.55500030517578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:04:00.000' AS DateTime), 111.03214263916016)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:08:00.000' AS DateTime), 109.09207153320313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:12:00.000' AS DateTime), 109.61486053466797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:16:00.000' AS DateTime), 109.80556488037109)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:20:00.000' AS DateTime), 109.57927703857422)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:24:00.000' AS DateTime), 107.76605224609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:28:00.000' AS DateTime), 109.06596374511719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:32:00.000' AS DateTime), 108.22909545898438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:36:00.000' AS DateTime), 108.7855224609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:40:00.000' AS DateTime), 108.20030212402344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:44:00.000' AS DateTime), 106.38352203369141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:48:00.000' AS DateTime), 106.32525634765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:52:00.000' AS DateTime), 107.37057495117188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T12:56:00.000' AS DateTime), 107.57955932617188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:00:00.000' AS DateTime), 106.97228240966797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:04:00.000' AS DateTime), 107.10882568359375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:08:00.000' AS DateTime), 106.749267578125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:12:00.000' AS DateTime), 105.06867218017578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:16:00.000' AS DateTime), 103.942138671875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:20:00.000' AS DateTime), 104.14472198486328)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:24:00.000' AS DateTime), 105.02651977539063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:28:00.000' AS DateTime), 104.75259399414063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:32:00.000' AS DateTime), 103.93804168701172)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:36:00.000' AS DateTime), 103.17292785644531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:40:00.000' AS DateTime), 105.21233367919922)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:44:00.000' AS DateTime), 104.00135040283203)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:48:00.000' AS DateTime), 103.97503662109375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:52:00.000' AS DateTime), 103.79849243164063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T13:56:00.000' AS DateTime), 101.87178802490234)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:00:00.000' AS DateTime), 101.62000274658203)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:04:00.000' AS DateTime), 100.76821136474609)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:08:00.000' AS DateTime), 101.11151123046875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:12:00.000' AS DateTime), 101.26995849609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:16:00.000' AS DateTime), 100.67864990234375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:20:00.000' AS DateTime), 100.4776611328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:24:00.000' AS DateTime), 101.93207550048828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:28:00.000' AS DateTime), 100.40695953369141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:32:00.000' AS DateTime), 100.79240417480469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:36:00.000' AS DateTime), 99.1934814453125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:40:00.000' AS DateTime), 100.77027893066406)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:44:00.000' AS DateTime), 100.94786834716797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:48:00.000' AS DateTime), 100.15132141113281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:52:00.000' AS DateTime), 99.635734558105469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T14:56:00.000' AS DateTime), 98.421173095703125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:00:00.000' AS DateTime), 99.112716674804688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:04:00.000' AS DateTime), 97.920440673828125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:08:00.000' AS DateTime), 98.2594223022461)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:12:00.000' AS DateTime), 98.404747009277344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:16:00.000' AS DateTime), 97.056480407714844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:20:00.000' AS DateTime), 96.709701538085938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:24:00.000' AS DateTime), 95.759483337402344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:28:00.000' AS DateTime), 96.4208984375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:32:00.000' AS DateTime), 95.789031982421875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:36:00.000' AS DateTime), 95.953948974609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:40:00.000' AS DateTime), 97.1457290649414)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:44:00.000' AS DateTime), 97.309432983398438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:48:00.000' AS DateTime), 94.555145263671875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:52:00.000' AS DateTime), 95.827926635742188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T15:56:00.000' AS DateTime), 94.267852783203125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:00:00.000' AS DateTime), 95.889999389648438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:04:00.000' AS DateTime), 95.714431762695312)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:08:00.000' AS DateTime), 94.05120849609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:12:00.000' AS DateTime), 95.280410766601562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:16:00.000' AS DateTime), 94.277107238769531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:20:00.000' AS DateTime), 92.461357116699219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:24:00.000' AS DateTime), 92.593223571777344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:28:00.000' AS DateTime), 93.9677734375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:32:00.000' AS DateTime), 94.235076904296875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:36:00.000' AS DateTime), 94.340194702148438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:40:00.000' AS DateTime), 92.70318603515625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:44:00.000' AS DateTime), 92.374114990234375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:48:00.000' AS DateTime), 91.793037414550781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:52:00.000' AS DateTime), 91.385025024414062)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T16:56:00.000' AS DateTime), 91.990127563476562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:00:00.000' AS DateTime), 90.828399658203125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:04:00.000' AS DateTime), 91.984901428222656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:08:00.000' AS DateTime), 90.074691772460938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:12:00.000' AS DateTime), 90.687828063964844)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:16:00.000' AS DateTime), 90.659355163574219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:20:00.000' AS DateTime), 90.434333801269531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:24:00.000' AS DateTime), 91.707809448242188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:28:00.000' AS DateTime), 89.204841613769531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:32:00.000' AS DateTime), 89.320465087890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:36:00.000' AS DateTime), 89.4647445678711)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:40:00.000' AS DateTime), 91.657722473144531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:44:00.000' AS DateTime), 90.529434204101562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:48:00.000' AS DateTime), 89.354942321777344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:52:00.000' AS DateTime), 89.8592758178711)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T17:56:00.000' AS DateTime), 89.557487487792969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:00:00.000' AS DateTime), 88.554618835449219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:04:00.000' AS DateTime), 90.4957046508789)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:08:00.000' AS DateTime), 88.2057876586914)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:12:00.000' AS DateTime), 90.054901123046875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:16:00.000' AS DateTime), 88.773086547851562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:20:00.000' AS DateTime), 89.105384826660156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:24:00.000' AS DateTime), 87.8868179321289)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:28:00.000' AS DateTime), 88.687423706054688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:32:00.000' AS DateTime), 88.562240600585938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:36:00.000' AS DateTime), 88.871292114257812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:40:00.000' AS DateTime), 87.994613647460938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:44:00.000' AS DateTime), 87.137222290039062)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:48:00.000' AS DateTime), 86.814155578613281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:52:00.000' AS DateTime), 88.0904312133789)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T18:56:00.000' AS DateTime), 88.6260757446289)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:00:00.000' AS DateTime), 86.511116027832031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:04:00.000' AS DateTime), 88.920562744140625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:08:00.000' AS DateTime), 87.754447937011719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:12:00.000' AS DateTime), 87.587783813476562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:16:00.000' AS DateTime), 88.685592651367188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:20:00.000' AS DateTime), 89.217880249023438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:24:00.000' AS DateTime), 88.799674987792969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:28:00.000' AS DateTime), 87.0009765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:32:00.000' AS DateTime), 87.446807861328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:36:00.000' AS DateTime), 88.637168884277344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:40:00.000' AS DateTime), 88.2770767211914)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:44:00.000' AS DateTime), 88.996536254882812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:48:00.000' AS DateTime), 87.025558471679688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:52:00.000' AS DateTime), 86.164138793945312)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T19:56:00.000' AS DateTime), 87.9422836303711)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:00:00.000' AS DateTime), 88.5199966430664)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:04:00.000' AS DateTime), 86.977287292480469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:08:00.000' AS DateTime), 88.549140930175781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:12:00.000' AS DateTime), 88.515556335449219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:16:00.000' AS DateTime), 88.896537780761719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:20:00.000' AS DateTime), 88.172080993652344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:24:00.000' AS DateTime), 87.2471694946289)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:28:00.000' AS DateTime), 87.816810607910156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:32:00.000' AS DateTime), 88.5259780883789)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:36:00.000' AS DateTime), 86.4146728515625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:40:00.000' AS DateTime), 88.162879943847656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:44:00.000' AS DateTime), 89.2105941772461)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:48:00.000' AS DateTime), 88.202789306640625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:52:00.000' AS DateTime), 88.814445495605469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T20:56:00.000' AS DateTime), 87.845565795898438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:00:00.000' AS DateTime), 87.14111328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:04:00.000' AS DateTime), 88.086074829101562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:08:00.000' AS DateTime), 88.185432434082031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:12:00.000' AS DateTime), 88.204154968261719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:16:00.000' AS DateTime), 87.942222595214844)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:20:00.000' AS DateTime), 87.2046127319336)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:24:00.000' AS DateTime), 88.921295166015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:28:00.000' AS DateTime), 88.997245788574219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:32:00.000' AS DateTime), 87.667427062988281)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:36:00.000' AS DateTime), 87.351821899414062)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:40:00.000' AS DateTime), 89.460380554199219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:44:00.000' AS DateTime), 87.9380874633789)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:48:00.000' AS DateTime), 88.869903564453125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:52:00.000' AS DateTime), 89.475784301757812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T21:56:00.000' AS DateTime), 90.855705261230469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:00:00.000' AS DateTime), 89.219619750976562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:04:00.000' AS DateTime), 88.977493286132812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:08:00.000' AS DateTime), 88.69927978515625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:12:00.000' AS DateTime), 89.229942321777344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:16:00.000' AS DateTime), 91.144439697265625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:20:00.000' AS DateTime), 91.59771728515625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:24:00.000' AS DateTime), 90.184745788574219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:28:00.000' AS DateTime), 89.73046875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:32:00.000' AS DateTime), 90.254837036132812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:36:00.000' AS DateTime), 90.082809448242188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:40:00.000' AS DateTime), 89.899330139160156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:44:00.000' AS DateTime), 91.789360046386719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:48:00.000' AS DateTime), 92.847824096679688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:52:00.000' AS DateTime), 92.4596939086914)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T22:56:00.000' AS DateTime), 90.529899597167969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:00:00.000' AS DateTime), 93.188400268554688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:04:00.000' AS DateTime), 91.910125732421875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:08:00.000' AS DateTime), 91.540023803710938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:12:00.000' AS DateTime), 92.873039245605469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:16:00.000' AS DateTime), 92.464111328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:20:00.000' AS DateTime), 92.333183288574219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:24:00.000' AS DateTime), 92.040191650390625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:28:00.000' AS DateTime), 94.535079956054688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:32:00.000' AS DateTime), 94.562774658203125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:36:00.000' AS DateTime), 92.663223266601562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:40:00.000' AS DateTime), 93.601356506347656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:44:00.000' AS DateTime), 92.8871078491211)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:48:00.000' AS DateTime), 93.745414733886719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:52:00.000' AS DateTime), 95.0962142944336)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-03T23:56:00.000' AS DateTime), 94.634429931640625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:00:00.000' AS DateTime), 95.25)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:04:00.000' AS DateTime), 94.882858276367188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:08:00.000' AS DateTime), 94.862930297851562)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:12:00.000' AS DateTime), 95.065139770507812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:16:00.000' AS DateTime), 96.254432678222656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:20:00.000' AS DateTime), 97.290725708007812)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:24:00.000' AS DateTime), 95.98895263671875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:28:00.000' AS DateTime), 95.604034423828125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:32:00.000' AS DateTime), 95.895904541015625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:36:00.000' AS DateTime), 96.999481201171875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:40:00.000' AS DateTime), 97.99969482421875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:44:00.000' AS DateTime), 96.961479187011719)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:48:00.000' AS DateTime), 98.204742431640625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:52:00.000' AS DateTime), 97.1344223022461)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T00:56:00.000' AS DateTime), 99.4254379272461)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:00:00.000' AS DateTime), 98.622711181640625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:04:00.000' AS DateTime), 98.576171875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:08:00.000' AS DateTime), 98.410736083984375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:12:00.000' AS DateTime), 99.726325988769531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:16:00.000' AS DateTime), 100.26786804199219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:20:00.000' AS DateTime), 99.415275573730469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:24:00.000' AS DateTime), 100.35848236083984)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:28:00.000' AS DateTime), 99.922401428222656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:32:00.000' AS DateTime), 99.641960144042969)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:36:00.000' AS DateTime), 100.43207550048828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:40:00.000' AS DateTime), 101.46766662597656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:44:00.000' AS DateTime), 100.58865356445313)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:48:00.000' AS DateTime), 101.40995788574219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:52:00.000' AS DateTime), 101.2965087890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T01:56:00.000' AS DateTime), 103.293212890625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:00:00.000' AS DateTime), 103.34999847412109)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:04:00.000' AS DateTime), 103.75678253173828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:08:00.000' AS DateTime), 104.22849273681641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:12:00.000' AS DateTime), 102.35504150390625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:16:00.000' AS DateTime), 102.13134765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:20:00.000' AS DateTime), 104.20233917236328)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:24:00.000' AS DateTime), 104.43792724609375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:28:00.000' AS DateTime), 103.00303649902344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:32:00.000' AS DateTime), 104.97760009765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:36:00.000' AS DateTime), 105.95151519775391)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:40:00.000' AS DateTime), 103.89472198486328)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:44:00.000' AS DateTime), 104.30213165283203)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:48:00.000' AS DateTime), 106.39867401123047)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:52:00.000' AS DateTime), 105.12926483154297)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T02:56:00.000' AS DateTime), 107.07882690429688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:00:00.000' AS DateTime), 105.76728820800781)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:04:00.000' AS DateTime), 105.64456176757813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:08:00.000' AS DateTime), 106.84557342529297)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:12:00.000' AS DateTime), 107.50025177001953)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:16:00.000' AS DateTime), 107.01351928710938)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:20:00.000' AS DateTime), 107.53030395507813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:24:00.000' AS DateTime), 106.93051910400391)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:28:00.000' AS DateTime), 109.55410003662109)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:32:00.000' AS DateTime), 107.31096649169922)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:36:00.000' AS DateTime), 107.54104614257813)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:40:00.000' AS DateTime), 108.37427520751953)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:44:00.000' AS DateTime), 109.25056457519531)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:48:00.000' AS DateTime), 110.18985748291016)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:52:00.000' AS DateTime), 110.32707214355469)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T03:56:00.000' AS DateTime), 109.90714263916016)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:00:00.000' AS DateTime), 108.96499633789063)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:04:00.000' AS DateTime), 109.31557464599609)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:08:00.000' AS DateTime), 111.36878967285156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:12:00.000' AS DateTime), 111.76458740234375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:16:00.000' AS DateTime), 110.22289276123047)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:20:00.000' AS DateTime), 111.27364349365234)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:24:00.000' AS DateTime), 111.56177520751953)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:28:00.000' AS DateTime), 110.27222442626953)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:32:00.000' AS DateTime), 110.68991851806641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:36:00.000' AS DateTime), 112.86980438232422)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:40:00.000' AS DateTime), 111.13181304931641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:44:00.000' AS DateTime), 111.71088409423828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:48:00.000' AS DateTime), 112.43196105957031)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:52:00.000' AS DateTime), 111.85997772216797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T04:56:00.000' AS DateTime), 111.65987396240234)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:00:00.000' AS DateTime), 112.12660217285156)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:04:00.000' AS DateTime), 113.51009368896484)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:08:00.000' AS DateTime), 114.74030303955078)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:12:00.000' AS DateTime), 114.11217498779297)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:16:00.000' AS DateTime), 114.48564147949219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:20:00.000' AS DateTime), 114.67566680908203)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:24:00.000' AS DateTime), 115.42218780517578)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:28:00.000' AS DateTime), 113.66016387939453)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:32:00.000' AS DateTime), 115.33453369140625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:36:00.000' AS DateTime), 116.07525634765625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:40:00.000' AS DateTime), 113.8372802734375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:44:00.000' AS DateTime), 114.47556304931641)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:48:00.000' AS DateTime), 114.04006195068359)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:52:00.000' AS DateTime), 115.55072021484375)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T05:56:00.000' AS DateTime), 116.21250915527344)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:00:00.000' AS DateTime), 116.85538482666016)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:04:00.000' AS DateTime), 115.98929595947266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:08:00.000' AS DateTime), 116.38921356201172)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:12:00.000' AS DateTime), 115.68509674072266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:16:00.000' AS DateTime), 117.23690795898438)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:20:00.000' AS DateTime), 115.26461791992188)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:24:00.000' AS DateTime), 116.58818054199219)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:28:00.000' AS DateTime), 115.23757171630859)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:32:00.000' AS DateTime), 117.43775939941406)
GO
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:36:00.000' AS DateTime), 117.30370330810547)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:40:00.000' AS DateTime), 115.89038848876953)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:44:00.000' AS DateTime), 117.43277740478516)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:48:00.000' AS DateTime), 116.6158447265625)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:52:00.000' AS DateTime), 117.09957122802734)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T06:56:00.000' AS DateTime), 116.39892578125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:00:00.000' AS DateTime), 116.01388549804688)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:04:00.000' AS DateTime), 115.91443634033203)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:08:00.000' AS DateTime), 118.20555114746094)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:12:00.000' AS DateTime), 116.70721435546875)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:16:00.000' AS DateTime), 115.87440490722656)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:20:00.000' AS DateTime), 116.01711273193359)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:24:00.000' AS DateTime), 117.60032653808594)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:28:00.000' AS DateTime), 116.97402191162109)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:32:00.000' AS DateTime), 116.07318878173828)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:36:00.000' AS DateTime), 117.53282928466797)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:40:00.000' AS DateTime), 118.18292236328125)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:44:00.000' AS DateTime), 118.82346343994141)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:48:00.000' AS DateTime), 118.28444671630859)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:52:00.000' AS DateTime), 118.32585906982422)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T07:56:00.000' AS DateTime), 116.86771392822266)
INSERT [dbo].[CompressedPoints] ([tag], [time], [value]) VALUES (N'chamber_report_tag_1', CAST(N'2022-11-04T08:00:00.000' AS DateTime), 117.30999755859375)
GO
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:00:00.0000000' AS DateTime2), 114.84999847412109)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:01:00.0000000' AS DateTime2), 115.36837768554688)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:02:00.0000000' AS DateTime2), 115.77350616455078)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:03:00.0000000' AS DateTime2), 118.83537292480469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:04:00.0000000' AS DateTime2), 114.74398040771484)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:05:00.0000000' AS DateTime2), 119.88928985595703)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:06:00.0000000' AS DateTime2), 115.35129547119141)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:07:00.0000000' AS DateTime2), 119.06996154785156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:08:00.0000000' AS DateTime2), 115.39525604248047)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:09:00.0000000' AS DateTime2), 119.25714111328125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:10:00.0000000' AS DateTime2), 115.8355712890625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:11:00.0000000' AS DateTime2), 118.72050476074219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:12:00.0000000' AS DateTime2), 118.63188171386719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:13:00.0000000' AS DateTime2), 116.10964965820313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:14:00.0000000' AS DateTime2), 117.22373199462891)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:15:00.0000000' AS DateTime2), 117.86408233642578)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:16:00.0000000' AS DateTime2), 119.81060791015625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:17:00.0000000' AS DateTime2), 118.84323883056641)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:18:00.0000000' AS DateTime2), 119.49188995361328)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:19:00.0000000' AS DateTime2), 120.92647552490234)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:20:00.0000000' AS DateTime2), 119.97690582275391)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:21:00.0000000' AS DateTime2), 118.21307373046875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:22:00.0000000' AS DateTime2), 118.50489044189453)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:23:00.0000000' AS DateTime2), 123.28223419189453)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:24:00.0000000' AS DateTime2), 122.11499786376953)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:25:00.0000000' AS DateTime2), 121.5230712890625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:26:00.0000000' AS DateTime2), 124.39632415771484)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:27:00.0000000' AS DateTime2), 120.504638671875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:28:00.0000000' AS DateTime2), 124.69788360595703)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:29:00.0000000' AS DateTime2), 125.16591644287109)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:30:00.0000000' AS DateTime2), 124.38860321044922)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:31:00.0000000' AS DateTime2), 127.95579528808594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:32:00.0000000' AS DateTime2), 123.82735443115234)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:33:00.0000000' AS DateTime2), 123.67311859130859)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:34:00.0000000' AS DateTime2), 123.90293121337891)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:35:00.0000000' AS DateTime2), 126.00663757324219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:36:00.0000000' AS DateTime2), 125.38406372070313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:37:00.0000000' AS DateTime2), 128.8050537109375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:38:00.0000000' AS DateTime2), 130.79940795898438)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:39:00.0000000' AS DateTime2), 132.64697265625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:40:00.0000000' AS DateTime2), 130.03755187988281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:41:00.0000000' AS DateTime2), 128.08097839355469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:42:00.0000000' AS DateTime2), 128.79702758789063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:43:00.0000000' AS DateTime2), 131.23554992675781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:44:00.0000000' AS DateTime2), 132.36631774902344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:45:00.0000000' AS DateTime2), 133.27912902832031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:46:00.0000000' AS DateTime2), 132.81379699707031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:47:00.0000000' AS DateTime2), 133.65008544921875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:48:00.0000000' AS DateTime2), 136.33781433105469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:49:00.0000000' AS DateTime2), 139.24674987792969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:50:00.0000000' AS DateTime2), 134.4666748046875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:51:00.0000000' AS DateTime2), 135.807373046875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:52:00.0000000' AS DateTime2), 136.72862243652344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:53:00.0000000' AS DateTime2), 136.70018005371094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:54:00.0000000' AS DateTime2), 138.03181457519531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:55:00.0000000' AS DateTime2), 141.42329406738281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:56:00.0000000' AS DateTime2), 143.06439208984375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:57:00.0000000' AS DateTime2), 142.28485107421875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:58:00.0000000' AS DateTime2), 141.98443603515625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T10:59:00.0000000' AS DateTime2), 146.71290588378906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:00:00.0000000' AS DateTime2), 147.77999877929688)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:01:00.0000000' AS DateTime2), 143.84547424316406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:02:00.0000000' AS DateTime2), 149.54905700683594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:03:00.0000000' AS DateTime2), 145.43052673339844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:04:00.0000000' AS DateTime2), 150.75958251953125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:05:00.0000000' AS DateTime2), 146.44599914550781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:06:00.0000000' AS DateTime2), 147.15948486328125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:07:00.0000000' AS DateTime2), 152.47978210449219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:08:00.0000000' AS DateTime2), 152.65663146972656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:09:00.0000000' AS DateTime2), 149.90975952148438)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:10:00.0000000' AS DateTime2), 153.95889282226563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:11:00.0000000' AS DateTime2), 155.82374572753906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:12:00.0000000' AS DateTime2), 157.37406921386719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:13:00.0000000' AS DateTime2), 155.70954895019531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:14:00.0000000' AS DateTime2), 159.93994140625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:15:00.0000000' AS DateTime2), 159.04495239257813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:16:00.0000000' AS DateTime2), 159.75430297851563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:17:00.0000000' AS DateTime2), 160.92768859863281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:18:00.0000000' AS DateTime2), 159.03485107421875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:19:00.0000000' AS DateTime2), 163.60549926757813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:20:00.0000000' AS DateTime2), 162.56935119628906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:21:00.0000000' AS DateTime2), 164.8861083984375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:22:00.0000000' AS DateTime2), 167.84547424316406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:23:00.0000000' AS DateTime2), 163.20718383789063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:24:00.0000000' AS DateTime2), 165.47093200683594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:25:00.0000000' AS DateTime2), 169.39643859863281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:26:00.0000000' AS DateTime2), 169.68339538574219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:27:00.0000000' AS DateTime2), 168.03152465820313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:28:00.0000000' AS DateTime2), 172.25053405761719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:29:00.0000000' AS DateTime2), 169.08012390136719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:30:00.0000000' AS DateTime2), 170.52000427246094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:31:00.0000000' AS DateTime2), 171.61988830566406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:32:00.0000000' AS DateTime2), 176.63946533203125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:33:00.0000000' AS DateTime2), 175.28848266601563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:34:00.0000000' AS DateTime2), 175.18659973144531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:35:00.0000000' AS DateTime2), 177.38356018066406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:36:00.0000000' AS DateTime2), 175.4190673828125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:37:00.0000000' AS DateTime2), 180.39280700683594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:38:00.0000000' AS DateTime2), 180.06451416015625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:39:00.0000000' AS DateTime2), 181.80389404296875)
GO
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:40:00.0000000' AS DateTime2), 180.70065307617188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:41:00.0000000' AS DateTime2), 184.26449584960938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:42:00.0000000' AS DateTime2), 186.16514587402344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:43:00.0000000' AS DateTime2), 187.82231140136719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:44:00.0000000' AS DateTime2), 184.86570739746094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:45:00.0000000' AS DateTime2), 186.13504028320313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:46:00.0000000' AS DateTime2), 185.85005187988281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:47:00.0000000' AS DateTime2), 186.3304443359375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:48:00.0000000' AS DateTime2), 186.75593566894531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:49:00.0000000' AS DateTime2), 187.74624633789063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:50:00.0000000' AS DateTime2), 190.60110473632813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:51:00.0000000' AS DateTime2), 191.990234375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:52:00.0000000' AS DateTime2), 194.11335754394531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:53:00.0000000' AS DateTime2), 195.25021362304688)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:54:00.0000000' AS DateTime2), 192.4105224609375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:55:00.0000000' AS DateTime2), 195.59400939941406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:56:00.0000000' AS DateTime2), 198.08041381835938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:57:00.0000000' AS DateTime2), 197.78947448730469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:58:00.0000000' AS DateTime2), 198.60093688964844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T11:59:00.0000000' AS DateTime2), 198.61453247070313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:00:00.0000000' AS DateTime2), 197.1300048828125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:01:00.0000000' AS DateTime2), 201.42709350585938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:02:00.0000000' AS DateTime2), 199.93556213378906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:03:00.0000000' AS DateTime2), 205.44514465332031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:04:00.0000000' AS DateTime2), 200.35560607910156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:05:00.0000000' AS DateTime2), 203.17669677734375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:06:00.0000000' AS DateTime2), 204.59819030761719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:07:00.0000000' AS DateTime2), 205.50982666015625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:08:00.0000000' AS DateTime2), 205.14138793945313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:09:00.0000000' AS DateTime2), 205.75262451171875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:10:00.0000000' AS DateTime2), 205.88331604003906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:11:00.0000000' AS DateTime2), 208.79324340820313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:12:00.0000000' AS DateTime2), 207.92218017578125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:13:00.0000000' AS DateTime2), 210.95991516113281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:14:00.0000000' AS DateTime2), 209.44621276855469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:15:00.0000000' AS DateTime2), 212.25086975097656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:16:00.0000000' AS DateTime2), 212.18368530273438)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:17:00.0000000' AS DateTime2), 214.72445678710938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:18:00.0000000' AS DateTime2), 210.61296081542969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:19:00.0000000' AS DateTime2), 214.30902099609375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:20:00.0000000' AS DateTime2), 213.6324462890625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:21:00.0000000' AS DateTime2), 216.28303527832031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:22:00.0000000' AS DateTime2), 215.70059204101563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:23:00.0000000' AS DateTime2), 217.05494689941406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:24:00.0000000' AS DateTime2), 215.9559326171875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:25:00.0000000' AS DateTime2), 219.76336669921875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:26:00.0000000' AS DateTime2), 220.19706726074219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:27:00.0000000' AS DateTime2), 216.056884765625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:28:00.0000000' AS DateTime2), 218.03263854980469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:29:00.0000000' AS DateTime2), 219.96420288085938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:30:00.0000000' AS DateTime2), 222.08139038085938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:31:00.0000000' AS DateTime2), 221.18408203125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:32:00.0000000' AS DateTime2), 221.31211853027344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:33:00.0000000' AS DateTime2), 218.6253662109375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:34:00.0000000' AS DateTime2), 223.86367797851563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:35:00.0000000' AS DateTime2), 222.11692810058594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:36:00.0000000' AS DateTime2), 222.22500610351563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:37:00.0000000' AS DateTime2), 223.07777404785156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:38:00.0000000' AS DateTime2), 226.22511291503906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:39:00.0000000' AS DateTime2), 224.70692443847656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:40:00.0000000' AS DateTime2), 224.61309814453125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:41:00.0000000' AS DateTime2), 222.99351501464844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:42:00.0000000' AS DateTime2), 225.64810180664063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:43:00.0000000' AS DateTime2), 224.46676635742188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:44:00.0000000' AS DateTime2), 225.72940063476563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:45:00.0000000' AS DateTime2), 226.25592041015625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:46:00.0000000' AS DateTime2), 226.98626708984375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:47:00.0000000' AS DateTime2), 226.53034973144531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:48:00.0000000' AS DateTime2), 225.48811340332031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:49:00.0000000' AS DateTime2), 225.18949890136719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:50:00.0000000' AS DateTime2), 227.36442565917969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:51:00.0000000' AS DateTime2), 227.8028564453125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:52:00.0000000' AS DateTime2), 226.63475036621094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:53:00.0000000' AS DateTime2), 227.30003356933594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:54:00.0000000' AS DateTime2), 226.34870910644531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:55:00.0000000' AS DateTime2), 228.51071166992188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:56:00.0000000' AS DateTime2), 225.83602905273438)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:57:00.0000000' AS DateTime2), 230.41462707519531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:58:00.0000000' AS DateTime2), 228.906494140625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T12:59:00.0000000' AS DateTime2), 225.40162658691406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:00:00.0000000' AS DateTime2), 229.66000366210938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:01:00.0000000' AS DateTime2), 227.13162231445313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:02:00.0000000' AS DateTime2), 227.48649597167969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:03:00.0000000' AS DateTime2), 224.87461853027344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:04:00.0000000' AS DateTime2), 227.76602172851563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:05:00.0000000' AS DateTime2), 224.96070861816406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:06:00.0000000' AS DateTime2), 229.0487060546875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:07:00.0000000' AS DateTime2), 228.7900390625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:08:00.0000000' AS DateTime2), 226.12474060058594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:09:00.0000000' AS DateTime2), 225.45286560058594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:10:00.0000000' AS DateTime2), 224.75442504882813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:11:00.0000000' AS DateTime2), 226.05949401855469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:12:00.0000000' AS DateTime2), 227.51811218261719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:13:00.0000000' AS DateTime2), 225.17034912109375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:14:00.0000000' AS DateTime2), 228.31626892089844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:15:00.0000000' AS DateTime2), 226.46592712402344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:16:00.0000000' AS DateTime2), 225.39939880371094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:17:00.0000000' AS DateTime2), 227.65676879882813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:18:00.0000000' AS DateTime2), 223.39810180664063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:19:00.0000000' AS DateTime2), 224.80352783203125)
GO
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:20:00.0000000' AS DateTime2), 225.81309509277344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:21:00.0000000' AS DateTime2), 222.29692077636719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:22:00.0000000' AS DateTime2), 221.89511108398438)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:23:00.0000000' AS DateTime2), 220.457763671875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:24:00.0000000' AS DateTime2), 223.42500305175781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:25:00.0000000' AS DateTime2), 223.64692687988281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:26:00.0000000' AS DateTime2), 223.8836669921875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:27:00.0000000' AS DateTime2), 224.245361328125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:28:00.0000000' AS DateTime2), 223.72212219238281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:29:00.0000000' AS DateTime2), 218.58409118652344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:30:00.0000000' AS DateTime2), 217.48139953613281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:31:00.0000000' AS DateTime2), 219.27420043945313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:32:00.0000000' AS DateTime2), 220.32264709472656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:33:00.0000000' AS DateTime2), 218.53688049316406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:34:00.0000000' AS DateTime2), 219.737060546875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:35:00.0000000' AS DateTime2), 217.49336242675781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:36:00.0000000' AS DateTime2), 219.89593505859375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:37:00.0000000' AS DateTime2), 217.54495239257813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:38:00.0000000' AS DateTime2), 217.39059448242188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:39:00.0000000' AS DateTime2), 213.16302490234375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:40:00.0000000' AS DateTime2), 217.48243713378906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:41:00.0000000' AS DateTime2), 214.06903076171875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:42:00.0000000' AS DateTime2), 215.36296081542969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:43:00.0000000' AS DateTime2), 210.41445922851563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:44:00.0000000' AS DateTime2), 211.51368713378906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:45:00.0000000' AS DateTime2), 209.15087890625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:46:00.0000000' AS DateTime2), 209.42620849609375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:47:00.0000000' AS DateTime2), 208.2899169921875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:48:00.0000000' AS DateTime2), 210.12217712402344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:49:00.0000000' AS DateTime2), 207.84324645996094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:50:00.0000000' AS DateTime2), 209.48332214355469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:51:00.0000000' AS DateTime2), 206.72262573242188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:52:00.0000000' AS DateTime2), 209.33137512207031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:53:00.0000000' AS DateTime2), 205.26982116699219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:54:00.0000000' AS DateTime2), 202.75819396972656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:55:00.0000000' AS DateTime2), 206.50669860839844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:56:00.0000000' AS DateTime2), 202.60560607910156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:57:00.0000000' AS DateTime2), 203.80514526367188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:58:00.0000000' AS DateTime2), 198.72555541992188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T13:59:00.0000000' AS DateTime2), 197.86709594726563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:00:00.0000000' AS DateTime2), 201.47000122070313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:01:00.0000000' AS DateTime2), 198.99452209472656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:02:00.0000000' AS DateTime2), 195.93093872070313)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:03:00.0000000' AS DateTime2), 194.66947937011719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:04:00.0000000' AS DateTime2), 199.36041259765625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:05:00.0000000' AS DateTime2), 197.66400146484375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:06:00.0000000' AS DateTime2), 195.71051025390625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:07:00.0000000' AS DateTime2), 191.82020568847656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:08:00.0000000' AS DateTime2), 193.28335571289063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:09:00.0000000' AS DateTime2), 190.32023620605469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:10:00.0000000' AS DateTime2), 189.08110046386719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:11:00.0000000' AS DateTime2), 192.07624816894531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:12:00.0000000' AS DateTime2), 190.62593078613281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:13:00.0000000' AS DateTime2), 189.42044067382813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:14:00.0000000' AS DateTime2), 186.64006042480469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:15:00.0000000' AS DateTime2), 188.06504821777344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:16:00.0000000' AS DateTime2), 188.095703125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:17:00.0000000' AS DateTime2), 186.92230224609375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:18:00.0000000' AS DateTime2), 183.15513610839844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:19:00.0000000' AS DateTime2), 184.8544921875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:20:00.0000000' AS DateTime2), 180.78065490722656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:21:00.0000000' AS DateTime2), 181.243896484375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:22:00.0000000' AS DateTime2), 180.5145263671875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:23:00.0000000' AS DateTime2), 177.36280822753906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:24:00.0000000' AS DateTime2), 178.42906188964844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:25:00.0000000' AS DateTime2), 176.74356079101563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:26:00.0000000' AS DateTime2), 173.49661254882813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:27:00.0000000' AS DateTime2), 174.07847595214844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:28:00.0000000' AS DateTime2), 173.34947204589844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:29:00.0000000' AS DateTime2), 172.7598876953125)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:30:00.0000000' AS DateTime2), 171.27000427246094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:31:00.0000000' AS DateTime2), 172.90011596679688)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:32:00.0000000' AS DateTime2), 172.13052368164063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:33:00.0000000' AS DateTime2), 167.88151550292969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:34:00.0000000' AS DateTime2), 171.59339904785156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:35:00.0000000' AS DateTime2), 169.81643676757813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:36:00.0000000' AS DateTime2), 163.85093688964844)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:37:00.0000000' AS DateTime2), 164.4871826171875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:38:00.0000000' AS DateTime2), 166.87547302246094)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:39:00.0000000' AS DateTime2), 161.39610290527344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:40:00.0000000' AS DateTime2), 159.96934509277344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:41:00.0000000' AS DateTime2), 164.7655029296875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:42:00.0000000' AS DateTime2), 163.32485961914063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:43:00.0000000' AS DateTime2), 162.76768493652344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:44:00.0000000' AS DateTime2), 160.19429016113281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:45:00.0000000' AS DateTime2), 160.02494812011719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:46:00.0000000' AS DateTime2), 159.83995056152344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:47:00.0000000' AS DateTime2), 153.6695556640625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:48:00.0000000' AS DateTime2), 155.76406860351563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:49:00.0000000' AS DateTime2), 155.19375610351563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:50:00.0000000' AS DateTime2), 156.04888916015625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:51:00.0000000' AS DateTime2), 155.54975891113281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:52:00.0000000' AS DateTime2), 151.43663024902344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:53:00.0000000' AS DateTime2), 151.23979187011719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:54:00.0000000' AS DateTime2), 148.55947875976563)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:55:00.0000000' AS DateTime2), 149.81599426269531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:56:00.0000000' AS DateTime2), 150.68959045410156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:57:00.0000000' AS DateTime2), 146.87052917480469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:58:00.0000000' AS DateTime2), 149.59906005859375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T14:59:00.0000000' AS DateTime2), 148.37547302246094)
GO
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:00:00.0000000' AS DateTime2), 146.57000732421875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:01:00.0000000' AS DateTime2), 142.6029052734375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:02:00.0000000' AS DateTime2), 144.95443725585938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:03:00.0000000' AS DateTime2), 139.87484741210938)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:04:00.0000000' AS DateTime2), 144.08439636230469)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:05:00.0000000' AS DateTime2), 140.7532958984375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:06:00.0000000' AS DateTime2), 142.99180603027344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:07:00.0000000' AS DateTime2), 139.98017883300781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:08:00.0000000' AS DateTime2), 138.76861572265625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:09:00.0000000' AS DateTime2), 138.41737365722656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:10:00.0000000' AS DateTime2), 138.28668212890625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:11:00.0000000' AS DateTime2), 136.38674926757813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:12:00.0000000' AS DateTime2), 134.65782165527344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:13:00.0000000' AS DateTime2), 136.02009582519531)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:14:00.0000000' AS DateTime2), 133.0037841796875)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:15:00.0000000' AS DateTime2), 136.58912658691406)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:16:00.0000000' AS DateTime2), 132.17631530761719)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:17:00.0000000' AS DateTime2), 131.98554992675781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:18:00.0000000' AS DateTime2), 130.717041015625)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:19:00.0000000' AS DateTime2), 131.79096984863281)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:20:00.0000000' AS DateTime2), 131.72755432128906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:21:00.0000000' AS DateTime2), 128.65696716308594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:22:00.0000000' AS DateTime2), 128.84941101074219)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:23:00.0000000' AS DateTime2), 127.53504943847656)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:24:00.0000000' AS DateTime2), 126.06406402587891)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:25:00.0000000' AS DateTime2), 130.12663269042969)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:26:00.0000000' AS DateTime2), 124.36293029785156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:27:00.0000000' AS DateTime2), 125.12311553955078)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:28:00.0000000' AS DateTime2), 126.12735748291016)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:29:00.0000000' AS DateTime2), 124.42579650878906)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:30:00.0000000' AS DateTime2), 125.53860473632813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:31:00.0000000' AS DateTime2), 121.57591247558594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:32:00.0000000' AS DateTime2), 126.00788116455078)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:33:00.0000000' AS DateTime2), 122.62464141845703)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:34:00.0000000' AS DateTime2), 120.11632537841797)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:35:00.0000000' AS DateTime2), 124.43307495117188)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:36:00.0000000' AS DateTime2), 124.18499755859375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:37:00.0000000' AS DateTime2), 122.71223449707031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:38:00.0000000' AS DateTime2), 119.62488555908203)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:39:00.0000000' AS DateTime2), 120.58307647705078)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:40:00.0000000' AS DateTime2), 121.71690368652344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:41:00.0000000' AS DateTime2), 121.136474609375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:42:00.0000000' AS DateTime2), 122.45188903808594)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:43:00.0000000' AS DateTime2), 120.54323577880859)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:44:00.0000000' AS DateTime2), 117.67060852050781)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:45:00.0000000' AS DateTime2), 121.86408233642578)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:46:00.0000000' AS DateTime2), 118.02373504638672)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:47:00.0000000' AS DateTime2), 120.59964752197266)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:48:00.0000000' AS DateTime2), 120.89188385009766)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:49:00.0000000' AS DateTime2), 116.04050445556641)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:50:00.0000000' AS DateTime2), 116.35557556152344)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:51:00.0000000' AS DateTime2), 120.07714080810547)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:52:00.0000000' AS DateTime2), 119.99525451660156)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:53:00.0000000' AS DateTime2), 120.71996307373047)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:54:00.0000000' AS DateTime2), 118.79129791259766)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:55:00.0000000' AS DateTime2), 115.36929321289063)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:56:00.0000000' AS DateTime2), 118.58397674560547)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:57:00.0000000' AS DateTime2), 119.43537902832031)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:58:00.0000000' AS DateTime2), 118.81350708007813)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T15:59:00.0000000' AS DateTime2), 120.14837646484375)
INSERT [dbo].[HiExcursion] ([XdateStr], [FSValN]) VALUES (CAST(N'2022-11-01T16:00:00.0000000' AS DateTime2), 117.05999755859375)
GO
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:00:00.0000000' AS DateTime2), 116.64499664306641)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:04:00.0000000' AS DateTime2), 116.08771514892578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:08:00.0000000' AS DateTime2), 116.48586273193359)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:12:00.0000000' AS DateTime2), 118.85944366455078)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:16:00.0000000' AS DateTime2), 118.25846099853516)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:20:00.0000000' AS DateTime2), 118.40292358398438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:24:00.0000000' AS DateTime2), 116.84282684326172)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:28:00.0000000' AS DateTime2), 117.75819396972656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:32:00.0000000' AS DateTime2), 117.66902160644531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:36:00.0000000' AS DateTime2), 116.12532806396484)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:40:00.0000000' AS DateTime2), 118.14711761474609)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:44:00.0000000' AS DateTime2), 115.91440582275391)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:48:00.0000000' AS DateTime2), 116.35721588134766)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:52:00.0000000' AS DateTime2), 118.23055267333984)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T08:56:00.0000000' AS DateTime2), 115.77943420410156)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:00:00.0000000' AS DateTime2), 115.87388610839844)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:04:00.0000000' AS DateTime2), 117.70392608642578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:08:00.0000000' AS DateTime2), 118.11956787109375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:12:00.0000000' AS DateTime2), 116.91085052490234)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:16:00.0000000' AS DateTime2), 116.76777648925781)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:20:00.0000000' AS DateTime2), 116.98538970947266)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:24:00.0000000' AS DateTime2), 117.47370910644531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:28:00.0000000' AS DateTime2), 115.68775939941406)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:32:00.0000000' AS DateTime2), 116.19257354736328)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:36:00.0000000' AS DateTime2), 115.61817932128906)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:40:00.0000000' AS DateTime2), 117.41461944580078)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:44:00.0000000' AS DateTime2), 115.38690948486328)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:48:00.0000000' AS DateTime2), 116.07009887695313)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:52:00.0000000' AS DateTime2), 114.47921752929688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T09:56:00.0000000' AS DateTime2), 114.36929321289063)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:00:00.0000000' AS DateTime2), 116.78038024902344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:04:00.0000000' AS DateTime2), 116.40750885009766)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:08:00.0000000' AS DateTime2), 114.92072296142578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:12:00.0000000' AS DateTime2), 115.07006072998047)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:16:00.0000000' AS DateTime2), 114.22556304931641)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:20:00.0000000' AS DateTime2), 114.18727874755859)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:24:00.0000000' AS DateTime2), 113.34525299072266)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:28:00.0000000' AS DateTime2), 113.79453277587891)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:32:00.0000000' AS DateTime2), 115.10015869140625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:36:00.0000000' AS DateTime2), 114.42218780517578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:40:00.0000000' AS DateTime2), 112.64066314697266)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:44:00.0000000' AS DateTime2), 113.48564147949219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:48:00.0000000' AS DateTime2), 113.12717437744141)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:52:00.0000000' AS DateTime2), 113.95030212402344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T10:56:00.0000000' AS DateTime2), 113.89509582519531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:00:00.0000000' AS DateTime2), 112.70660400390625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:04:00.0000000' AS DateTime2), 111.59987640380859)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:08:00.0000000' AS DateTime2), 113.55997467041016)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:12:00.0000000' AS DateTime2), 113.85695648193359)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:16:00.0000000' AS DateTime2), 113.52588653564453)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:20:00.0000000' AS DateTime2), 113.49681091308594)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:24:00.0000000' AS DateTime2), 112.07980346679688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:28:00.0000000' AS DateTime2), 111.34492492675781)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:32:00.0000000' AS DateTime2), 111.30722808837891)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:36:00.0000000' AS DateTime2), 112.45677947998047)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:40:00.0000000' AS DateTime2), 111.99864959716797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:44:00.0000000' AS DateTime2), 109.77289581298828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:48:00.0000000' AS DateTime2), 110.70958709716797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:52:00.0000000' AS DateTime2), 110.42878723144531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T11:56:00.0000000' AS DateTime2), 109.26557159423828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:00:00.0000000' AS DateTime2), 110.55500030517578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:04:00.0000000' AS DateTime2), 111.03214263916016)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:08:00.0000000' AS DateTime2), 109.09207153320313)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:12:00.0000000' AS DateTime2), 109.61486053466797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:16:00.0000000' AS DateTime2), 109.80556488037109)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:20:00.0000000' AS DateTime2), 109.57927703857422)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:24:00.0000000' AS DateTime2), 107.76605224609375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:28:00.0000000' AS DateTime2), 109.06596374511719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:32:00.0000000' AS DateTime2), 108.22909545898438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:36:00.0000000' AS DateTime2), 108.7855224609375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:40:00.0000000' AS DateTime2), 108.20030212402344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:44:00.0000000' AS DateTime2), 106.38352203369141)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:48:00.0000000' AS DateTime2), 106.32525634765625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:52:00.0000000' AS DateTime2), 107.37057495117188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T12:56:00.0000000' AS DateTime2), 107.57955932617188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:00:00.0000000' AS DateTime2), 106.97228240966797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:04:00.0000000' AS DateTime2), 107.10882568359375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:08:00.0000000' AS DateTime2), 106.749267578125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:12:00.0000000' AS DateTime2), 105.06867218017578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:16:00.0000000' AS DateTime2), 103.942138671875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:20:00.0000000' AS DateTime2), 104.14472198486328)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:24:00.0000000' AS DateTime2), 105.02651977539063)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:28:00.0000000' AS DateTime2), 104.75259399414063)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:32:00.0000000' AS DateTime2), 103.93804168701172)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:36:00.0000000' AS DateTime2), 103.17292785644531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:40:00.0000000' AS DateTime2), 105.21233367919922)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:44:00.0000000' AS DateTime2), 104.00135040283203)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:48:00.0000000' AS DateTime2), 103.97503662109375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:52:00.0000000' AS DateTime2), 103.79849243164063)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T13:56:00.0000000' AS DateTime2), 101.87178802490234)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:00:00.0000000' AS DateTime2), 101.62000274658203)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:04:00.0000000' AS DateTime2), 100.76821136474609)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:08:00.0000000' AS DateTime2), 101.11151123046875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:12:00.0000000' AS DateTime2), 101.26995849609375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:16:00.0000000' AS DateTime2), 100.67864990234375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:20:00.0000000' AS DateTime2), 100.4776611328125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:24:00.0000000' AS DateTime2), 101.93207550048828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:28:00.0000000' AS DateTime2), 100.40695953369141)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:32:00.0000000' AS DateTime2), 100.79240417480469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:36:00.0000000' AS DateTime2), 99.1934814453125)
GO
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:40:00.0000000' AS DateTime2), 100.77027893066406)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:44:00.0000000' AS DateTime2), 100.94786834716797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:48:00.0000000' AS DateTime2), 100.15132141113281)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:52:00.0000000' AS DateTime2), 99.635734558105469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T14:56:00.0000000' AS DateTime2), 98.421173095703125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:00:00.0000000' AS DateTime2), 99.112716674804688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:04:00.0000000' AS DateTime2), 97.920440673828125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:08:00.0000000' AS DateTime2), 98.2594223022461)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:12:00.0000000' AS DateTime2), 98.404747009277344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:16:00.0000000' AS DateTime2), 97.056480407714844)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:20:00.0000000' AS DateTime2), 96.709701538085938)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:24:00.0000000' AS DateTime2), 95.759483337402344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:28:00.0000000' AS DateTime2), 96.4208984375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:32:00.0000000' AS DateTime2), 95.789031982421875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:36:00.0000000' AS DateTime2), 95.953948974609375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:40:00.0000000' AS DateTime2), 97.1457290649414)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:44:00.0000000' AS DateTime2), 97.309432983398438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:48:00.0000000' AS DateTime2), 94.555145263671875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:52:00.0000000' AS DateTime2), 95.827926635742188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T15:56:00.0000000' AS DateTime2), 94.267852783203125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:00:00.0000000' AS DateTime2), 95.889999389648438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:04:00.0000000' AS DateTime2), 95.714431762695312)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:08:00.0000000' AS DateTime2), 94.05120849609375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:12:00.0000000' AS DateTime2), 95.280410766601562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:16:00.0000000' AS DateTime2), 94.277107238769531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:20:00.0000000' AS DateTime2), 92.461357116699219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:24:00.0000000' AS DateTime2), 92.593223571777344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:28:00.0000000' AS DateTime2), 93.9677734375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:32:00.0000000' AS DateTime2), 94.235076904296875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:36:00.0000000' AS DateTime2), 94.340194702148438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:40:00.0000000' AS DateTime2), 92.70318603515625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:44:00.0000000' AS DateTime2), 92.374114990234375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:48:00.0000000' AS DateTime2), 91.793037414550781)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:52:00.0000000' AS DateTime2), 91.385025024414062)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T16:56:00.0000000' AS DateTime2), 91.990127563476562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:00:00.0000000' AS DateTime2), 90.828399658203125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:04:00.0000000' AS DateTime2), 91.984901428222656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:08:00.0000000' AS DateTime2), 90.074691772460938)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:12:00.0000000' AS DateTime2), 90.687828063964844)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:16:00.0000000' AS DateTime2), 90.659355163574219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:20:00.0000000' AS DateTime2), 90.434333801269531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:24:00.0000000' AS DateTime2), 91.707809448242188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:28:00.0000000' AS DateTime2), 89.204841613769531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:32:00.0000000' AS DateTime2), 89.320465087890625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:36:00.0000000' AS DateTime2), 89.4647445678711)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:40:00.0000000' AS DateTime2), 91.657722473144531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:44:00.0000000' AS DateTime2), 90.529434204101562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:48:00.0000000' AS DateTime2), 89.354942321777344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:52:00.0000000' AS DateTime2), 89.8592758178711)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T17:56:00.0000000' AS DateTime2), 89.557487487792969)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:00:00.0000000' AS DateTime2), 88.554618835449219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:04:00.0000000' AS DateTime2), 90.4957046508789)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:08:00.0000000' AS DateTime2), 88.2057876586914)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:12:00.0000000' AS DateTime2), 90.054901123046875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:16:00.0000000' AS DateTime2), 88.773086547851562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:20:00.0000000' AS DateTime2), 89.105384826660156)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:24:00.0000000' AS DateTime2), 87.8868179321289)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:28:00.0000000' AS DateTime2), 88.687423706054688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:32:00.0000000' AS DateTime2), 88.562240600585938)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:36:00.0000000' AS DateTime2), 88.871292114257812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:40:00.0000000' AS DateTime2), 87.994613647460938)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:44:00.0000000' AS DateTime2), 87.137222290039062)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:48:00.0000000' AS DateTime2), 86.814155578613281)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:52:00.0000000' AS DateTime2), 88.0904312133789)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T18:56:00.0000000' AS DateTime2), 88.6260757446289)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:00:00.0000000' AS DateTime2), 86.511116027832031)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:04:00.0000000' AS DateTime2), 88.920562744140625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:08:00.0000000' AS DateTime2), 87.754447937011719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:12:00.0000000' AS DateTime2), 87.587783813476562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:16:00.0000000' AS DateTime2), 88.685592651367188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:20:00.0000000' AS DateTime2), 89.217880249023438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:24:00.0000000' AS DateTime2), 88.799674987792969)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:28:00.0000000' AS DateTime2), 87.0009765625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:32:00.0000000' AS DateTime2), 87.446807861328125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:36:00.0000000' AS DateTime2), 88.637168884277344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:40:00.0000000' AS DateTime2), 88.2770767211914)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:44:00.0000000' AS DateTime2), 88.996536254882812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:48:00.0000000' AS DateTime2), 87.025558471679688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:52:00.0000000' AS DateTime2), 86.164138793945312)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T19:56:00.0000000' AS DateTime2), 87.9422836303711)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:00:00.0000000' AS DateTime2), 88.5199966430664)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:04:00.0000000' AS DateTime2), 86.977287292480469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:08:00.0000000' AS DateTime2), 88.549140930175781)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:12:00.0000000' AS DateTime2), 88.515556335449219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:16:00.0000000' AS DateTime2), 88.896537780761719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:20:00.0000000' AS DateTime2), 88.172080993652344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:24:00.0000000' AS DateTime2), 87.2471694946289)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:28:00.0000000' AS DateTime2), 87.816810607910156)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:32:00.0000000' AS DateTime2), 88.5259780883789)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:36:00.0000000' AS DateTime2), 86.4146728515625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:40:00.0000000' AS DateTime2), 88.162879943847656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:44:00.0000000' AS DateTime2), 89.2105941772461)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:48:00.0000000' AS DateTime2), 88.202789306640625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:52:00.0000000' AS DateTime2), 88.814445495605469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T20:56:00.0000000' AS DateTime2), 87.845565795898438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:00:00.0000000' AS DateTime2), 87.14111328125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:04:00.0000000' AS DateTime2), 88.086074829101562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:08:00.0000000' AS DateTime2), 88.185432434082031)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:12:00.0000000' AS DateTime2), 88.204154968261719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:16:00.0000000' AS DateTime2), 87.942222595214844)
GO
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:20:00.0000000' AS DateTime2), 87.2046127319336)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:24:00.0000000' AS DateTime2), 88.921295166015625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:28:00.0000000' AS DateTime2), 88.997245788574219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:32:00.0000000' AS DateTime2), 87.667427062988281)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:36:00.0000000' AS DateTime2), 87.351821899414062)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:40:00.0000000' AS DateTime2), 89.460380554199219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:44:00.0000000' AS DateTime2), 87.9380874633789)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:48:00.0000000' AS DateTime2), 88.869903564453125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:52:00.0000000' AS DateTime2), 89.475784301757812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T21:56:00.0000000' AS DateTime2), 90.855705261230469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:00:00.0000000' AS DateTime2), 89.219619750976562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:04:00.0000000' AS DateTime2), 88.977493286132812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:08:00.0000000' AS DateTime2), 88.69927978515625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:12:00.0000000' AS DateTime2), 89.229942321777344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:16:00.0000000' AS DateTime2), 91.144439697265625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:20:00.0000000' AS DateTime2), 91.59771728515625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:24:00.0000000' AS DateTime2), 90.184745788574219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:28:00.0000000' AS DateTime2), 89.73046875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:32:00.0000000' AS DateTime2), 90.254837036132812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:36:00.0000000' AS DateTime2), 90.082809448242188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:40:00.0000000' AS DateTime2), 89.899330139160156)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:44:00.0000000' AS DateTime2), 91.789360046386719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:48:00.0000000' AS DateTime2), 92.847824096679688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:52:00.0000000' AS DateTime2), 92.4596939086914)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T22:56:00.0000000' AS DateTime2), 90.529899597167969)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:00:00.0000000' AS DateTime2), 93.188400268554688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:04:00.0000000' AS DateTime2), 91.910125732421875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:08:00.0000000' AS DateTime2), 91.540023803710938)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:12:00.0000000' AS DateTime2), 92.873039245605469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:16:00.0000000' AS DateTime2), 92.464111328125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:20:00.0000000' AS DateTime2), 92.333183288574219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:24:00.0000000' AS DateTime2), 92.040191650390625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:28:00.0000000' AS DateTime2), 94.535079956054688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:32:00.0000000' AS DateTime2), 94.562774658203125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:36:00.0000000' AS DateTime2), 92.663223266601562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:40:00.0000000' AS DateTime2), 93.601356506347656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:44:00.0000000' AS DateTime2), 92.8871078491211)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:48:00.0000000' AS DateTime2), 93.745414733886719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:52:00.0000000' AS DateTime2), 95.0962142944336)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-03T23:56:00.0000000' AS DateTime2), 94.634429931640625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:00:00.0000000' AS DateTime2), 95.25)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:04:00.0000000' AS DateTime2), 94.882858276367188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:08:00.0000000' AS DateTime2), 94.862930297851562)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:12:00.0000000' AS DateTime2), 95.065139770507812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:16:00.0000000' AS DateTime2), 96.254432678222656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:20:00.0000000' AS DateTime2), 97.290725708007812)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:24:00.0000000' AS DateTime2), 95.98895263671875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:28:00.0000000' AS DateTime2), 95.604034423828125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:32:00.0000000' AS DateTime2), 95.895904541015625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:36:00.0000000' AS DateTime2), 96.999481201171875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:40:00.0000000' AS DateTime2), 97.99969482421875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:44:00.0000000' AS DateTime2), 96.961479187011719)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:48:00.0000000' AS DateTime2), 98.204742431640625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:52:00.0000000' AS DateTime2), 97.1344223022461)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T00:56:00.0000000' AS DateTime2), 99.4254379272461)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:00:00.0000000' AS DateTime2), 98.622711181640625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:04:00.0000000' AS DateTime2), 98.576171875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:08:00.0000000' AS DateTime2), 98.410736083984375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:12:00.0000000' AS DateTime2), 99.726325988769531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:16:00.0000000' AS DateTime2), 100.26786804199219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:20:00.0000000' AS DateTime2), 99.415275573730469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:24:00.0000000' AS DateTime2), 100.35848236083984)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:28:00.0000000' AS DateTime2), 99.922401428222656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:32:00.0000000' AS DateTime2), 99.641960144042969)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:36:00.0000000' AS DateTime2), 100.43207550048828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:40:00.0000000' AS DateTime2), 101.46766662597656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:44:00.0000000' AS DateTime2), 100.58865356445313)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:48:00.0000000' AS DateTime2), 101.40995788574219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:52:00.0000000' AS DateTime2), 101.2965087890625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T01:56:00.0000000' AS DateTime2), 103.293212890625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:00:00.0000000' AS DateTime2), 103.34999847412109)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:04:00.0000000' AS DateTime2), 103.75678253173828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:08:00.0000000' AS DateTime2), 104.22849273681641)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:12:00.0000000' AS DateTime2), 102.35504150390625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:16:00.0000000' AS DateTime2), 102.13134765625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:20:00.0000000' AS DateTime2), 104.20233917236328)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:24:00.0000000' AS DateTime2), 104.43792724609375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:28:00.0000000' AS DateTime2), 103.00303649902344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:32:00.0000000' AS DateTime2), 104.97760009765625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:36:00.0000000' AS DateTime2), 105.95151519775391)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:40:00.0000000' AS DateTime2), 103.89472198486328)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:44:00.0000000' AS DateTime2), 104.30213165283203)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:48:00.0000000' AS DateTime2), 106.39867401123047)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:52:00.0000000' AS DateTime2), 105.12926483154297)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T02:56:00.0000000' AS DateTime2), 107.07882690429688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:00:00.0000000' AS DateTime2), 105.76728820800781)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:04:00.0000000' AS DateTime2), 105.64456176757813)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:08:00.0000000' AS DateTime2), 106.84557342529297)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:12:00.0000000' AS DateTime2), 107.50025177001953)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:16:00.0000000' AS DateTime2), 107.01351928710938)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:20:00.0000000' AS DateTime2), 107.53030395507813)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:24:00.0000000' AS DateTime2), 106.93051910400391)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:28:00.0000000' AS DateTime2), 109.55410003662109)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:32:00.0000000' AS DateTime2), 107.31096649169922)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:36:00.0000000' AS DateTime2), 107.54104614257813)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:40:00.0000000' AS DateTime2), 108.37427520751953)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:44:00.0000000' AS DateTime2), 109.25056457519531)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:48:00.0000000' AS DateTime2), 110.18985748291016)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:52:00.0000000' AS DateTime2), 110.32707214355469)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T03:56:00.0000000' AS DateTime2), 109.90714263916016)
GO
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:00:00.0000000' AS DateTime2), 108.96499633789063)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:04:00.0000000' AS DateTime2), 109.31557464599609)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:08:00.0000000' AS DateTime2), 111.36878967285156)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:12:00.0000000' AS DateTime2), 111.76458740234375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:16:00.0000000' AS DateTime2), 110.22289276123047)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:20:00.0000000' AS DateTime2), 111.27364349365234)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:24:00.0000000' AS DateTime2), 111.56177520751953)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:28:00.0000000' AS DateTime2), 110.27222442626953)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:32:00.0000000' AS DateTime2), 110.68991851806641)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:36:00.0000000' AS DateTime2), 112.86980438232422)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:40:00.0000000' AS DateTime2), 111.13181304931641)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:44:00.0000000' AS DateTime2), 111.71088409423828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:48:00.0000000' AS DateTime2), 112.43196105957031)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:52:00.0000000' AS DateTime2), 111.85997772216797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T04:56:00.0000000' AS DateTime2), 111.65987396240234)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:00:00.0000000' AS DateTime2), 112.12660217285156)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:04:00.0000000' AS DateTime2), 113.51009368896484)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:08:00.0000000' AS DateTime2), 114.74030303955078)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:12:00.0000000' AS DateTime2), 114.11217498779297)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:16:00.0000000' AS DateTime2), 114.48564147949219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:20:00.0000000' AS DateTime2), 114.67566680908203)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:24:00.0000000' AS DateTime2), 115.42218780517578)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:28:00.0000000' AS DateTime2), 113.66016387939453)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:32:00.0000000' AS DateTime2), 115.33453369140625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:36:00.0000000' AS DateTime2), 116.07525634765625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:40:00.0000000' AS DateTime2), 113.8372802734375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:44:00.0000000' AS DateTime2), 114.47556304931641)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:48:00.0000000' AS DateTime2), 114.04006195068359)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:52:00.0000000' AS DateTime2), 115.55072021484375)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T05:56:00.0000000' AS DateTime2), 116.21250915527344)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:00:00.0000000' AS DateTime2), 116.85538482666016)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:04:00.0000000' AS DateTime2), 115.98929595947266)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:08:00.0000000' AS DateTime2), 116.38921356201172)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:12:00.0000000' AS DateTime2), 115.68509674072266)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:16:00.0000000' AS DateTime2), 117.23690795898438)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:20:00.0000000' AS DateTime2), 115.26461791992188)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:24:00.0000000' AS DateTime2), 116.58818054199219)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:28:00.0000000' AS DateTime2), 115.23757171630859)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:32:00.0000000' AS DateTime2), 117.43775939941406)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:36:00.0000000' AS DateTime2), 117.30370330810547)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:40:00.0000000' AS DateTime2), 115.89038848876953)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:44:00.0000000' AS DateTime2), 117.43277740478516)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:48:00.0000000' AS DateTime2), 116.6158447265625)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:52:00.0000000' AS DateTime2), 117.09957122802734)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T06:56:00.0000000' AS DateTime2), 116.39892578125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:00:00.0000000' AS DateTime2), 116.01388549804688)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:04:00.0000000' AS DateTime2), 115.91443634033203)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:08:00.0000000' AS DateTime2), 118.20555114746094)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:12:00.0000000' AS DateTime2), 116.70721435546875)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:16:00.0000000' AS DateTime2), 115.87440490722656)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:20:00.0000000' AS DateTime2), 116.01711273193359)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:24:00.0000000' AS DateTime2), 117.60032653808594)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:28:00.0000000' AS DateTime2), 116.97402191162109)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:32:00.0000000' AS DateTime2), 116.07318878173828)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:36:00.0000000' AS DateTime2), 117.53282928466797)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:40:00.0000000' AS DateTime2), 118.18292236328125)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:44:00.0000000' AS DateTime2), 118.82346343994141)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:48:00.0000000' AS DateTime2), 118.28444671630859)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:52:00.0000000' AS DateTime2), 118.32585906982422)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T07:56:00.0000000' AS DateTime2), 116.86771392822266)
INSERT [dbo].[LowExcursion] ([XdateStr], [FlatVal]) VALUES (CAST(N'2022-11-04T08:00:00.0000000' AS DateTime2), 117.30999755859375)
GO
INSERT [dbo].[Tags] ([TagId], [TagName]) VALUES (1001, N'TagTests_InsertTest')
GO
/****** Object:  Index [pkExcursionPointsCycleId]    Script Date: 11/18/2022 1:35:07 PM ******/
ALTER TABLE [dbo].[ExcursionPoints] ADD  CONSTRAINT [pkExcursionPointsCycleId] PRIMARY KEY NONCLUSTERED 
(
	[CycleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_CollectionPointsPace_TagId]    Script Date: 11/18/2022 1:35:07 PM ******/
CREATE NONCLUSTERED INDEX [IX_CollectionPointsPace_TagId] ON [dbo].[PointsPaces]
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IxTagStageName]    Script Date: 11/18/2022 1:35:07 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName] ON [dbo].[Stages]
(
	[TagId] ASC,
	[StageName] ASC
)
WHERE ([StageName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 11/18/2022 1:35:07 PM ******/
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
(
	[StageId] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixTagsTagName]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetStagesLimitsAndDates]    Script Date: 11/18/2022 1:35:07 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spPivotExcursionPoints]    Script Date: 11/18/2022 1:35:07 PM ******/
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
			, HiPointsCt int, LowPointsCt int
			, LowThreashold float, HiThreashold float);
	DECLARE @ExcPoints as TABLE ( 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  
			, LowThreashold float, HiThreashold float);
	DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
	DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
	DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
	DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
	DECLARE  @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	PRINT 'GET initial TagExcNbr'
	SELECT TOP 1 @TagExcNbr = ISNULL(TagExcNbr,0) + 1 FROM [dbo].[ExcursionPoints] 
		WHERE TagName = @TagName
		ORDER BY TagName, TagExcNbr Desc
	PRINT 'Create Output record'
	INSERT INTO @ExcPoint1 VALUES (@TagName, @TagExcNbr
	, NULL, NULL -- RampIn
	, NULL, NULL -- FirstExc
	, NULL, NULL -- LastExc
	, NULL, NULL -- RampOut
	, @HiPointsCt, @LowPointsCt
	, @LowThreashold, @HiThreashold );

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName 
		AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

	OPEN CPoint;
	FETCH NEXT FROM CPoint INTO @tag, @time, @value;
	PRINT Concat('First Excursion point. Value ', @time, @Value);

	PRINT 'Loop through Excursion points in the time period if any'
	WHILE @@FETCH_STATUS = 0  BEGIN
			
		IF (@FirstExcDate IS NULL) BEGIN
			PRINT 'Get First Excursion Point'
			UPDATE @ExcPoint1 SET FirstExcDate = @time, FirstExcValue = @value;
			SELECT TOP 1 @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue FROM @ExcPoint1;
			PRINT 'Determine if cycle is for Hi or Low Excursion'
			IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
			ELSE SET @IsHiExc = 0;
			PRINT Concat('IsHiExc: ', @IsHiExc);
		END

		PRINT 'Increase Excursion Counter'
		IF (@IsHiExc = 1) SET @HiPointsCt = @HiPointsCt + 1;
		ELSE SET @LowPointsCt = @LowPointsCt + 1;
		UPDATE @ExcPoint1 SET HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt;

		IF (@FirstExcDate IS NOT NULL AND @RampInDate IS NULL) BEGIN
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time <= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Desc;
			IF (@RampInDate IS NOT NULL) UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
			PRINT Concat('RampIn point: RampInDate RampInValue', @RampInDate, @RampInValue);
END

		PRINT 'Always Reset Last Excursion Point until end of cursor'
		UPDATE @ExcPoint1 SET LastExcDate = @time, LastExcValue = @value;
		SELECT TOP 1 @LastExcDate = LastExcDate, @LastExcValue = LastExcValue FROM @ExcPoint1;
		
		PRINT 'Get RampOut point'
		IF (@RampOutDate IS NULL AND @LastExcDate IS NOT NULL ) BEGIN
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time >= FORMAT(@LastExcDate,'yyyy-MM-dd HH:mm:ss') 
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Asc;
			IF (@RampOutDate IS NOT NULL) UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
		END

		FETCH NEXT FROM CPoint INTO @tag, @time, @value; 
		PRINT Concat('Next Excursion point: time Value ', @time, @Value);

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
					, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
					, @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold);
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
