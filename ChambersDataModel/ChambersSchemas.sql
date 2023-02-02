USE [master]
GO
/****** Object:  Database [ELChambers]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetExcursionsCounts]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnGetExcursionsCounts] (
      @TagNamesList varchar(max),
      @MinHiCount int = Null,
      @MinLowCount int = NULL,
      @AfterDate DateTime = NULL,
      @BeforeDate DateTime = NULL)
RETURNS @ExcsCounts TABLE (TagName varchar(255), HiExcsCount int, LowExcsCount int)
AS
BEGIN
--DECLARE @LowestDate datetime = '1900-01-01', @HighestDate datetime = '1900-01-01';
      IF (@MinHiCount IS NULL OR @MinHiCount < 0) SET @MinHiCount = 0;
      IF (@MinLowCount IS NULL OR @MinLowCount < 0) SET @MinLowCount = 0;

      INSERT INTO @ExcsCounts
      SELECT TagName, Count(Case when exc.HiPointsCt > 0 then 1 else null end) as HiExcsCount
             , Count(Case when exc.LowPointsCt > 0 then 1 else null end) as LowExcsCount 
      from [dbo].[ExcursionPoints] as exc
      where 
      (@TagNamesList IS NULL OR TagName in (SELECT value FROM STRING_SPLIT( @TagNamesList, ',')))
      AND ((exc.HiPointsCt > @MinHiCount) Or (exc.LowPointsCt > @MinLowCount))
      AND (@AfterDate IS NULL OR @AfterDate <= exc.RampOutDate)
      AND (@BeforeDate IS NULL OR exc.RampInDate <= @BeforeDate )
      GROUP BY TagName;

      DECLARE @rowsCnt int;
      SELECT @rowsCnt = COUNT(*) FROM @ExcsCounts;

      RETURN;
END
-- RampInDate      RampOutDate      HiPointsCt   LowPointsCt
-- 2022-11-01 12:00:00.000      2022-11-01 12:02:00.000      1     0
-- 2022-11-01 12:02:00.000      2022-11-01 13:58:00.000      115   0
-- 2022-11-01 13:59:00.000      2022-11-01 14:01:00.000      1     0
-- 2022-11-03 14:32:00.000      2022-11-03 14:40:00.000      0     1
-- 2022-11-03 14:48:00.000      2022-11-04 01:16:00.000      0     156
-- 2022-11-04 01:16:00.000      2022-11-04 01:24:00.000      0     1
-- 2022-11-04 01:24:00.000      2022-11-04 01:36:00.000      0     2

-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, null, null); 
-- RETURN: chamber_report_tag_1      3     4
-- SELECT * from [dbo].[fnGetExcursionsCounts]('chamber_report_tag_1', 0, 1, null, null); 
-- RETURN: chamber_report_tag_1      3     2
-- SELECT * from [dbo].[fnGetExcursionsCounts]('chamber_report_tag_1', 0, 0, '2022-11-02', null); 
-- RETURN: chamber_report_tag_1      0     4
-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, '2022-11-04', null); 
-- RETURN: chamber_report_tag_1      0     3
-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, '2022-11-05', null); 
-- RETURN: no rows
-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, NULL, '2022-11-04'); 
-- RETURN: chamber_report_tag_1      3     2
-- SELECT * from [dbo].[fnGetExcursionsCounts]('chamber_report_tag_1, chamber_report_tag_2', 0, 1, null, null)
-- RETURN: chamber_report_tag_1      3     2


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetExcursionsDetails]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnGetExcursionsDetails] (
      @TagName varchar(255),
      @AfterDate DateTime,
      @BeforeDate DateTime = NULL,
         @MinHiCount int = Null,
      @MinLowCount int = NULL
)
RETURNS @ExcsCounts TABLE ( 
       [CycleId] int NOT NULL,
       [TagId] int NULL, [TagName] [varchar](255) NOT NULL,
       [TagExcNbr] [int] NOT NULL, [StepLogId] int null,
       [RampInDate] [datetime] NULL, [RampInValue] [float] NULL,
       [FirstExcDate] [datetime] NULL, [FirstExcValue] [float] NULL,
       [LastExcDate] [datetime] NULL,     [LastExcValue] [float] NULL,
       [RampOutDate] [datetime] NULL,     [RampOutValue] [float] NULL,
       [HiPointsCt] [int] NOT NULL, [LowPointsCt] [int] NOT NULL,
       [MinThreshold] [float] NULL, [MaxThreshold] [float] NULL
       )
AS
BEGIN
INSERT INTO @ExcsCounts
SELECT [CycleId], [TagId], [TagName], [TagExcNbr], [StepLogId]
              , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
              , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
              ,[HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
FROM [dbo].[ExcursionPoints] 
WHERE TagName = @TagName
AND ( @AfterDate  <= RampInDate   AND (@BeforeDate is NULL OR RampOutDate <= @BeforeDate) )
AND ( (HiPointsCt > @MinHiCount OR LowPointsCt > @MinLowCount OR (@MinHiCount IS NULL AND @MinLowCount IS NULL)) )  

RETURN


--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, NULL, NULL); -- returns 0-6
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-03', NULL, NULL, NULL); -- returns 3-6
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', '2022-11-03', NULL, NULL); -- returns 0-2
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, 1, NULL); -- returns  1
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, NULL, 1); -- return 4 & 6
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, 0, 0); -- returns 0-6

--TagName     TagExcNbr     RampInDate    RampInValue       FirstExcDate  FirstExcValue LastExcDate   LastExcValue       RampOutDate   RampOutValue  HiPointsCt    LowPointsCt       MinValue      MaxValue
--chamber_report_tag_1      0      2022-11-01 12:00:00.000       197.130004882813     2022-11-01 12:01:00.000       201.427093505859     2022-11-01 12:01:00.000       201.427093505859     2022-11-01 12:02:00.000       199.935562133789     1      0      100    200
--chamber_report_tag_1      1      2022-11-01 12:02:00.000       199.935562133789     2022-11-01 12:03:00.000       205.44514465332      2022-11-01 13:57:00.000       203.805145263672     2022-11-01 13:58:00.000       198.725555419922     115    0      100    200
--chamber_report_tag_1      2      2022-11-01 13:59:00.000       197.867095947266     2022-11-01 14:00:00.000       201.470001220703     2022-11-01 14:00:00.000       201.470001220703     2022-11-01 14:01:00.000       198.994522094727     1      0      100    200
--chamber_report_tag_1      3      2022-11-03 14:32:00.000       100.792404174805     2022-11-03 14:36:00.000       99.1934814453125     2022-11-03 14:36:00.000       99.1934814453125     2022-11-03 14:40:00.000       100.770278930664     0      1      100    200
--chamber_report_tag_1      4      2022-11-03 14:48:00.000       100.151321411133     2022-11-03 14:52:00.000       99.6357345581055     2022-11-04 01:12:00.000       99.7263259887695     2022-11-04 01:16:00.000       100.267868041992     0      156    100    200
--chamber_report_tag_1      5      2022-11-04 01:16:00.000       100.267868041992     2022-11-04 01:20:00.000       99.4152755737305     2022-11-04 01:20:00.000       99.4152755737305     2022-11-04 01:24:00.000       100.35848236084      0      1      100    200
--chamber_report_tag_1      6      2022-11-04 01:24:00.000       100.35848236084      2022-11-04 01:28:00.000       99.9224014282227     2022-11-04 01:32:00.000       99.641960144043      2022-11-04 01:36:00.000       100.432075500488     0      2      100    200


END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetScheduleDates]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsPaces](
	[PaceId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[NextStepStartDate] [datetime] NOT NULL,
	[StepSizeDays] [int] NOT NULL,
	[NextStepEndDate]  AS (dateadd(day,[StepSizeDays],[NextStepStartDate])),
	[ProcessedDate] [datetime] NULL,
 CONSTRAINT [pcPointsPacesPaceId] PRIMARY KEY NONCLUSTERED 
(
	[PaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [ixPointsPacesStageDateId]    Script Date: 2/2/2023 10:37:16 AM ******/
