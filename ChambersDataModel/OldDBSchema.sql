--/****** Object:  Database [ELChambers_copy]    Script Date: 7/24/2023 1:45:52 PM ******/
--CREATE DATABASE [ELChambers_copy]
-- CONTAINMENT = NONE
-- ON  PRIMARY 
--( NAME = N'ELChambers_copy', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ELChambers_copy.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
-- LOG ON 
--( NAME = N'ELChambers_copy_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ELChambers_copy_log.ldf' , SIZE = 40960KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
-- WITH CATALOG_COLLATION = DATABASE_DEFAULT
--GO
--ALTER DATABASE [ELChambers_copy] SET COMPATIBILITY_LEVEL = 150
--GO

use [ELChambers_copy]
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [ELChambers_copy].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [ELChambers_copy] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ELChambers_copy] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ELChambers_copy] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ELChambers_copy] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ELChambers_copy] SET ARITHABORT OFF 
GO
ALTER DATABASE [ELChambers_copy] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ELChambers_copy] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ELChambers_copy] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ELChambers_copy] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ELChambers_copy] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ELChambers_copy] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ELChambers_copy] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ELChambers_copy] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ELChambers_copy] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ELChambers_copy] SET  ENABLE_BROKER 
GO
ALTER DATABASE [ELChambers_copy] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ELChambers_copy] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ELChambers_copy] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ELChambers_copy] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ELChambers_copy] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ELChambers_copy] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [ELChambers_copy] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ELChambers_copy] SET RECOVERY FULL 
GO
ALTER DATABASE [ELChambers_copy] SET  MULTI_USER 
GO
ALTER DATABASE [ELChambers_copy] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ELChambers_copy] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ELChambers_copy] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ELChambers_copy] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ELChambers_copy] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ELChambers_copy] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ELChambers', N'ON'
GO
ALTER DATABASE [ELChambers_copy] SET QUERY_STORE = OFF
GO
USE [ELChambers_copy]
GO
/****** Object:  Schema [BB50PCSjsantos]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE SCHEMA [BB50PCSjsantos]
GO
/****** Object:  UserDefinedFunction [BB50PCSjsantos].[fnYYYYMM]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [BB50PCSjsantos].[fnYYYYMM] 
(
       -- Add the parameters for the function here
       @date DateTime
)
RETURNS char(6)
AS
BEGIN
       -- Declare the return variable here
       DECLARE @Result char(6)

       -- Add the T-SQL statements to compute the return value here
       SELECT @Result = CONCAT(YEAR(@date), RIGHT(CONCAT('00',  MONTH(@date)), 2))

       -- Return the result of the function
       RETURN @Result

END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SplitJoin]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_SplitJoin] 
(
       -- Add the parameters for the function here
       @StringWithDelimiters varchar(MAX)
       , @Delimiter char(1) = ','
       , @Prefix varchar(MAX) = ''
       , @Sufix varchar(MAX) = ''
       , @NewDelimiter varchar(MAX) = NULL
)
RETURNS varchar(MAX)
AS
BEGIN
       -- Declare the return variable here
       DECLARE @Result varchar(MAX) = '';

       DECLARE @Temp varchar(MAX) = NULL;


       -- Add the T-SQL statements to compute the return value here
    
       if len(@StringWithDelimiters)<1 or @StringWithDelimiters is NULL  return NULL;     
   
    if (len(@NewDelimiter)<1 or @NewDelimiter is NULL) SET @NewDelimiter = @Delimiter;
       declare @idx int = 1;     
       declare @slice varchar(8000);

       while @idx!= 0     
       begin     
             set @idx = charindex(@Delimiter,@StringWithDelimiters)     
             if (@idx!=0) BEGIN 
                    set @slice =left(@StringWithDelimiters,@idx - 1); 
                    set @StringWithDelimiters = right(@StringWithDelimiters,len(@StringWithDelimiters) - @idx)
             END    
             ELSE BEGIN    
                    set @slice = @StringWithDelimiters;
                    set @StringWithDelimiters = '';
             END
             
             if(len(@slice)>0) SET @Result =  @Result +  @Prefix + @Slice + @Sufix ;

             --set @StringWithDelimiters = right(@StringWithDelimiters,len(@StringWithDelimiters) - @idx)     
             if (len(@StringWithDelimiters) = 0)  break; 
             ELSE SET @Result = @Result +  @NewDelimiter;    
       end 
       
       -- Return the result of the function
       RETURN @Result

	   
--select [dbo].[fn_SplitJoin]('P_4000_AI_9160_01,P_4000_AI_9160_02',',','','',' - ') 
--'P_4000_AI_9160_01 - P_4000_AI_9160_02'

--select dbo.fn_SplitJoin('P_4000_AI_9160_01,P_4000_AI_9160_02',',','''','''',', '); 
--'P_4000_AI_9160_01','P_4000_AI_9160_02';


--IF (@Actual != @Expected) Raiserror(@Actual, 16, 1)
--ELSE Print('Test passed');

END


GO
/****** Object:  UserDefinedFunction [dbo].[fnCalcTimeStep]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnCalcTimeStep] 
(
	-- Add the parameters for the function here
	@StartDate DateTime,
	@EndDate DateTime,
	@NbrOfPoints int
)
RETURNS Time(0)
AS
BEGIN
	DECLARE @Result time(0), @holderDate DateTime

	IF (@StartDate > @EndDate) BEGIN
		SET @holderDate = @EndDate;
		SET @EndDate = @StartDate;
		SET @StartDate = @holderDate;
	END

	DECLARE @seconds int = DateDiff(SECOND,@StartDate,@EndDate);
	DECLARE @timeStep int = @seconds/@NbrOfPoints;
	


	-- Compute in milliseconds to facilitate conversion
	SELECT @Result = Cast(CONVERT(varchar, DATEADD(ms, @timeStep * 1000, 0), 114) as time(0));

	-- Return the result of the function
	RETURN @Result

-- Unit Tests
--SELECT [dbo].fnCalcTimeStep('2023-01-01 00:01:00', '2023-01-01 00:02:00', 60) --> 00:00:01 
--SELECT [dbo].fnCalcTimeStep('2023-01-01 01:00:00', '2023-01-01 02:00:00', 60) --> 00:01:00 
--SELECT [dbo].fnCalcTimeStep('2023-01-01 01:00:00', '2023-01-07 01:00:00', 60) --> > 02:00:00 

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetBAUExcursions]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[fnGetBAUExcursions](
	@AfterDate DateTime
	, @BeforeDate DateTime
	, @TagIdsList varchar(max)
	, @MinDurationInSecs int 
	, @ActiveOnly int 
)
RETURNS @ExcursionsTbl TABLE (
  Building varchar(50)
, lAreaID int
, lUnitID int
, Area varchar(50) NULL
, Unit varchar(20)
, TagId int NULL
, TagName varchar(255)
, TagExcNbr int
, StepLogId int NULL
, RampInDate datetime NULL
, RampInValue float NULL
, FirstExcDate datetime NULL
, FirstExcValue float NULL
, LastExcDate datetime NULL
, LastExcValue float NULL
, RampOutDate datetime NULL
, RampOutValue float NULL
, HiPointsCt int
, LowPointsCt int
, MinThreshold float NULL
, MaxThreshold float NULL
, MinValue float NULL
, MaxValue float NULL
, AvergValue float NULL
, StdDevValue float NULL
, Duration int NULL
, ThresholdDuration int NULL
, SetPoint float NULL
, sTagDesc varchar(100)
, sEGU varchar(20)
, StageDeprecatedDate datetime NULL
, StageDateDeprecatedDate datetime NULL
, ProductionDate datetime NULL
, ExcType varchar(3)
, StructDuration varchar(20) NULL
, CalcDuration varchar(16) NULL
, StructMinDuration varchar(16) NULL
, OverlapStartDate DateTime NULL
, OverlapEndDate DateTime NULL
, SetPointEGU varchar(255)
)
AS BEGIN

INSERT INTO @ExcursionsTbl
SELECT * 
, [dbo].[fnToStructDuration](COALESCE(@MinDurationInSecs, ThresholdDuration))  as CalcDuration 
, [dbo].[fnToStructDuration](COALESCE(@MinDurationInSecs, ThresholdDuration))  as StructMinDuration
, (SELECT StartDate  FROM [dbo].[fnGetOverlappingDates](@AfterDate, @BeforeDate, FirstExcDate, LastExcDate)) as OverlapStartDate
, (SELECT EndDate  FROM [dbo].[fnGetOverlappingDates](@AfterDate, @BeforeDate, FirstExcDate, LastExcDate)) as OverlapEndDate
, Concat(SetPoint, ' ',sEGU) as SetPointEGU

FROM BAUExcursions
WHERE  
(SELECT StartDate  FROM [dbo].[fnGetOverlappingDates](@AfterDate, @BeforeDate, FirstExcDate, LastExcDate)) IS NOT NULL
AND Duration >= COALESCE(@MinDurationInSecs, ThresholdDuration)
AND (@TagIdsList is null OR TagId in (SELECT value FROM STRING_SPLIT( @TagIdsList, ',')))
AND (@ActiveOnly IS NULL OR (SELECT StartDate  FROM [dbo].[fnGetOverlappingDates]
(FirstExcDate, LastExcDate, ProductionDate, StageDeprecatedDate)) IS NOT NULL);
 
RETURN;

--SELECT * FROM fnGetBAUExcursions('2023-02-01','2023-02-28','14997',10*60, 1);
--SELECT * FROM fnGetBAUExcursions('2023-01-01','2023-02-28','14997, 15767, 16627, 16667',NULL, NULL);
--SELECT * FROM fnGetBAUExcursions('2023-01-01','2023-02-28',NULL,10*60, NULL);
--SELECT * FROM fnGetBAUExcursions('2023-02-01','2023-03-01',NULL, NULL, NULL);
--SELECT * FROM fnGetBAUExcursions('2023-01-01','2023-02-28',NULL, 0, 1);
--SELECT * from  dbo.fnGetOverlappingDates('2023-02-01', '2023-02-28', NULL, NULL) as v;
--SELECT *  FROM [dbo].[fnGetOverlappingDates]('2023-02-01','2023-02-28', '2023-01-01', '2023-03-01')
END

GO
/****** Object:  UserDefinedFunction [dbo].[fnGetExcursionsCounts]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetExcursionsDetails]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetInterp2]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnGetInterp2] 
(	
	-- Add the parameters for the function here
	@TagName varchar(255), 
	@StartDate datetime,
	@EndDate datetime,
	@TimeStep time(0)
)
RETURNS @Interop TABLE (tag varchar(255), time datetime2(7), value float NULL
, svalue nvarchar(4000) NULL, status int NULL, timestep time(0))
AS
BEGIN

		INSERT INTO @Interop
		SELECT c.tag, c.time, c.value, NULL as svalue, null as status, @TimeStep as timestep from dbo.CompressedPoints as c
		WHERE tag = @TagName 
		AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		AND value is not NULL
		
		--INSERT INTO @Interop
		--SELECT * from PI.piarchive..piinterp
		--WHERE tag = @TagName 
		--AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		--AND value is not NULL
		--AND timestep = @TimeStep;


		--AND timestep = cast(CONCAT('00:00:', @TimeStepInSeconds) as time(0))
		--ORDER BY tag, time asc; THIS DOESN"T WORK.

		--UNIT TESTS
		--SELECT * from [dbo].[fnGetInterp2]('chamber_report_tag_1', '2022-10-31', '2022-11-30','00:00:30')

--INSERT INTO @Interop
--SELECT * FROM OPENQUERY(PI, '
--    SELECT *
--    FROM piarchive..piinterp
--    WHERE tag = ''P_4000_AI_9160_01''
--    AND time BETWEEN ''2022-04-11'' AND ''2022-04-12''
--	AND value is not null
--    AND TimeStep=''10s''
--')


RETURN ; 

END
GO
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 7/24/2023 1:45:52 PM ******/
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
	--Unit Tests
--SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-03-31','2023-02-01','2023-02-27') 
	--> 2023-02-01 00:00:00.000 | 2023-02-27 00:00:00.000
--SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-03-31','2023-02-01',NULL) 
	--> 2023-02-01 00:00:00.000 | 2023-03-31 00:00:00.000
--SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-01-31','2023-02-01','2023-02-27') 
	--> NULL | NULL

--SELECT StartDate From (SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-03-31','2023-02-01',NULL)) as ovr
	-->2023-02-01 00:00:00.000
--SELECT CASE WHEN StartDate IS NULL THEN 'True' ELSE ' false' END From (SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-01-31','2023-02-01','2023-02-27')) as ovr
	-->True
END;


GO
/****** Object:  UserDefinedFunction [dbo].[fnGetScheduleDates]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- GetScheduleDatesForDate('2022-11-03', '2022-10-02', 1, week, 1, month) returns '2022-10-30', '2022-11-05'
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


-- UNIT TESTS
-- SELECT * from GetScheduleDatesForDate('2022-11-03', '2022-10-02', 1, 'week', 1, 'month')
-- 2022-11-02	2022-11-09
-- SELECT * from GetScheduleDatesForDate('2022-11-10', '2022-10-02', 1, 'week', 1, 'month')
-- NULL	NULL
GO
/****** Object:  UserDefinedFunction [dbo].[fnSplit]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnSplit]
(
    @Line nvarchar(MAX),
    @SplitOn nvarchar(5) = ','
)
RETURNS @RtnValue table
(
    Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    Data nvarchar(100) NOT NULL
)
AS
BEGIN
    IF @Line IS NULL RETURN;

    DECLARE @split_on_len INT = LEN(@SplitOn);
    DECLARE @start_at INT = 1;
    DECLARE @end_at INT;
    DECLARE @data_len INT;

    WHILE 1=1
    BEGIN
        SET @end_at = CHARINDEX(@SplitOn,@Line,@start_at);
        SET @data_len = CASE @end_at WHEN 0 THEN LEN(@Line) ELSE @end_at-@start_at END;
        INSERT INTO @RtnValue (data) VALUES( SUBSTRING(@Line,@start_at,@data_len) );
        IF @end_at = 0 BREAK;
        SET @start_at = @end_at + @split_on_len;
    END;

    RETURN;

	--SELECT Cast(data as int) * 10 from dbo.fnSplit('11,12,13',',')

END;
GO
/****** Object:  UserDefinedFunction [dbo].[fnToDuration]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Function [dbo].[fnToDuration] 
	( @SDuration varchar(12) )
	RETURNS int WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	DECLARE @Result int ;
	DECLARE @sdays varchar(12), @days int, @time varchar(8);
	-- Does input @SDuration contain a days ('d') delimitir? if not return NULL
	if (Charindex('d', @SDuration) = 0 ) RETURN NULL;
	Select  @sdays = Substring(@SDuration, 1,Charindex('d', @SDuration)-1);
	-- Reject days if it is not a numeric by returning NULL
	if (isNumeric(@sdays) = 0) RETURN NULL
	ELSE set @days = cast(@sdays as int);

	DECLARE @hh int, @mm int, @ss int;
	DECLARE @shh varchar(12), @smm varchar(12), @sss varchar(12);
	
	IF (LEN(@SDuration) <= LEN(@sdays)) RETURN NULL; --nothing else to parse
	-- get balance of @SDuration to parse as @time
	SELECT @time = Substring(@SDuration, Charindex('d', @SDuration)+1, LEN(@SDuration));

	--parse hours
	if (Charindex(':', @time) = 0 ) RETURN NULL;
	Select  @shh = Substring(@time, 1,Charindex(':', @time)-1);
	if (isNumeric(@shh) = 0) RETURN NULL
	else set @hh = cast(@shh as int);

	IF (LEN(@time) <= LEN(@shh)) RETURN NULL; --nothing else to parse
	-- get balance of @time to parse
	SELECT @time = Substring(@time, Charindex(':', @time)+1, LEN(@time));

		--parse minutes
	if (Charindex(':', @time) = 0 ) RETURN NULL;
	Select  @smm = Substring(@time, 1,Charindex(':', @time)-1);
	if (isNumeric(@smm) = 0) RETURN NULL
	else set @mm = cast(@smm as int);

	IF (LEN(@time) <= LEN(@smm)) RETURN NULL; --nothing else to parse
	-- get balance of @time to parse
	SELECT @time = Substring(@time, Charindex(':', @time)+1, LEN(@time));

	--parse seconds
	Select  @sss = @time;
	if (isNumeric(@sss) = 0) RETURN NULL
	else set @ss = cast(@sss as int);

	SET @Result = @ss + @mm * 60 + @hh * (60 * 60) + @days * (24 * 60 * 60);

	--Select  @mm = Substring(@time, 4, 2), @ss = Substring(@time, 7, 2);
	--SET @Result = @ss + @mm * 60 + @hh * (60 * 60) + @days * (24 * 60 * 60);

	RETURN @Result;

--SELECT dbo.fnToDuration('000d00:01:30');-- result 90
--SELECT dbo.fnToDuration('000d01:00:00');-- result 3600
--SELECT dbo.fnToDuration('0d01:00:00');-- result 3600
--SELECT dbo.fnToDuration('0d100:00:00');-- result 360000
--SELECT dbo.fnToDuration('1d');-- result NULL
--SELECT dbo.fnToDuration('0d00:01:00');-- result 60
--SELECT dbo.fnToDuration('0d0:1:00');-- result 60
END


GO
/****** Object:  UserDefinedFunction [dbo].[fnToStructDuration]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnToStructDuration] 
(
	-- Add the parameters for the function here
	@totalSeconds int
)
RETURNS varchar(20) WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	-- Declare the return variable here
	DECLARE @Result varchar(20)


	DECLARE @days BIGINT, @hours BIGINT, @minutes BIGINT, @seconds BIGINT
	DECLARE @KEEP DATETIME

	SET @days = @totalSeconds / (24 * 60 * 60); -- division result is truncated to an integer

	Set @totalSeconds = (@totalSeconds - (@days * 24 * 60 * 60));
	SET @hours = @totalSeconds / (60 * 60); 
	
	SET @totalSeconds = (@totalSeconds - (@hours * 60 * 60));
	SET @minutes = @totalSeconds / 60;

	SET @totalSeconds = @totalSeconds - (@minutes * 60);
	SET @seconds = @totalSeconds;

	SET @Result = CONCAT(':', RIGHT('00' + CAST(@seconds as varchar(2)),2));
	SET @Result = CONCAT(':', RIGHT('00' + CAST(@minutes as varchar(2)),2),@Result); 
	SET @Result = CONCAT(':', RIGHT('00' + CAST(@hours as varchar(2)),2),@Result); 
	SET @Result = CONCAT(RIGHT('00' + CAST(@days as varchar(3)),2),@Result); 
	
	RETURN @Result;

--select [dbo].[fnToStructDuration](31539690);
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-01 01:01:30'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-01 00:2:1'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-03 01:01:30'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2023-01-01 01:01:30'));
--SELECT DATEDIFF(second,'2022-01-01 00:00:00', '2023-01-01 01:01:30');

END



GO
/****** Object:  Table [dbo].[Stages]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Stages](
	[StageId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NOT NULL,
	[StageName] [nvarchar](255) NULL,
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[TimeStep] [float] NULL,
	[ProductionDate] [datetime] NULL,
	[DeprecatedDate] [datetime] NULL,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
 CONSTRAINT [PK_Stages] PRIMARY KEY CLUSTERED 
(
	[StageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tags]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  Table [dbo].[StagesDates]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  View [dbo].[StagesLimitsAndDatesCore]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[StagesLimitsAndDatesCore]
AS
SELECT t .TagId, t .TagName, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold, std.StartDate, std.EndDate, st.TimeStep, st.StageId
, st.ThresholdDuration, st.SetPoint, st.DeprecatedDate AS StageDeprecatedDate, std.DeprecatedDate AS StageDateDeprecatedDate, st.ProductionDate
, COALESCE(st.DeprecatedDate, std.DeprecatedDate) as DeprecatedDate
, IIF((st.DeprecatedDate IS NULL AND std.DeprecatedDate IS NULL), Cast(0 as bit), Cast(1 as bit)) AS IsDeprecated
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t .TagId
WHERE (MinThreshold IS NOT NULL or MaxThreshold IS NOT NULL)
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT std.TagId, std.TagName, std.StageDateId, std.StageName, std.MinThreshold, std.MaxThreshold, std.StartDate, std.EndDate
, std.TimeStep, std.StageId, std.ThresholdDuration, std.SetPoint
FROM  StagesLimitsAndDatesCore as std
WHERE (std.DeprecatedDate is null)
GO
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  Index [ixPointsPacesStageDateId]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE CLUSTERED INDEX [ixPointsPacesStageDateId] ON [dbo].[PointsPaces]
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PointsStepsLogNextValues]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[PointsStepsLogNextValues]
AS
SELECT sld.StageDateId, sld.StageName, T .TagId, T .TagName, sld.StartDate AS StageStartDate, sld.EndDate AS StageEndDate
, sld.MinThreshold, sld.MaxThreshold, pp.PaceId, pp.NextStepStartDate AS PaceStartDate, pp.NextStepEndDate AS PaceEndDate
, ods.StartDate, ods.EndDate, sld.ThresholdDuration, sld.SetPoint 
FROM  Tags AS t 
INNER JOIN dbo.StagesLimitsAndDates AS sld ON t .TagId = sld.TagId 
INNER JOIN dbo.PointsPaces AS pp ON sld.StageDateId = pp.StageDateId 
CROSS APPLY[dbo].[fnGetOverlappingDates](sld.StartDate, sld.EndDate, pp.NextStepStartDate, pp.NextStepEndDate) AS ods
WHERE t .TagName IS NOT NULL AND ods.StartDate IS NOT NULL AND ods.EndDate IS NOT NULL AND pp.ProcessedDate IS NULL
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 7/24/2023 1:45:52 PM ******/
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
	[StageDateId] [int] NULL,
	[RampInDate] [datetime] NULL,
	[RampInValue] [float] NULL,
	[FirstExcDate] [datetime] NULL,
	[FirstExcValue] [float] NULL,
	[LastExcDate] [datetime] NULL,
	[LastExcValue] [float] NULL,
	[RampOutDate] [datetime] NULL,
	[RampOutValue] [float] NULL,
	[HiPointsCt] [bigint] NULL,
	[LowPointsCt] [bigint] NULL,
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL,
	[AvergValue] [float] NULL,
	[StdDevValue] [float] NULL,
	[Duration]  AS (datediff(second,[FirstExcDate],[LastExcDate])) PERSISTED,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
	[DeprecatedDate] [datetime] NULL,
	[IsDeprecated]  AS (case when [DeprecatedDate] IS NULL then CONVERT([bit],(0)) else CONVERT([bit],(1)) end),
 CONSTRAINT [pkExcursionPointsCycleId] PRIMARY KEY NONCLUSTERED 
(
	[CycleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsRampInDateTagNameTagExcNbr]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE CLUSTERED INDEX [ixExcursionPointsRampInDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC,
	[RampInDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BuildingsAreasUnits]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BuildingsAreasUnits](
	[lBuildingID] [int] NOT NULL,
	[Building] [varchar](max) NULL,
	[lAreaID] [int] NOT NULL,
	[Area] [varchar](max) NULL,
	[lUnitID] [int] NOT NULL,
	[Unit] [varchar](max) NULL,
	[lTagID] [int] NOT NULL,
	[Tag] [varchar](max) NULL,
	[sEGU] [varchar](20) NOT NULL,
	[sTagDesc] [varchar](max) NULL,
 CONSTRAINT [PK_BuildingAreasUnits] PRIMARY KEY CLUSTERED 
(
	[lBuildingID] ASC,
	[lAreaID] ASC,
	[lUnitID] ASC,
	[lTagID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[BAUExcursions]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  View [BB50PCSjsantos].[LatestSqlChanges]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [BB50PCSjsantos].[LatestSqlChanges]
AS
SELECT        name, object_id, principal_id, schema_id, parent_object_id, type, type_desc
                      , [BB50PCSjsantos].fnYYYYMM(modify_date) AS modYYYYMM
                      , [BB50PCSjsantos].fnYYYYMM(create_date) AS crtYYYYMM
                      , create_date, modify_date, is_ms_shipped, is_published, is_schema_published
FROM            sys.objects
WHERE  type not in ('PK','D','F') AND  schema_id = 1 AND    
(type_desc NOT LIKE '%system%') AND (type_desc NOT LIKE '%internal%') AND (type_desc NOT LIKE '%service%')
GO
/****** Object:  Table [BB50PCSjsantos].[HiExcursion]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCSjsantos].[HiExcursion](
	[XdateStr] [datetime2](7) NOT NULL,
	[CVal] [float] NOT NULL,
 CONSTRAINT [PK_HiExcursion] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BB50PCSjsantos].[Interpolated]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCSjsantos].[Interpolated](
	[tag] [varchar](255) NOT NULL,
	[Time] [datetime2](7) NOT NULL,
	[Value] [float] NOT NULL,
 CONSTRAINT [pkInterpolated] PRIMARY KEY CLUSTERED 
(
	[tag] ASC,
	[Time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BB50PCSjsantos].[LowExcursion]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCSjsantos].[LowExcursion](
	[XdateStr] [datetime2](7) NOT NULL,
	[CVal] [float] NOT NULL,
 CONSTRAINT [PK_LowExcursion] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BB50PCSjsantos].[OneHiOneLowOneDay]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCSjsantos].[OneHiOneLowOneDay](
	[XdateStr] [datetime2](7) NOT NULL,
	[CVal] [float] NOT NULL,
 CONSTRAINT [PK_OneHiOneLowOneDay] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [BB50PCSjsantos].[OneHiOneLowTwoDays]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BB50PCSjsantos].[OneHiOneLowTwoDays](
	[XdateStr] [datetime2](7) NOT NULL,
	[CVal] [float] NOT NULL,
 CONSTRAINT [PK_OneHiOneLowTwoDays] PRIMARY KEY CLUSTERED 
(
	[XdateStr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompressedPoints]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  Table [dbo].[ExcursionPointsCopy]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExcursionPointsCopy](
	[CycleId] [int] IDENTITY(1,1) NOT NULL,
	[TagId] [int] NULL,
	[TagName] [varchar](255) NOT NULL,
	[TagExcNbr] [int] NOT NULL,
	[StepLogId] [int] NULL,
	[StageDateId] [int] NULL,
	[RampInDate] [datetime] NULL,
	[RampInValue] [float] NULL,
	[FirstExcDate] [datetime] NULL,
	[FirstExcValue] [float] NULL,
	[LastExcDate] [datetime] NULL,
	[LastExcValue] [float] NULL,
	[RampOutDate] [datetime] NULL,
	[RampOutValue] [float] NULL,
	[HiPointsCt] [bigint] NULL,
	[LowPointsCt] [bigint] NULL,
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[MinValue] [float] NULL,
	[MaxValue] [float] NULL,
	[AvergValue] [float] NULL,
	[StdDevValue] [float] NULL,
	[Duration] [int] NULL,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
	[DeprecatedDate] [datetime] NULL,
	[IsDeprecated] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ExcursionStats]    Script Date: 7/24/2023 1:45:52 PM ******/
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
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PointsStepsLog](
	[StepLogId] [int] IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL,
	[StageId] [int] NOT NULL,
	[TagId] [int] NOT NULL,
	[TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL,
	[StageEndDate] [datetime] NULL,
	[DeprecatedDate] [datetime] NULL,
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[PaceId] [int] NOT NULL,
	[PaceStartDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
 CONSTRAINT [pkPointsStepsLogPaceLogId] PRIMARY KEY CLUSTERED 
(
	[StepLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixExcursionPointsRampoutDateTagNameTagExcNbr]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE NONCLUSTERED INDEX [ixExcursionPointsRampoutDateTagNameTagExcNbr] ON [dbo].[ExcursionPoints]
(
	[TagName] ASC,
	[TagExcNbr] ASC,
	[RampOutDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ixExcursionPointsStageDateId]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE NONCLUSTERED INDEX [ixExcursionPointsStageDateId] ON [dbo].[ExcursionPoints]
(
	[StageDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IxTagStageName]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IxTagStageName] ON [dbo].[Stages]
(
	[TagId] ASC,
	[StageName] ASC
)
WHERE ([StageName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IxStagesDatesTagIdStartDate]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE NONCLUSTERED INDEX [IxStagesDatesTagIdStartDate] ON [dbo].[StagesDates]
(
	[StageId] ASC,
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ixTagsTagName]    Script Date: 7/24/2023 1:45:52 PM ******/
CREATE NONCLUSTERED INDEX [ixTagsTagName] ON [dbo].[Tags]
(
	[TagName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PointsPaces] ADD  CONSTRAINT [DF_PointsPaces_StepSizeDays]  DEFAULT ((2)) FOR [StepSizeDays]
GO
ALTER TABLE [dbo].[Stages] ADD  CONSTRAINT [DF__Stages__MaxValue__440B1D61]  DEFAULT ((3.4000000000000000e+038)) FOR [MaxThreshold]
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
/****** Object:  StoredProcedure [BB50PCSjsantos].[CreateCompressedPoint]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [BB50PCSjsantos].[CreateCompressedPoint] 
	-- Add the parameters for the stored procedure here
	@CurveName varchar(32) = 'HiExcursion', 
	@tagName varchar(256) ,
	@offsetDays int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@CurveName = 'HiExcursion') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers_copy].[BB50PCSjsantos].[HiExcursion]
		END
		ELSE IF (@CurveName = 'LowExcursion') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers_copy].[BB50PCSjsantos].LowExcursion
		END
		ELSE IF (@CurveName = 'OneHiOneLowOneDay') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers_copy].[BB50PCSjsantos].OneHiOneLowOneDay
		END
		ELSE IF (@CurveName = 'OneHiOneLowTwoDays') BEGIN
			select @TagName as tag, DateAdd(Day,@OffsetDays,XdateStr) as time, CVal as value 
				from [ELChambers_copy].[BB50PCSjsantos].OneHiOneLowTwoDays
		END
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'HiExcursion', 'my tag', 130
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'LowExcursion', 'my tag', 150
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'OneHiOneLowOneDay', 'my tag', 140
		--EXEC [BB50PCSjsantos].CreateCompressedPoint 'OneHiOneLowTwoDays', 'my tag', 160

END
GO
/****** Object:  StoredProcedure [BB50PCSjsantos].[spSeedForTests]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [dbo].[GetBAUExcursions]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetBAUExcursions] 
	-- Add the parameters for the stored procedure here
	@TagsList varchar(max),  @AfterDate DateTime = NULL, @BeforeDate DateTime = null, @DurationThreshold int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF (@AfterDate IS null) SET @AfterDate = DATEFROMPARTS(YEAR(GetDate()),1,1);
	IF (@BeforeDate IS null) SET @BeforeDate = DATEADD(day,-1,GetDate());
	
	SELECT * from [dbo].[BAUExcursions] as BE
	WHERE BE.TagId in (SELECT * FROM STRING_SPLIT(@TagsList,','))
	AND BE.FirstExcDate >= @AfterDate AND BE.FirstExcDate < @BeforeDate
	AND (
		(@DurationThreshold is NULL AND BE.Duration > BE.ThresholdDuration)
		OR
		(@DurationThreshold is NOT NULL AND BE.Duration > @DurationThreshold)
	)

	--MUST USE TagIds instead of TagNames
	--EXEC GetBAUExcursions '15767'
	--EXEC GetBAUExcursions '15767,16667'
	--EXEC GetBAUExcursions '15767,16667', NULL, NULL, 0
	--EXEC GetBAUExcursions '15767,16667', NULL, NULL, 10000
	--SELECT DISTINCT * FROM (  VALUES (1), (1), (1), (2), (5), (1), (6)) as list(val);
END
GO
/****** Object:  StoredProcedure [dbo].[spGetStats]    Script Date: 8/10/2023 5:25:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetStats]
	@TagName varchar(255), 
	@FirstExcDate DateTime,
	@LastExcDate DateTime,
	@ExcPointsCount int NULL OUTPUT,
	@MinValue float NULL OUTPUT,
	@MaxValue float NULL OUTPUT,
	@AvergValue float NULL OUTPUT,
	@StdDevValue float NULL OUTPUT
AS
BEGIN
PRINT '>>> spGetStats begins'


		--SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate,'00:00:01');

		SELECT @ExcPointsCount = count(*),  @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate,'00:00:01');
			FROM [BB50PCSjsantos].Interpolated as Stat
			WHERE Stat.tag = @TagName  and Stat.time >= @FirstExcDate And Stat.Time <= @LastExcDate;

PRINT 'spGetStats ends <<<'

END

/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
       @FromDate datetime, -- Processing Start date
       @ToDate datetime, -- Processing ENd date
       @StageDateIds nvarchar(max) = null

AS
BEGIN
PRINT CONCAT('>>> spDriverExcursionsPointsForDate @FromDate:', Format(@FromDate,'yyyy-MM-dd')
		,' @ToDate:', Format(@ToDate,'yyyy-MM-dd'),' @StageDateIds:',@StageDateIds);

       SET NOCOUNT ON;
       
       -- Processing StageDates
       DECLARE @StageDateIdsTable TABLE (StageDateId int);
       IF (@StageDateIds IS NOT NULL) BEGIN
              INSERT INTO @StageDateIdsTable
              SELECT value from STRING_SPLIT(@StageDateIds, ',')
       END;

       -- Processing Tag details
       DECLARE @StagesLimitsAndDatesCore TABLE (
              RowID int not null primary key identity(1,1)
              , TagId int, TagName nvarchar(255), StageDateId int, StageName nvarchar(255) NULL
              , MinThreshold float, MaxThreshold float, StartDate datetime, EndDate datetime
              , TimeStep float null, StageId int, ThresholdDuration int NULL, SetPoint float NULL
              , StageDeprecatedDate datetime NULL, StageDateDeprecatedDate datetime NULL
              , ProductionDate datetime NULL, DeprecatedDate datetime, IsDeprecated bit
              , PaceId int, NextStepStartDate datetime, NextStepEndDate datetime
              , ProcessedDate datetime NULL, StepSizeDays int
       )

       --PRINT 'Get PointPaces for all StagesDatesId. If PointsPaces doesnt exist for a StageDate manufacture one.'
       --PRINT 'If StagesDatesId list not informed use all StagesDates configured'
       INSERT INTO @StagesLimitsAndDatesCore
       SELECT TagId, TagName, sldc.StageDateId, StageName 
              , MinThreshold, MaxThreshold, StartDate, EndDate
              , TimeStep, StageId, ThresholdDuration, SetPoint 
              , StageDeprecatedDate, StageDateDeprecatedDate 
              , ProductionDate, DeprecatedDate, IsDeprecated
              , ISNULL(pp.PaceId,-1) as PaceId
              , ISNULL(pp.NextStepStartDate,@FromDate) as NextStepStartDate, pp.NextStepEndDate
              , pp.ProcessedDate, ISNULL(PP.StepSizeDays,1) as StepSizeDays
              FROM [dbo].[StagesLimitsAndDatesCore] as sldc left join 
              (                     SELECT P1.PaceId, P1.StageDateId, P1.NextStepStartDate, P1.NextStepEndDate, P1.ProcessedDate, P1.StepSizeDays 
                             FROM PointsPaces as P1 WHERE P1.ProcessedDate IS NULL 
              ) as PP 
              ON sldc.StageDateId = PP.StageDateId OR PP.PaceId = -1
              WHERE (@StageDateIds IS NULL OR sldc.StageDateId in (SELECT StageDateId From @StageDateIdsTable));


       DECLARE @ExcPoints as TABLE ( RowID int not null primary key identity(1,1), NewRowId int
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, ThresholdDuration int, SetPoint float);

       DECLARE @ExcPointsWIP as TABLE ( RowID int NULL
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, ThresholdDuration int, SetPoint float);

       DECLARE @ExcPointsOutput as TABLE ( RowID int NULL, NewRowId int
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, ThresholdDuration int, SetPoint float);

       -- If no Tag details found abort (details are not configured).
       IF (NOT EXISTS(SELECT * FROM @StagesLimitsAndDatesCore)) BEGIN
              PRINT '<<< spDriverExcursionsPointsForDate aborted';
              SELECT * FROM @ExcPoints;
              RETURN -1;
       END;
--*****************************************************************************************
       PRINT ' >>> GET new excursions in date range'

       DECLARE @StgDtCount int, @CurrStgDtIx int = 1;
       SELECT @StgDtCount = count(*) from @StagesLimitsAndDatesCore;
       --PRINT 'Process every StageDate'
       WHILE @CurrStgDtIx <= @StgDtCount BEGIN
              DECLARE @CurrStageDateId int, @StageId int, @TagId int, @TagName varchar(255)
              , @ProductionDate datetime, @DeprecatedDate datetime
              , @StageStartDate datetime, @StageEndDate datetime
              , @CurrStepStartDate datetime, @CurrStepEndDate datetime, @StepSizedays int
              , @MinThreshold float, @MaxThreshold float, @ThresholdDuration float, @SetPoint float
              , @PaceId int;
              SELECT @CurrStageDateId = StageDateId, @StageId = StageId, @TagId = TagId, @TagName = TagName
              , @ProductionDate = ProductionDate, @DeprecatedDate = DeprecatedDate
              , @StageStartDate = StartDate, @StageEndDate = EndDate
              , @CurrStepStartDate = NextStepStartDate, @CurrStepEndDate = NextStepEndDate, @StepSizedays = StepSizedays
              , @MinThreshold = MinThreshold, @MaxThreshold = MaxThreshold
              , @ThresholdDuration = ThresholdDuration, @SetPoint = SetPoint
              , @PaceId = PaceId
              FROM @StagesLimitsAndDatesCore WHERE RowID = @CurrStgDtIx;

              if (@CurrStepStartDate < @ProductionDate) BEGIN
                      SET @CurrStepStartDate = @ProductionDate;
              END
              SET @CurrStepEndDate = DateAdd(day, @StepSizedays, @CurrStepStartDate);

              --PRINT CONCAT('Processing StageDateId:', @CurrStageDateId,' TagName:', @TagName, ' for ...');
              --Get processing date region
              DECLARE @ProcStartDate as datetime, @ProcEndDate as datetime;
              SELECT @ProcStartDate = StartDate,  @ProcEndDate = EndDate 
                      FROM [dbo].[fnGetOverlappingDates](@ProductionDate, @DeprecatedDate, @FromDate, @ToDate);
              --PRINT CONCAT('...- Processing Start date:', Format(@ProcStartDate,'yyyy-MM-dd'),' and End date:', FORMAT(@ProcEndDate, 'yyyy-MM-dd'));
              IF (@ProcStartDate is NULL) BEGIN 
                      --PRINT CONCAT('valid processing dates not found for StageDateId', @CurrStageDateId);
                      SET @CurrStgDtIx=@CurrStgDtIx+1;
                      CONTINUE; 
              END;

              DECLARE @ProcNextStepStartDate datetime, @ProcNextStepEndDate datetime
              SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
                      FROM [dbo].[fnGetOverlappingDates](@ProcStartDate, @ProcEndDate
                      , @CurrStepStartDate, ISNULL(@CurrStepEndDate, DATEADD(day,@StepSizedays,@CurrStepStartDate)));

              IF (@DeprecatedDate IS NOT NULL) SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
                                    FROM [dbo].[fnGetOverlappingDates](@ProcNextStepStartDate, @ProcNextStepEndDate, NULL, @DeprecatedDate);

              --PRINT 'processing first Step using...'; 
              --PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd'),' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));
                      
              --BEGIN TRAN;
              --PRINT 'Process one day'
              WHILE @ProcNextStepEndDate <= @ProcEndDate BEGIN

                --PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @TagName, ''', ''', ' StageDateId:', @CurrStageDateId); 
                --PRINT CONCAT(FORMAT(@ProcNextStepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'), ''', ');
                --PRINT CONCAT(CONVERT(varchar(255), @MinThreshold), ', ', CONVERT(varchar(255), @MaxThreshold), ', ')
                --PRINT CONCAT(Convert(varchar(16), @TagId), ', '); 
                --PRINT CONCAT(Convert(varchar(16), @ThresholdDuration), ', ', Convert(varchar(16), @SetPoint));

                -- Update or insert PointsPaces row
                DECLARE @currPaceId int = null;
                IF (@PaceId <= 0) BEGIN
                        INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
                                    VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays , GetDate() ); 
                        SET @currPaceId = SCOPE_IDENTITY();
                END
                ELSE BEGIN
                        UPDATE [dbo].[PointsPaces] SET ProcessedDate = GetDate()
                        WHERE PaceId = @PaceId;
                        SET @currPaceId = @PaceId;
                        SET @PaceId = -1; --subsequent PointsPaces should be inserted after the first update
                END
                      
                -- Insert Log
                DECLARE @StepLogId int;
                INSERT INTO [dbo].[PointsStepsLog] (
                                    [StageDateId], [StageId], [TagId], [TagName]
                                ,[StageStartDate], [StageEndDate], [DeprecatedDate]
                                ,[MinThreshold], [MaxThreshold]
                                ,[PaceId], [PaceStartDate]
                                ,[StartDate], [EndDate]
                                ,[ThresholdDuration], [SetPoint]
                            )
                        VALUES (
                                    @CurrStageDateId, @StageId, @TagId, @TagName
                                ,@StageStartDate, @StageEndDate, @DeprecatedDate
                                ,@MinThreshold, @MaxThreshold
                                ,@currPaceId, @ProcNextStepStartDate
                                ,@ProcNextStepStartDate, @ProcNextStepEndDate
                                ,@ThresholdDuration, @SetPoint
                            )
                SET @StepLogId = SCOPE_IDENTITY();

                --PRINT 'Find Excursions in date range'
                DECLARE @pivotReturnValue int = 0;
                INSERT INTO @ExcPoints (
                        [CycleId], [StageDateId], [TagId], [TagName], [TagExcNbr]
                , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
                , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
                , [HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
                , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
                , [ThresholdDuration], [SetPoint]
                )
                EXECUTE @pivotReturnValue = [dbo].[spPivotExcursionPoints] @CurrStageDateId, @ProcNextStepStartDate
                        , @ProcNextStepEndDate, @MinThreshold, @MaxThreshold, '00:00:01';
				UPDATE @ExcPoints SET StepLogId = @StepLogId WHERE StepLogId IS NULL;

                DECLARE @dbgExcsFound int, @dbgFirstExcDate datetime;
                SELECT @dbgExcsFound = count(*) from @ExcPoints;
                SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
                --PRINT CONCAT('DEBUG: @dbgExcsFound:',@dbgExcsFound,'@dbgFirstExcDate:',@dbgFirstExcDate);

                SET @ProcNextStepStartDate = @ProcNextStepEndDate; 
                SET @ProcNextStepEndDate = DateAdd(day, @StepSizedays, @ProcNextStepStartDate);
                --PRINT 'processing next Step using...'; 
                --PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd'),' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));

              END -- Next day in date Range

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< GET new excursions in date range: @dbgExcsFound:',@dbgExcsFound,' @dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< GET new excursions in date range ENDED'
--*****************************************************************************************
              PRINT ' >>> Compress lengthy excursions'
              
              --PRINT 'UPDATE ThresholdDuration, SetPoint... in the new excursions found through spPivot'
              UPDATE @ExcPoints SET ThresholdDuration = @ThresholdDuration
			  , SetPoint = @SetPoint, DeprecatedDate = @DeprecatedDate, NewRowId = RowId;

     --         DECLARE @dbgUpdateCnt int, @dbgInsertCnt int;
     --         SELECT @dbgUpdateCnt = count(*) from @ExcPoints WHERE CycleId > 0;
     --         SELECT @dbgInsertCnt = count(*) from @ExcPoints WHERE CycleId < 0;
			  --PRINT CONCAT('Compress :excursions: @dbgUpdateCnt:', @dbgUpdateCnt,' @dbgInsertCnt:', @dbgInsertCnt);


              DECLARE @CycleId int,@FirstExcDate datetime, @FirstExcValue float, @LastExcDate datetime, @LastExcValue float
			  , @RampOutDate datetime, @RampOutValue float, @HiPointsCt int, @LowPointsCt int
              , @MinValue float, @MaxValue float, @AvergValue float, @StdDevValue float;

              DECLARE @pvtExcCount int, @pvtExcIx int, @prevPvtExcId int, @adjPvtExcId int;
              SELECT @pvtExcIx = count(*) from @ExcPoints;
              WHILE @pvtExcIx > 1 BEGIN
                      --PRINT CONCAT('check if pointed excursion #',@pvtExcIx,' can be compressed')
                      DECLARE @pointedRampInDate datetime;
                      SELECT @pointedRampInDate = RampInDate FROM @ExcPoints WHERE NewRowId = @pvtExcIx;
                      IF (@pointedRampInDate IS NOT NULL) BEGIN 
                             --PRINT CONCAT('pointed excursion #',@pvtExcIx,' can NOT be compressed. Move forward')
                             GOTO SetNextExcursion;
                      END

                      --PRINT CONCAT('check if previous excursion #',@pvtExcIx - 1,' can accept compression')
                      SET @prevPvtExcId = @pvtExcIx - 1;
                      DECLARE @previousRampOutDate datetime;
                      SELECT @previousRampOutDate = RampOutDate FROM @ExcPoints WHERE NewRowId = @prevPvtExcId;
                      IF (@previousRampOutDate IS NOT NULL) BEGIN 
                             --PRINT CONCAT('previous excursion #',@prevPvtExcId,' DOESNT accept compression. Move forward')
                             GOTO SetNextExcursion;
                      END

                      --PRINT CONCAT('       compress pointed excursion #',@pvtExcIx,'. Prepare to update previous excursion');
                             SELECT @CycleId = CycleId
                             , @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
                             , @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
                             , @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
                             FROM @ExcPoints where NewRowId = @pvtExcIx;
                      --PRINT '              update previous excursion with pointed excursion'
                             UPDATE @ExcPoints
                             SET LastExcDate = @LastExcDate, LastExcValue = @LastExcValue, RampOutDate = @RampOutDate, RampOutValue = @RampOutValue
                                    , HiPointsCt = HiPointsCt + @HiPointsCt, LowPointsCt = LowPointsCt + @LowPointsCt
                                    , StepLogId = @StepLogId
                                    , MinValue = @MinValue, MaxValue = @MaxValue, AvergValue = @AvergValue, StdDevValue = @StdDevValue
                             WHERE  NewRowId = @prevPvtExcId;
                      --PRINT '          delete pointed excursion'
                             DELETE FROM @ExcPoints where NewRowId = @pvtExcIx;
                      --PRINT CONCAT('         excursion #',@pvtExcIx,' compressed')
							-- Adjust subsequent rows NewRowId
							UPDATE @ExcPoints SET NewRowId = NewRowId - 1 WHERE NewRowId > @pvtExcIx;

SetNextExcursion:
                      SET @pvtExcIx = @pvtExcIx - 1;
                      --PRINT CONCAT('previous excursion #',@pvtExcIx,' is now the POINTED excursion and is ready to be processed');
              END
              
              SELECT @dbgExcsFound = count(*) from @ExcPoints;
              SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints ORDER BY NewRowId Desc;
              --PRINT CONCAT(' <<< Compress lengthy excursions: @dbgExcsFound:',@dbgExcsFound,'  @dbgFirstExcDate: ',@dbgFirstExcDate);

              PRINT ' <<< Compress lengthy excursions ENDED'
--*****************************************************************************************
            PRINT ' >>> Compute statistics '
			DECLARE @FirstExcDate1 datetime, @FirstExcDate2 datetime, @FirstExcDate3 datetime;
			SELECT @FirstExcDate1 = FirstExcDate FROM @ExcPoints WHERE NewRowId = 1;
			SELECT @FirstExcDate2 = FirstExcDate FROM @ExcPoints WHERE NewRowId = 2;
			SELECT @FirstExcDate3 = FirstExcDate FROM @ExcPoints WHERE NewRowId = 3;


            SELECT @pvtExcCount = count(*) from @ExcPoints;
		    SET @pvtExcIx = 1
		    --PRINT CONCAT(' Compute aggregates for every one of the ',@pvtExcCount ,' Excursions in @ExcPoints')
		    WHILE @pvtExcIx <= @pvtExcCount BEGIN
			    SELECT @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue, @LastExcDate = LastExcDate
                    , @LowPointsCt = LowPointsCt, @HiPointsCt = HiPointsCt 
				    , @MinThreshold = MinThreshold, @MaxThreshold = MaxThreshold
			    FROM @ExcPoints WHERE NewRowId = @pvtExcIx
		        IF (@FirstExcDate IS NOT NULL AND @LastExcDate IS NOT NULL) BEGIN
                    PRINT CONCAT(' STATS: @TagName:',@TagName,' @FirstExcDate:', FORMAT(@FirstExcDate,'yyyy-MM-dd'),' @LastExcDate:', FORMAT(@LastExcDate,'yyyy-MM-dd'));
					DECLARE @OExcPointsCount int, @OMinValue float, @OMaxValue float, @OAvergValue float, @OStdDevValue float;
                    EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
                            , @ExcPointsCount = @OExcPointsCount OUTPUT, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
                            , @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
                    UPDATE @ExcPoints SET MinValue = @OMinValue, MaxValue = @OMaxValue
                                    , AvergValue = @OAvergValue, StdDevValue = @OStdDevValue
				    WHERE NewRowId = @pvtExcIx;
                    IF (@FirstExcValue >= @MaxThreshold) Update @ExcPoints Set HiPointsCt = @OExcPointsCount WHERE NewRowId = @pvtExcIx;
                    ELSE Update @ExcPoints Set LowPointsCt = @OExcPointsCount WHERE NewRowId = @pvtExcIx;
                    --PRINT 'aggregated values updated'
                END

			    SET @pvtExcIx = @pvtExcIx + 1;
		    END
		
            PRINT ' <<< Compute statistics ENDED'
--*****************************************************************************************
              PRINT ' >>> Merge with ExcursionPoints table'
              --SELECT @dbgUpdateCnt = count(*) from @ExcPoints WHERE CycleId > 0;
              --SELECT @dbgInsertCnt = count(*) from @ExcPoints WHERE CycleId < 0;

              --PRINT 'Determine if first Excursion from spPivot proc can be merged with ExcursionPoints table''s last excursion'
              DECLARE @fstExcRampInDate datetime;
              SELECT @fstExcRampInDate = RampInDate FROM @ExcPoints WHERE NewRowId = 1;
              IF (@fstExcRampInDate IS NULL) BEGIN
                  --PRINT ' GET Latest Excursion row from [ExcursionPoints] table and save it in @ExcPointsWIP '
                      DELETE FROM @ExcPointsWIP;
                      INSERT INTO @ExcPointsWIP (CycleId, StageDateId, TagName, TagExcNbr
            , RampInDate, RampInValue, FirstExcDate, FirstExcValue
            , LastExcDate, LastExcValue, RampOutDate, RampOutValue
            , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
            , MinValue, MaxValue, AvergValue, StdDevValue
            , ThresholdDuration, SetPoint)
            SELECT TOP 1 CycleId, StageDateId, TagName, TagExcNbr
            , RampInDate, RampInValue, FirstExcDate, FirstExcValue
            , LastExcDate, LastExcValue, RampOutDate, RampOutValue
            , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
            , MinValue, MaxValue, AvergValue, StdDevValue
            , ThresholdDuration, SetPoint
                      FROM [dbo].[ExcursionPoints] 
                WHERE StageDateId = @CurrStageDateId 
                ORDER BY TagExcNbr Desc
                     --PRINT '  IF ExcursionPoints table last entry is open for a merge ...  '
                      IF (EXISTS(SELECT * FROM @ExcPointsWIP)) BEGIN 
                             DECLARE @tblRampOutDate datetime;
                             SELECT TOP 1 @tblRampOutDate = RampOutDate from @ExcPointsWIP;
                             IF (@tblRampOutDate IS NULL) BEGIN
                                    --PRINT ' ...Update excursion in @ExcPoints using the entry from ExcursionsTable ';
                                    SELECT @CycleId = CycleId
                                    , @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
                                    , @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
                                    , @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
                                    FROM @ExcPointsWIP;
                                    UPDATE @ExcPoints SET CycleId = @CycleId,  HiPointsCt = HiPointsCt + @HiPointsCt
                                    , LowPointsCt = LowPointsCt + @LowPointsCt, LastExcDate = @LastExcDate, LastExcValue = @LastExcValue
                                    , RampOutDate = @RampOutDate, RampOutValue = @RampOutValue
                                    where NewRowId = 1;
									--IF (@FirstExcDate IS NOT NULL AND @LastExcDate IS NOT NULL) BEGIN
									--	PRINT CONCAT(' STATS: @TagName:',@TagName,' @FirstExcDate:', FORMAT(@FirstExcDate,'yyyy-MM-dd'),' @LastExcDate:', FORMAT(@LastExcDate,'yyyy-MM-dd'));
									--	EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
									--			, @ExcPointsCount = @OExcPointsCount OUTPUT, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
									--			, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
									--	UPDATE @ExcPoints SET MinValue = @OMinValue, MaxValue = @OMaxValue
									--					, AvergValue = @OAvergValue, StdDevValue = @OStdDevValue
									--	WHERE RowId = @pvtExcIx;
									--	IF (@FirstExcValue >= @MaxThreshold) Update @ExcPoints Set HiPointsCt = @OExcPointsCount WHERE RowId = @pvtExcIx;
									--	ELSE Update @ExcPoints Set LowPointsCt = @OExcPointsCount WHERE RowId = @pvtExcIx;
									--	--PRINT 'aggregated values updated'
									--END
                             END
                      END
				END

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< Merge with ExcursionPoints table: @dbgExcsFound:',@dbgExcsFound,'@dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< Merge with ExcursionPoints table ENDED'
--*****************************************************************************************
              PRINT ' >>> Persist excursions to table'

              --SELECT @dbgUpdateCnt = count(*) from @ExcPoints WHERE CycleId > 0;
              --SELECT @dbgInsertCnt = count(*) from @ExcPoints WHERE CycleId < 0;

              INSERT INTO @ExcPointsOutput
              SELECT * FROM @ExcPoints;

              UPDATE ExcursionPoints 
              SET HiPointsCt = ep.HiPointsCt, LowPointsCt = ep.LowPointsCt, LastExcDate = ep.LastExcDate, LastExcValue = ep.LastExcValue
              , RampOutDate = ep.RampOutDate, RampOutValue = ep.RampOutValue
              FROM @ExcPoints as ep
              WHERE ep.CycleId > 0 AND ExcursionPoints.CycleId = ep.CycleId

              DELETE FROM @ExcPoints WHERE CycleId > 0;

              DECLARE @HighestTagExcNbr int;
              SELECT TOP 1 @HighestTagExcNbr = TagExcNbr from [dbo].[ExcursionPoints] WHERE StageDateId = @CurrStageDateId ORDER BY TagExcNbr Desc;
              if (@HighestTagExcNbr IS NULL) SET @HighestTagExcNbr = 0;

              --PRINT 'Resquence TagExcNbr of excursions that will be inserted'
              UPDATE exp SET TagExcNbr = NewSeq
              FROM @ExcPoints as exp 
              inner join 
              (SELECT FirstExcDate,  (@HighestTagExcNbr + Row_number()OVER(ORDER BY FirstExcDate ) ) as NewSeq 
                             FROM @ExcPoints ) as rsq
              ON exp.FirstExcDate = rsq.FirstExcDate
              WHERE exp.CycleId < 0;

              --DECLARE @dbgDuplicatedTag int, @dbgDuplicatedExcNbrCount int;
              --SElECT TOP 1 @dbgDuplicatedTag = TagExcNbr, @dbgDuplicatedExcNbrCount = count(*) 
              --FROM @ExcPoints      Group by TagExcNbr Having count(*) > 1;
              --PRINT CONCAT(' @dbgDuplicatedTag:',@dbgDuplicatedTag,' @dbgDuplicatedExcNbrCount:',@dbgDuplicatedExcNbrCount);

              --PRINT 'Insert new Excursions to ExcursionPoints Table'
              Insert into ExcursionPoints ( 
                      TagId, TagName, TagExcNbr, StageDateId, StepLogId
                      , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                      , HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
                      , MinValue, MaxValue, AvergValue, StdDevValue
                      , DeprecatedDate, ThresholdDuration, SetPoint
                      )
              SELECT 
                      --TagId, TagName, IsNull(TagExcNbr,0), StageDateId, @StepLogId as StepLogId
                      TagId, TagName, IsNull(TagExcNbr,0), StageDateId, StepLogId
                      , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                      , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                      , MinValue, MaxValue, AvergValue, StdDevValue
                      , DeprecatedDate, ThresholdDuration, SetPoint
                      FROM @ExcPoints

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< Persist excursions to table: @dbgExcsFound:',@dbgExcsFound,' @dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< Persist excursions to table ENDED'
--*****************************************************************************************
              -- Insert PointsPaces' next process row if Tag was not deprecated in the next PointsPace time interval
              if (@DeprecatedDate IS NULL OR @DeprecatedDate > DateAdd(day,1,@ProcNextStepStartDate))
              INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
                      VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays, NULL );


              SET @CurrStgDtIx=@CurrStgDtIx+1;
       END; -- Next stageDate


spDriverExit:

SELECT * FROM @ExcPointsOutput;

--SELECT @dbgExcsFound = count(*) from @ExcPointsOutput;
--SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPointsOutput;
--PRINT CONCAT(' <<< spDriverExcursionsPointsForDate: @dbgExcsFound:',@dbgExcsFound,'@dbgFirstExcDate:',@dbgFirstExcDate);


PRINT '  <<< spDriverExcursionsPointsForDate ENDED'

--RETURN @pivotReturnValue;
RETURN 0;;

--UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '12341234'

END;
GO
/****** Object:  StoredProcedure [dbo].[spPivotExcursionPoints]    Script Date: 7/24/2023 1:45:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (       
         @StageDateId int, @StartDate DateTime, @EndDate DateTime
       , @LowThreashold float, @HiThreashold float, @TimeStep time(0) NULL
)
AS
BEGIN
PRINT '		>>> spPivotExcursionPoints'
DECLARE @MaximumDate datetime = CAST(GETDATE() AS DATE) ; --zero hour of today's date
IF (@EndDate > @MaximumDate) SET @EndDate = @MaximumDate;

DECLARE @TagId int, @TagName varchar(255), @returnValue int = 0, @ThresholdDuration int, @SetPoint float;
SELECT TOP 1 @TagId = TagId, @TagName = sldc.TagName, @ThresholdDuration = sldc.ThresholdDuration, @SetPoint = sldc.SetPoint
FROM StagesLimitsAndDatesCore as sldc
WHERE sldc.StageDateId = @StageDateId;
IF (@TagName IS NULL) BEGIN
       PRINT CONCAT('StageDateId not found:', @StageDateId);
       RAISERROR ('StageDateId not found',1,1);
       SET @returnValue = -1;
       GOTO ReturnResult;
END

PRINT CONCAT('		INPUT: @StageDateId:',@StageDateId, ' @StartDate:', @StartDate, ' @EndDate:', @EndDate,' @LowThreashold:',@LowThreashold, ' @HiThreashold:',@HiThreashold, ' @TimeStep:', @TimeStep);

       --Declare input cursor values
       DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 1; 
       DECLARE @IsHiExc int = -1;

       -- Currently in-process Excursion in date range for Tag (TagName)
       DECLARE @ExcPoint1 as TABLE ( ExcPriority int, CycleId int, StageDateId int, TagId int
            , TagName varchar(255), TagExcNbr int
            , RampInDate DateTime, RampInValue float, FirstExcDate DateTime, FirstExcValue float
            , LastExcDate DateTime, LastExcValue float, RampOutDate DateTime, RampOutValue float
            , HiPointsCt int, LowPointsCt int, LowThreashold float, HiThreashold float
            , MinValue float, MaxValue float, AvergValue float, StdDevValue float
            , ThresholdDuration int, SetPoint float);
       -- Finished processed (saved) Excursions in date range
       DECLARE @ExcPointsOutput as TABLE ( ExcPriority int, CycleId int, StageDateId int, TagId int
            , TagName varchar(255), TagExcNbr int
            , RampInDate DateTime, RampInValue float
            , FirstExcDate DateTime, FirstExcValue float
            , LastExcDate DateTime, LastExcValue float
            , RampOutDate DateTime, RampOutValue float
            , HiPointsCt int, LowPointsCt int  
            , LowThreashold float, HiThreashold float
            , MinValue float, MaxValue float
            , AvergValue float, StdDevValue float
            , ThresholdDuration int, SetPoint float);

       DECLARE @CycleId int,
			@RampInDate DateTime = NULL, @RampInValue float = NULL,
			@FirstExcDate DateTime = NULL, @FirstExcValue float = NULL,
			@LastExcDate DateTime = NULL, @LastExcValue float = NULL,
			@RampOutDate DateTime = NULL, @RampOutValue float = NULL,
			@HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	--Print 'Set First Excursion for tag (StageDateId, TagId and TagName) created'
	INSERT INTO @ExcPoint1
		-- Create a new Excursion 
	SELECT 1 as ExcPriority, -1 as  CycleId, @StageDateId as StageDateId, @TagId as TagId
		, @TagName as TagName, 1 as TagExcNbr
		, NULL, NULL, NULL, NULL
		, NULL, NULL, NULL, NULL
		, 0, 0, @LowThreashold, @HiThreashold
		, NULL, NULL, NULL, NULL
		, @ThresholdDuration, @SetPoint

    --PRINT '@TagExcNbr from latest Excursion number (if any)'
    DECLARE @ExcPriority int;
    SELECT  @ExcPriority = ExcPriority, @CycleId = CycleId, @TagExcNbr = TagExcNbr
    , @RampInDate = RampInDate, @RampInValue = RampInValue, @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue
    , @RampOutDate = RampOutDate, @RampOutValue = RampOutValue, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue
    , @LowPointsCt = LowPointsCt, @HiPointsCt = HiPointsCt
    FROM @ExcPoint1;
    IF (@ExcPriority = 3) BEGIN
            --Print 'In-Progress Excursion found'
            IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
            ELSE SET @IsHiExc = 0;
            PRINT Concat('IsHiExc: ', @IsHiExc);
    END
    ELSE IF (@ExcPriority = 2) BEGIN
            --Print 'Completed Excursion found'
            SET @TagExcNbr = @TagExcNbr + 1;
            UPDATE @ExcPoint1 SET TagExcNbr = @TagExcNbr;
    END

    --PRINT 'Loop datetime range'
    DECLARE @CurrStartDate datetime = @StartDate;
    WHILE @CurrStartDate < @EndDate  BEGIN
                             
		--PRINT 'Find First Excursion Point using ..'
		--PRINT CONCAT('.. @CurrStartDate', FORMAT(@CurrStartDate,'yyyy-MM-dd HH:mm:ss'));
		--PRINT CONCAT(' @EndDate', FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss'));
		--PRINT CONCAT(' @HiThreashold:',@HiThreashold,' @LowThreashold:',@LowThreashold);
		--SELECT TOP 1 @FirstExcDate = [time], @FirstExcValue = [value] FROM PI.piarchive..piinterp
		SELECT TOP 1 @FirstExcDate = [time], @FirstExcValue = [value] FROM [BB50PCSjsantos].[Interpolated]
				WHERE tag = @TagName 
				AND time >= FORMAT(@CurrStartDate,'yyyy-MM-dd HH:mm:ss') 
				AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
				AND value is not null
				AND ((@HiThreashold IS NOT NULL AND value >= @HiThreashold) OR (@LowThreashold IS NOT NULL AND value < @LowThreashold))
				--AND timestep = @TimeStep
				ORDER BY time;
		UPDATE @ExcPoint1 SET FirstExcDate = @FirstExcDate, FirstExcValue = @FirstExcValue, StageDateId = @StageDateId, TagId = @TagId;
		--PRINT Concat('First Excursion point: @@FirstExcDate:', @FirstExcDate,' @FirstExcValue:', @FirstExcValue);

        -- if no excursion point found break away
        IF (@FirstExcDate IS NULL) BREAK;

        -- determine if this is a High or Low excursion if this is NOT an in-progress excursion (@IsHiExc = -1)
        IF (@HiThreashold IS NOT NULL) BEGIN 
            IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
            ELSE SET @IsHiExc = 0;
        END
        ELSE IF (@LowThreashold IS NOT NULL) BEGIN 
            IF (@FirstExcValue < @LowThreashold) SET @IsHiExc = 0;
            ELSE SET @IsHiExc = 1;
        END
        --PRINT Concat('IsHiExc: ', @IsHiExc);

        if (@RampInDate IS NULL) BEGIN -- dont get RampIn Point for In-Progress excursion
                --PRINT 'Find RampIn point'
                --SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM PI.piarchive..piinterp
                SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                WHERE tag = @TagName
                        AND time < FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
                        AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss')
                        AND value is not null
                        AND (
                        (@IsHiExc = 1 AND @HiThreashold IS NOT NULL AND value < @HiThreashold) 
                        OR 
                        (@IsHiExc = 0 AND @LowThreashold IS NOT NULL AND value > @LowThreashold )
                    )
                        --AND timestep = @TimeStep
                ORDER BY time Desc;
                UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
                --PRINT Concat('RampIn point: RampInDate:', @RampInDate,' RampInValue:', @RampInValue);
        END

        -- find RampOut point
        IF (@RampOutDate IS NULL AND @FirstExcDate IS NOT NULL) BEGIN
                --PRINT 'Find RampOut point'
                --SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  PI.piarchive..piinterp
                SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                WHERE tag = @TagName 
                        AND time > FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                        AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised 
                        AND value is not null
                        AND (
                        (@LowThreashold IS NULL OR value >= @LowThreashold)  
                        AND 
                        (@HiThreashold IS NULL OR value < @HiThreashold)
                    )
                        --AND timestep = @TimeStep
                ORDER BY time Asc;
                UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
                --PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
        END

        -- find last excursion point
        IF (@FirstExcDate IS NOT NULL) BEGIN
            --PRINT 'Find Last Excursion point'
            --PRINT Concat(' RampOutValue:', @RampOutValue, ' @FirstExcDate:', @FirstExcDate);
            --PRINT Concat(' @EndDate:', @EndDate, ' @IsHiExc:', @IsHiExc, ' @HiThreashold:', @HiThreashold);
            --PRINT Concat(' @LowThreashold:', @LowThreashold );
                        IF (@RampOutDate IS NOT NULL) BEGIN
                                --SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM  PI.piarchive..piinterp
                                SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                                WHERE tag = @TagName 
                                    AND time >= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND time < FORMAT(@RampOutDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND value is not null
                                    AND ((@IsHiExc = 1 AND value >= @HiThreashold) OR (@IsHiExc = 0 AND value < @LowThreashold ))
                                    --AND timestep = @TimeStep
                                ORDER BY time Desc;
                        END
                        ELSE BEGIN
                                --SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM  PI.piarchive..piinterp
                                SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                                WHERE tag = @TagName 
                                    AND time >= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND value is not null
                                    AND ((@IsHiExc = 1 AND value >= @HiThreashold) OR (@IsHiExc = 0 AND value < @LowThreashold ))
                                    --AND timestep = @TimeStep
                                ORDER BY time Desc;
        END
        UPDATE @ExcPoint1 SET LastExcDate = @LastExcDate, LastExcValue = @LastExcValue;
        --PRINT Concat('Last Excursion point: @LastExcDate:', @LastExcDate, ' @LastExcValue:', @LastExcValue);
        END

        --PRINT 'Prepare for a new Excursion Cycle or terminate while loop if RampOutDate or LastExcDate is before @EndDate'
        --PRINT CONCAT('@CurrStartDate:',@CurrStartDate,' @RampOutDate:', @RampOutDate, ' @LastExcDate:', @LastExcDate, ' @EndDate:', @EndDate);
        
        IF (@RampOutDate is not null and @RampOutDate < @EndDate) SET @CurrStartDate = DateAdd(SECOND,3,@RampOutDate)
        ELSE IF (@LastExcDate is not null and @LastExcDate < @EndDate) SET @CurrStartDate = DateAdd(SECOND,3,@LastExcDate)
        ELSE SET @CurrStartDate = @EndDate; --finalize while loop
        --PRINT CONCAT('@CurrStartDate:',@CurrStartDate);

        --PRINT 'Save Current Excursion and prepare for Next'
        INSERT INTO @ExcPointsOutput Select * FROM @ExcPoint1;
        DELETE FROM @ExcPoint1;
        DECLARE @ExcSavedCount int; SELECT @ExcSavedCount = count(*) from @ExcPointsOutput;
        --PRINT CONCAT('Number of excursions saved:',@ExcSavedCount);
           
        SET @TagExcNbr = @TagExcNbr + 1;
        SET @RampInDate = NULL; SET @RampInValue = NULL; SET @FirstExcDate = NULL; SET @FirstExcValue = NULL;
        SET @LastExcDate = NULL; SET @LastExcValue = NULL; SET @RampOutDate = NULL; SET @RampOutValue = NULL;
        SET @HiPointsCt = 0; SET @LowPointsCt = 0;
        INSERT INTO @ExcPoint1 VALUES (0, @CycleId, @StageDateId, @TagId, @TagName, @TagExcNbr
            , NULL, NULL, NULL, NULL
            , NULL, NULL, NULL, NULL
            , @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold, NULL, NULL
            , NULL, NULL, NULL, NULL);
    END; --END OF WHILE LOOP

ReturnResult:
       SELECT 
         [CycleId], [StageDateId], [TagId], [TagName], [TagExcNbr]
         , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
         , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
         , [HiPointsCt], [LowPointsCt], @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
         , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
         , [ThresholdDuration], [SetPoint]
       FROM @ExcPointsOutput 
      -- WHERE (HiPointsCt > 0 OR LowPointsCt > 0);
       --WHERE (HiPointsCt > 0 OR LowPointsCt > 0) AND FirstExcDate IS NOT NULL;

          PRINT '		spPivotExcursionPoints ends <<<'
          RETURN @returnValue;

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
               Bottom = 580
               Right = 804
            End
            DisplayFlags = 280
            TopColumn = 1
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StagesLimitsAndDatesCore'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'StagesLimitsAndDatesCore'
GO
USE [master]
GO
ALTER DATABASE [ELChambers_copy] SET  READ_WRITE 
GO