CREATE CLUSTERED INDEX [ixPointsPacesStageDateId] ON [dbo].[PointsPaces]
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tags](
	[TagId] [int] NOT NULL,
	[TagName] [nvarchar](255) NOT NULL,
	[Picture] [varbinary](max) NULL,
 CONSTRAINT [PK_Tags] PRIMARY KEY CLUSTERED 
(
	[TagId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stages](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NULL,
	[MinThreshold] [float] NOT NULL,
	[MaxThreshold] [float] NOT NULL,
	[TimeStep] [float] NULL,
	[ProductionDate] [datetime] NULL,
	[DeprecatedDate] [datetime] NULL,
 CONSTRAINT [PK_Stages] PRIMARY KEY CLUSTERED 
(
	[StageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StagesDates](
	[StageDateId] [int] IDENTITY(1,1) NOT NULL,
	[StageId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[DeprecatedDate] [datetime] NULL,
 CONSTRAINT [pkStagesDatesStageDateId] PRIMARY KEY CLUSTERED 
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT t.TagId, t.TagName, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold, std.StartDate, std.EndDate, st.TimeStep, st.StageId
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t.TagId
WHERE (std.DeprecatedDate IS NULL) AND (st.DeprecatedDate IS NULL)
GO
/****** Object:  View [dbo].[DefaultPointsPaces]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  View [dbo].[PointsStepsLogNextValues]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT sld.StageDateId, sld.StageName,T.TagId, T.TagName
, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinThreshold, sld.MaxThreshold
, pp.PaceId, pp.NextStepStartDate as PaceStartDate, pp.NextStepEndDate as PaceEndDate
, ods.StartDate, ods.EndDate
FROM 
Tags as t
INNER JOIN 
dbo.StagesLimitsAndDates AS sld ON t.TagId = sld.TagId
INNER JOIN
dbo.PointsPaces AS pp ON sld.StageDateId = pp.StageDateId
CROSS APPLY
[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE 
t.TagName IS NOT NULL AND
ods.StartDate IS NOT NULL AND
ods.EndDate IS NOT NULL AND
pp.ProcessedDate IS NULL
GO
/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionPoints](
	[CycleId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NULL,
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
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[ExcursionLength]  AS (datediff(minute,[RampInDate],[RampOutDate])),
 CONSTRAINT [pkExcursionPointsCycleId] PRIMARY KEY NONCLUSTERED 
(
	[CycleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsRampInDateTagNameTagExcNbr]    Script Date: 2/2/2023 10:37:16 AM ******/
CREATE CLUSTERED INDEX [ixExcursionPointsRampInDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC,
	[RampInDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExcursionStats]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionStats](
	[TagName] [varchar](255) NOT NULL,
	[TagExcNbr] [int] NOT NULL,
	[TagId] [int] NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL,
	[AverageValue] [float] NULL,
	[StdDeviation] [float] NULL,
 CONSTRAINT [PK_ExcursionStats] PRIMARY KEY CLUSTERED 
(
	[TagName] ASC,
	[TagExcNbr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HiExcursion]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  Table [dbo].[Interpolated]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Interpolated](
	[tag] [varchar](20) NOT NULL,
	[Time] [datetime2](7) NOT NULL,
	[Value] [float] NOT NULL,
 CONSTRAINT [pkInterpolated] PRIMARY KEY CLUSTERED 
(
	[tag] ASC,
	[Time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LowExcursion]    Script Date: 2/2/2023 10:37:16 AM ******/
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
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsStepsLog](
	[StepLogId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[StageName] [nvarchar](255) NOT NULL,
	[TagId] [int] NOT NULL,
	[TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL,
	[StageEndDate] [datetime] NULL,
	[MinThreshold] [float] NOT NULL,
	[MaxThreshold] [float] NOT NULL,
	[PaceId] [int] NOT NULL,
	[PaceStartDate] [datetime] NOT NULL,
	[PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [pkPointsStepsLogPaceLogId] PRIMARY KEY CLUSTERED 
(
	[StepLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsRampoutDateTagNameTagExcNbr]    Script Date: 2/2/2023 10:37:16 AM ******/
CREATE NONCLUSTERED INDEX [ixExcursionPointsRampoutDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC,
	[RampOutDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IxTagStageName]    Script Date: 2/2/2023 10:37:16 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName] ON [dbo].[Stages]
(
	[TagId] ASC,
	[StageName] ASC
)
WHERE ([StageName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 2/2/2023 10:37:16 AM ******/
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
(
	[StageId] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixTagsTagName]    Script Date: 2/2/2023 10:37:16 AM ******/
CREATE NONCLUSTERED INDEX [ixTagsTagName] ON [dbo].[Tags]
(
	[TagName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PointsPaces] ADD  CONSTRAINT [DF_PointsPaces_StepSizeDays]  DEFAULT ((2)) FOR [StepSizeDays]
GO
ALTER TABLE [dbo].[Stages] ADD  DEFAULT ((3.4000000000000000e+038)) FOR [MaxThreshold]
GO
ALTER TABLE [dbo].[StagesDates] ADD  DEFAULT ('9999-12-31 11:11:59') FOR [EndDate]
GO
ALTER TABLE [dbo].[PointsPaces]  WITH CHECK ADD  CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId] FOREIGN KEY([StageDateId])
REFERENCES [dbo].[StagesDates] ([StageDateId])
GO
ALTER TABLE [dbo].[PointsPaces] CHECK CONSTRAINT [fkPointsPacesStageDateId_StagesDatesStageDateId]
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
/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
	-- Add the parameters for the stored procedure here
	@ForDate datetime, -- Processing date
	@StageDateId int = null,
	@TagName varchar(255) = NULL -- StageDateId is enough but pass TagName for better performance. 

AS
BEGIN
PRINT '>>> spDriverExcursionsPointsForDate begins'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRAN;

		-- find all (or selected by StageDateId) StagesLimitsAndDates (STADs) left join with PointsPaces
		-- default PointsPaces will be assigned to STADs that don't have one.
		IF (@StageDateId IS NULL AND @TagName IS NULL) 
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
			FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL;
		ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])			
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
			FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL AND sld.StageDateId = @StageDateId;
		ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays 
			FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL AND sld.TagName = @TagName;
		ELSE
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
			from [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL AND sld.TagName = @TagName AND sld.StageDateId = @StageDateId;

	
	--spCreateSteps
	-- iterate all PointsPaces or just the ones associated with input StageDateId.
	-- Iterate ends when PointsPaces' end date exceeds ForDate
	-- each iteration creates associated PointsStepsLog
	-- insert into [dbo].[PointsStepsLog]

	DECLARE  @PointsStepsLog TABLE ( [StepLogId] [int] NULL,
	[StageDateId] [int] NOT NULL, [StageName] [nvarchar](255) NOT NULL, [TagId] [int] NOT NULL, [TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL, [StageEndDate] [datetime] NULL, [MinThreshold] [float] NOT NULL, [MaxThreshold] [float] NOT NULL,
	[PaceId] [int] NOT NULL, [PaceStartDate] [datetime] NOT NULL, [PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL, [EndDate] [datetime] NULL
	);



	IF (@StageDateId IS NULL AND @TagName IS NULL) 
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId
	ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.TagName = @TagName
	ELSE
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId AND nxt.TagName = @TagName



	INSERT INTO [dbo].[PointsStepsLog] ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
	SELECT [StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate] 
	FROM @PointsStepsLog;

	--spProcessSteps
	-- each iteration populates excursionPoints
	-- iterations should be under the context of a transaction.
	DECLARE @ExcPoints as TABLE ( TagId int NULL
		, TagName varchar(255), TagExcNbr int NULL
		, StepLogId int NULL
		, RampInDate DateTime NULL, RampInValue float NULl
		, FirstExcDate DateTime NULL, FirstExcValue float NULL
		, LastExcDate DateTime NULL, LastExcValue float NULL
		, RampOutDate DateTime NULL, RampOutValue float NULL
		, HiPointsCt int NULL, LowPointsCt int NULL
		, MinThreshold float NULL, MaxThreshold float NULL);
	DECLARE @stTagId int, @stTagName varchar(255), @stStepLogId int
	, @stMinThreshold float, @stMaxThreshold float, @stStartDate as datetime, @stEndDate as datetime;
	DECLARE stepsCsr CURSOR 
	FOR SELECT psl.TagId, psl.TagName, psl.StepLogId, psl.MinThreshold, psl.MaxThreshold, psl.StartDate, psl.EndDate 
		FROM PointsStepsLog as psl
		WHERE psl.PaceId in (SELECT vpsl.PaceId From @PointsStepsLog as vpsl);
	OPEN stepsCsr;
	FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinThreshold, @stMaxThreshold, @stStartDate, @stEndDate;
	WHILE @@FETCH_STATUS = 0 BEGIN
		--PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ' + Convert(varchar(16), @stTagId) + Convert(varchar(16), @stStepLogId) +  '''',@stTagName, ''', '''
		--, FORMAT(@stStartDate, 'yyyy-MM-dd'), ''', ''', CONVERT(varchar(255), @stEndDate, 126), ''', '
		--, CONVERT(varchar(255), @stMinThreshold), ', ', CONVERT(varchar(255), @stMaxThreshold)
		--);
		INSERT INTO @ExcPoints
		EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @stStartDate, @stEndDate, @stMinThreshold, @stMaxThreshold, @stTagId, @stStepLogId;

		FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinThreshold, @stMaxThreshold, @stStartDate, @stEndDate;
	END;
	CLOSE stepsCsr;
	DEALLOCATE stepsCsr;

	IF EXISTS (SELECT PaceId FROM @PointsStepsLog) BEGIN
		-- Create a new PointsPaces row for next iteration
		INSERT INTO PointsPaces (StageDateId, NextStepStartDate, StepSizeDays)
		SELECT pps.StageDateId, pps.NextStepEndDate as NextStepStartDate, pps.StepSizeDays 
		FROM PointsPaces as pps
		WHERE pps.ProcessedDate IS NULL;
		-- Update PointsPaces's row that was processed
		UPDATE dbo.PointsPaces 
		SET  ProcessedDate = GetDate()
		WHERE PaceId IN (SELECT PaceId FROM @PointsStepsLog) AND ProcessedDate IS NULL;

	END

	SELECT * FROM @ExcPoints;

	COMMIT TRAN;

-- UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-01';
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2222-11-01';
--SELECT * FROM [dbo].[PointsStepsLog];
--DELETE FROM [dbo].[PointsStepsLog];
PRINT 'spDriverExcursionsPointsForDate ends <<<'

END;
GO
/****** Object:  StoredProcedure [dbo].[spGetStats]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spGetStats]
	@TagName varchar(255), 
	@FirstExcDate DateTime,
	@LastExcDate DateTime,
	@MinValue float NULL OUTPUT,
	@MaxValue float NULL OUTPUT,
	@AvergValue float NULL OUTPUT,
	@StdDevValue float NULL OUTPUT
AS
BEGIN
PRINT '>>> spGetStats begins'

		SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
			FROM [dbo].Interpolated as Stat
			WHERE Stat.tag = @TagName  and Stat.time >= @FirstExcDate And Stat.Time <= @LastExcDate;

PRINT 'spGetStats ends <<<'
--DECLARE @OMinValue    float;
--DECLARE @OMaxValue    float;
--DECLARE @OAvergValue  float;
--DECLARE @OStdDevValue float;
----insert into[dbo].[ExcursionStats]
--EXECUTE dbo.spGetStats chamber_report_tag_1, '2022-11-01 12:03:00.00', '2022-11-01 13:57:00.000'
--	, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
--PRINT CONCAT(@OMinValue,'-', @OMaxValue,'-', @OAvergValue,'-', @OStdDevValue);
END
GO
/****** Object:  StoredProcedure [dbo].[spMergeIncompleteCycles]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spMergeIncompleteCycles] 
	---- Add the parameters for the stored procedure here
	--@p1 int = 0, 
	--@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE  @RampInResults TABLE ( CycleId int, RampInDate DateTime NULL, RampInValue float, LowPointsCt int, HiPointsCt int);
	DECLARE  @RampOutResults TABLE ( CycleId int, TagName varchar(255), TagExcNbr int, RampInDate DateTime NULL, RampInValue float
	, RampOutDate DateTime NULL, LowPointsCt int, HiPointsCt int);
	DECLARE @OCycleId int, @OTagName varchar(255), @OTagExcNbr int, @OPrevTagExcNbr int, @ORampOutDate datetime, @OLowPointsCt int, @OHiPointsCt int;
	DECLARE RampOutCyclesCsr CURSOR 
	-- Get all Incomplete RampOuts. PrevTagExcNbr will contain the Excursion number of the 
	-- previous Incomplete RampOut for the same TagName
	FOR SELECT CycleId,  TagName, TagExcNbr
		, LAG(TagExcNbr,1,0) OVER (PARTITION BY TagName ORDER BY TagExcNbr) as PrevTagExcNbr
		, RampOutDate, LowPointsCt, HiPointsCt 
		FROM [dbo].[ExcursionPoints]
		WHERE RampInDate is null AND RampOutDate is NOT NULL;
	OPEN RampOutCyclesCsr;
	-- Fetch next RampOut Cycle row
	FETCH NEXT FROM RampOutCyclesCsr INTO @OCycleId, @OTagName, @OTagExcNbr, @OPrevTagExcNbr, @ORampOutDate, @OLowPointsCt, @OHiPointsCt;

	WHILE @@FETCH_STATUS = 0 BEGIN

		-- Get RampIn (and Intermediate) Cycles' rows 
		DELETE @RampInResults;
		INSERT INTO @RampInResults
		SELECT CycleId,  RampInDate, RampInValue, LowPointsCt, HiPointsCt 
			FROM [dbo].[ExcursionPoints] 
		WHERE TagName = @OTagName and TagExcNbr > @OPrevTagExcNbr and TagExcNbr < @OTagExcNbr;

		-- Compute RampIn's datetime and value and Points High and Low Count
		DECLARE  @GRampInDate DateTime, @GRampInValue float, @GLowPointsCt int, @GHiPointsCt int;
		SELECT @GRampInDate = MIN(RampInDate), @GRampInValue= Min(RampInValue)
		, @GLowPointsCt = IsNull(SUM(LowPointsCt),0), @GHiPointsCt = IsNull(SUM(HiPointsCt), 0) FROM @RampInResults;

		-- Update the RampOut Cycle row
		UPDATE [dbo].[ExcursionPoints]
		SET RampInDate = @GRampInDate, RampInValue = @GRampInValue, LowPointsCt = @OLowPointsCt + @GLowPointsCt, HiPointsCt =  @OHiPointsCt + @GHiPointsCt
		WHERE CycleId = @OCycleId;

		-- Save the updated RampOut cycle in RampOutResults
		INSERT INTO @RampOutResults
		SELECT CycleId , TagName , TagExcNbr , RampInDate , RampInValue, RampOutDate , LowPointsCt , HiPointsCt  
		FROM [dbo].[ExcursionPoints] WHERE CycleId = @OCycleId;

		-- Clear used RampIn (and Intermediate) Cycles' rows
		DELETE FROM [dbo].[ExcursionPoints] WHERE CycleId IN (SELECT CycleId FROM @RampInResults)

		-- Fetch next RampOut Cycle row
		FETCH NEXT FROM RampOutCyclesCsr INTO @OCycleId, @OTagName, @OTagExcNbr, @OPrevTagExcNbr, @ORampOutDate, @OLowPointsCt, @OHiPointsCt;
	END
	CLOSE RampOutCyclesCsr;
	DEALLOCATE RampOutCyclesCsr;
		

    -- Insert statements for procedure here
	SELECT * FROM @RampOutResults;
END

GO
/****** Object:  StoredProcedure [dbo].[spPivotExcursionPoints]    Script Date: 2/2/2023 10:37:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (	
	  @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
	, @LowThreashold float, @HiThreashold float, @TagId int = null, @StepLogId int = null 
)
AS
BEGIN
PRINT '>>> spPivotExcursionPoints begins'

	--Declare input cursor values
	DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 1; 
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
			IF (@RampOutDate IS NOT NULL) BEGIN 
				UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
			END
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

	INSERT INTO [dbo].[ExcursionPoints]
	SELECT 
	 @TagId as [TagId], [TagName], [TagExcNbr], @StepLogId as [StepLogId], [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      ,[LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue], [HiPointsCt], [LowPointsCt]
	  , @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
	FROM @ExcPoints WHERE HiPointsCt > 0 OR LowPointsCt > 0; -- select only full Excursions
	PRINT 'ALL Excursion Cycles inserted'

	SELECT 
	 @TagId as [TagId], [TagName], [TagExcNbr], @StepLogId as [StepLogId], [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      ,[LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue], [HiPointsCt], [LowPointsCt]
	  , @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
	FROM @ExcPoints WHERE HiPointsCt > 0 OR LowPointsCt > 0;

-- UNIT TESTS
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
--		, @LowThreashold = 100, @HiThreashold = 200, @TagId = 111, @StepLogId = 222;
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-05'
--		, @LowThreashold = 100, @HiThreashold = 200;
PRINT 'spPivotExcursionPoints ends <<<'

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
               Bottom = 627
               Right = 424
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PPs"
            Begin Extent = 
               Top = 15
               Left = 520
               Bottom = 408
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
         Begin Table = "st"
            Begin Extent = 
               Top = 45
               Left = 396
               Bottom = 510
               Right = 724
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "t"
            Begin Extent = 
               Top = 43
               Left = 0
               Bottom = 266
               Right = 328
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "std"
            Begin Extent = 
               Top = 101
               Left = 916
               Bottom = 478
               Right = 1283
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
