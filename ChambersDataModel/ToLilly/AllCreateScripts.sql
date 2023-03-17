/****** Object:  UserDefinedFunction [dbo].[fnCalcTimeStep]    Script Date: 3/17/2023 11:44:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  UserDefinedFunction [dbo].[fnGetBAUExcursions]    Script Date: 3/17/2023 11:44:34 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnGetInterp2]    Script Date: 3/17/2023 11:44:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  UserDefinedFunction [dbo].[fnGetOverlappingDates]    Script Date: 3/17/2023 11:44:34 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnToDuration]    Script Date: 3/17/2023 11:44:34 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fnToStructDuration]    Script Date: 3/17/2023 11:44:34 AM ******/
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
/****** Object:  Table [dbo].[Tags]    Script Date: 3/17/2023 11:44:34 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Stages]    Script Date: 3/17/2023 11:44:34 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[StagesDates]    Script Date: 3/17/2023 11:44:34 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[StagesLimitsAndDatesCore]    Script Date: 3/17/2023 11:44:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StagesLimitsAndDatesCore]
AS
SELECT t .TagId, t .TagName, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold, std.StartDate, std.EndDate, st.TimeStep, st.StageId
, st.ThresholdDuration, st.SetPoint, st.DeprecatedDate AS StageDeprecatedDate, std.DeprecatedDate AS StageDateDeprecatedDate, st.ProductionDate
, IIF((st.DeprecatedDate IS NULL AND std.DeprecatedDate IS NULL), Cast(0 as bit), Cast(1 as bit)) AS IsDeprecated
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t .TagId
GO
/****** Object:  View [dbo].[StagesLimitsAndDates]    Script Date: 3/17/2023 11:44:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT std.TagId, std.TagName, std.StageDateId, std.StageName, std.MinThreshold, std.MaxThreshold, std.StartDate, std.EndDate
, std.TimeStep, std.StageId, std.ThresholdDuration, std.SetPoint
FROM  StagesLimitsAndDatesCore as std
WHERE (std.StageDeprecatedDate IS NULL) AND (std.StageDateDeprecatedDate IS NULL)
GO
/****** Object:  Table [dbo].[ExcursionPoints]    Script Date: 3/17/2023 11:44:34 AM ******/
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
	[HiPointsCt] [int] NOT NULL,
	[LowPointsCt] [int] NOT NULL,
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[BAUExcursions]    Script Date: 3/17/2023 11:44:34 AM ******/
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
/****** Object:  Table [dbo].[PointsPaces]    Script Date: 3/17/2023 11:44:34 AM ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PointsStepsLog]    Script Date: 3/17/2023 11:44:34 AM ******/
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
	[MinThreshold] [float] NULL,
	[MaxThreshold] [float] NULL,
	[PaceId] [int] NOT NULL,
	[PaceStartDate] [datetime] NOT NULL,
	[PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ThresholdDuration] [int] NULL,
	[SetPoint] [float] NULL,
 CONSTRAINT [pkPointsStepsLogPaceLogId] PRIMARY KEY CLUSTERED 
(
	[StepLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PointsPaces] ADD  DEFAULT ((2)) FOR [StepSizeDays]
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
/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 3/17/2023 11:44:34 AM ******/
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
PRINT '>>> spDriverExcursionsPointsForDate begins'

	SET NOCOUNT ON;
	DECLARE @debugStr NVARCHAR(max)  ;
	
	-- Processing StageDates
	DECLARE @StageDateIdsTable TABLE (StageDateId int);
	IF (@StageDateIds IS NOT NULL) BEGIN
		INSERT INTO @StageDateIdsTable
		SELECT value from STRING_SPLIT(@StageDateIds, ',')
	END;

	--  Tag details
	DECLARE @StagesLimitsAndDatesCore TABLE (
		TagId int, TagName nvarchar(255), StageDateId int, StageName nvarchar(255) NULL
		, MinThreshold float, MaxThreshold float, StartDate datetime, EndDate datetime
		, TimeStep float null, StageId int, ThresholdDuration int NULL, SetPoint float NULL
		, StageDeprecatedDate datetime NULL, StageDateDeprecatedDate datetime NULL
		, ProductionDate datetime NULL, IsDeprecated int 
	)

	PRINT 'Get Tag details'
	INSERT INTO @StagesLimitsAndDatesCore
	SELECT TagId, TagName, StageDateId, StageName 
		, MinThreshold, MaxThreshold, StartDate, EndDate
		, TimeStep, StageId, ThresholdDuration, SetPoint 
		, StageDeprecatedDate, StageDateDeprecatedDate 
		, ProductionDate, IsDeprecated 
		FROM [dbo].[StagesLimitsAndDatesCore]
		WHERE (@StageDateIds IS NULL OR StageDateId in (SELECT StageDateId From @StageDateIdsTable));

	DECLARE @SavedExcPoints as TABLE ( TagId int NULL
	, TagName varchar(255), TagExcNbr int NULL
	, StepLogId int NULL
	, RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
	, LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
	, HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
	, MinValue float, MaxValue float, AvergValue float, StdDevValue float
	, ThresholdDuration int, SetPoint float);

	DECLARE @ExcPoints as TABLE ( TagId int NULL
	, TagName varchar(255), TagExcNbr int NULL
	, StepLogId int NULL
	, RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
	, LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
	, HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
	, MinValue float, MaxValue float, AvergValue float, StdDevValue float
	, ThresholdDuration int, SetPoint float);

	-- If no Tag details found abort (details are not configured).
	IF (NOT EXISTS(SELECT * FROM @StagesLimitsAndDatesCore)) BEGIN
		PRINT '+++ Tags are not configured +++';
		PRINT '<<< spDriverExcursionsPointsForDate aborted';
		SELECT * FROM @ExcPoints;
		RETURN;
	END;

	DECLARE @PointsPacesTbl TABLE (
		RowID int not null primary key identity(1,1)
		, PaceId int, StageDateId int, NextStepStartDate datetime, StepSizeDays int, NextStepEndDate datetime, ProcessedDate datetime NULL
	  );

	
	PRINT 'All PointsPaces that are awaiting to be processed (ProcessedDate is null) '
	INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
	SELECT PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate 
	FROM [dbo].[PointsPaces]
	WHERE (@StageDateIds IS NULL OR StageDateId in (SELECT StageDateId From @StageDateIdsTable))
	AND ProcessedDate IS NULL;
	SELECT @debugStr = COALESCE(@debugStr + '''|''', '|''') + Cast(PaceId as varchar(10)) + '-' + Format(NextStepStartDate, 'yy/MM/dd') 
		FROM @PointsPacesTbl;
	PRINT CONCAT('ROWS CNT:',@@ROWCOUNT,  @debugStr);
	
	PRINT 'Insert PointsPaces that have never been processed before'
	IF (@StageDateIds IS NULL) BEGIN
		INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
		SELECT -1 as PaceId, StageDateId, @FromDate as NextStepStartDate, 2 as StepSizeDays
			, DateAdd(day,2,@FromDate) as NextStepEndDate, NULL as ProcessedDate 
		FROM (SELECT StageDateID from [dbo].[StagesLimitsAndDatesCore] WHERE StageDateId Not IN (SELECT StageDateId FROM @PointsPacesTbl)) as ppsTbl
	END
	ELSE BEGIN
		INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
		SELECT -1 as PaceId, StageDateId, @FromDate as NextStepStartDate, 2 as StepSizeDays
			, DateAdd(day,2,@FromDate) as NextStepEndDate, NULL as ProcessedDate 
		FROM (SELECT StageDateID from @StageDateIdsTable WHERE StageDateId Not IN (SELECT StageDateId FROM @PointsPacesTbl)) as ppsTbl
	END
		SELECT @debugStr = COALESCE(@debugStr + '''|''', '|''') + Cast(StageDateId as varchar(10)) + '-' + Format(NextStepStartDate, 'yy/MM/dd') 
		FROM @PointsPacesTbl WHERE PaceId < 0 ;
	PRINT CONCAT('ROWS CNT:',@@ROWCOUNT,  @debugStr)

	DECLARE @stTagId int, @stTagName varchar(255), @stStepLogId int
		, @stMinThreshold float, @stMaxThreshold float, @stStartDate as datetime, @stEndDate as datetime
		, @stThresholdDuration int, @stSetPoint float;

	DECLARE @PacesCount int, @CurrPaceRow int = 0;
	DECLARE @PaceId int, @CurrStageDateId int, @StepStartDate datetime, @StepEndDate datetime, @StepSizedays int;
	SELECT @PacesCount = count(*) from @PointsPacesTbl;
	WHILE @CurrPaceRow < @PacesCount BEGIN
		SET @CurrPaceRow=@CurrPaceRow+1;
		SELECT @PaceId = PaceId, @CurrStageDateId = StageDateId,  @StepStartDate = NextStepStartDate 
			, @StepEndDate = NextStepEndDate, @StepSizedays = StepSizeDays
		FROM @PointsPacesTbl
		WHERE RowID = @CurrPaceRow;
		PRINT 'PROCESS Tag through the date date range'
		WHILE @StepEndDate < @ToDate BEGIN

			BEGIN TRAN;

			PRINT Concat('@StageDateId:', @CurrStageDateId, ' @StepStartDate:', @StepStartDate,' @StepEndDate:', @StepEndDate);

			SELECT @stTagId = TagId, @stTagName = TagName, @stMinThreshold = MinThreshold, @stMaxThreshold = MaxThreshold
				, @stThresholdDuration = ThresholdDuration , @stSetPoint = SetPoint
			FROM @StagesLimitsAndDatesCore
			WHERE StageDateId = @CurrStageDateId

			PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @stTagName, ''', '''
				, FORMAT(@StepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@StepEndDate, 'yyyy-MM-dd'), ''', '
				, CONVERT(varchar(255), @stMinThreshold), ', ', CONVERT(varchar(255), @stMaxThreshold), ', '
				, Convert(varchar(16), @stTagId), ', ', Convert(varchar(16), @stStepLogId), ', '
				, Convert(varchar(16), @stThresholdDuration), ', ', Convert(varchar(16), @stSetPoint)
				);

			INSERT INTO @ExcPoints (
				[TagName], [TagExcNbr]
			  , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
			  , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
			  , [HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
			  , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
			  , [ThresholdDuration], [SetPoint]
			)
			EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @StepStartDate, @StepEndDate, @stMinThreshold, @stMaxThreshold
				, @stThresholdDuration, @stSetPoint;
			SELECT @debugStr = COALESCE(@debugStr + '''|''', '|''') + Cast(TagExcNbr as varchar(10)) + '-' + Format(FirstExcDate, 'yy/MM/dd') + '-' + Format(LastExcDate, 'yy/MM/dd') 
				FROM @ExcPoints;
			PRINT CONCAT('spPivot ROWS CNT:',@@ROWCOUNT,  @debugStr);

			Insert into ExcursionPoints ( 
			TagName, TagExcNbr
			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
			, MinValue, MaxValue, AvergValue, StdDevValue
			, ThresholdDuration, SetPoint
			)
			SELECT TagName, TagExcNbr
			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
			, MinValue, MaxValue, AvergValue, StdDevValue
			, ThresholdDuration, SetPoint
			FROM @ExcPoints;

			Insert into @SavedExcPoints ( 
			TagName, TagExcNbr
			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
			, MinValue, MaxValue, AvergValue, StdDevValue
			, ThresholdDuration, SetPoint
			)
			SELECT TagName, TagExcNbr
			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
			, MinValue, MaxValue, AvergValue, StdDevValue
			, ThresholdDuration, SetPoint
			FROM @ExcPoints;

			Delete from @ExcPoints;

			IF (@PaceId <= 0) BEGIN
				INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
					 VALUES (@CurrStageDateId, @StepStartDate, @StepSizedays, GetDate() ); 
			END
			ELSE BEGIN
				UPDATE [dbo].[PointsPaces] SET ProcessedDate = GetDate()
				WHERE PaceId = @PaceId;
			END

			-- prepare for next Point's step run
			SET @StepStartDate = @StepEndDate; 
			SET @StepEndDate = DateAdd(day, @StepSizedays, @StepEndDate) ;
			SET @PaceId = -1;

			if (@StepEndDate >= @ToDate) BEGIN
				-- Last PointsPace row of the date range
				INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
				VALUES (@CurrStageDateId, @StepStartDate, @StepSizedays, NULL ); 

				SELECT @debugStr = COALESCE(@debugStr + '''|''', '|''') + Cast(TagExcNbr as varchar(10)) + '-' + Format(FirstExcDate, 'yy/MM/dd') + '-' + Format(LastExcDate, 'yy/MM/dd') 
						FROM @SavedExcPoints;
				PRINT CONCAT('SavedExcPoints ROWS CNT:',@@ROWCOUNT,  @debugStr);
			END

			COMMIT TRAN;

		END

		SELECT * FROM @SavedExcPoints;


	END


	--UNIT TESTS
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', 12341234


	--	-- find all (or selected by StageDateId) StagesLimitsAndDates (STADs) left join with PointsPaces
	--	-- default PointsPaces will be assigned to STADs that don't have one.
	--	IF (@StageDateId IS NULL AND @TagName IS NULL) 
	--		INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
	--		SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
	--		FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
	--		WHERE PPs.PaceId IS NULL;
	--	ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
	--		INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])			
	--		SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
	--		FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
	--		WHERE PPs.PaceId IS NULL AND sld.StageDateId = @StageDateId;
	--	ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
	--		INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
	--		SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays 
	--		FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
	--		WHERE PPs.PaceId IS NULL AND sld.TagName = @TagName;
	--	ELSE
	--		INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
	--		SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
	--		from [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
	--		WHERE PPs.PaceId IS NULL AND sld.TagName = @TagName AND sld.StageDateId = @StageDateId;

	
	----spCreateSteps
	---- iterate all PointsPaces or just the ones associated with input StageDateId.
	---- Iterate ends when PointsPaces' end date exceeds ForDate
	---- each iteration creates associated PointsStepsLog
	---- insert into [dbo].[PointsStepsLog]

	--DECLARE  @PointsStepsLog TABLE ( [StepLogId] [int] NULL,
	--[StageDateId] [int] NOT NULL, [StageName] [nvarchar](255) NOT NULL, [TagId] [int] NOT NULL, [TagName] [varchar](255) NOT NULL,
	--[StageStartDate] [datetime] NOT NULL, [StageEndDate] [datetime] NULL, [MinThreshold] [float] NOT NULL, [MaxThreshold] [float] NOT NULL,
	--[PaceId] [int] NOT NULL, [PaceStartDate] [datetime] NOT NULL, [PaceEndDate] [datetime] NOT NULL,
	--[StartDate] [datetime] NULL, [EndDate] [datetime] NULL, [ThresholdDuration] int NULL, SetPoint float NULL
	--);



	--IF (@StageDateId IS NULL AND @TagName IS NULL) 
	--	INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
	--	, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
	--	SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
	--	WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	--ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
	--	INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
	--	, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
	--	SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
	--	WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	--	AND nxt.StageDateId = @StageDateId
	--ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
	--	INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
	--	, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
	--	SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
	--	WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	--	AND nxt.TagName = @TagName
	--ELSE
	--	INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
	--	, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
	--	SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
	--	WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	--	AND nxt.StageDateId = @StageDateId AND nxt.TagName = @TagName



	--INSERT INTO [dbo].[PointsStepsLog] ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
	--	, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
	--SELECT [StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
	--	, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint] 
	--FROM @PointsStepsLog;

	----spProcessSteps
	---- each iteration populates excursionPoints
	---- iterations should be under the context of a transaction.
	--DECLARE @ExcPoints as TABLE ( TagId int NULL
	--	, TagName varchar(255), TagExcNbr int NULL
	--	, StepLogId int NULL
	--	, RampInDate DateTime NULL, RampInValue float NULl
	--	, FirstExcDate DateTime NULL, FirstExcValue float NULL
	--	, LastExcDate DateTime NULL, LastExcValue float NULL
	--	, RampOutDate DateTime NULL, RampOutValue float NULL
	--	, HiPointsCt int NULL, LowPointsCt int NULL
	--	, MinThreshold float NULL, MaxThreshold float NULL
	--	, MinValue float, MaxValue float
	--	, AvergValue float, StdDevValue float
	--	, ThresholdDuration int, SetPoint float);
	--DECLARE @stTagId int, @stTagName varchar(255), @stStepLogId int
	--, @stMinThreshold float, @stMaxThreshold float, @stStartDate as datetime, @stEndDate as datetime
	--, @stThresholdDuration int, @stSetPoint float;
	--DECLARE stepsCsr CURSOR 
	--FOR SELECT psl.TagId, psl.TagName, psl.StepLogId, psl.MinThreshold, psl.MaxThreshold, psl.StartDate, psl.EndDate, psl.ThresholdDuration, psl.SetPoint 
	--	FROM PointsStepsLog as psl
	--	WHERE psl.PaceId in (SELECT vpsl.PaceId From @PointsStepsLog as vpsl);
	--OPEN stepsCsr;
	--FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinThreshold, @stMaxThreshold
	--, @stStartDate, @stEndDate, @stThresholdDuration, @stSetPoint;
	--WHILE @@FETCH_STATUS = 0 BEGIN
	--	--PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ' + Convert(varchar(16), @stTagId) + Convert(varchar(16), @stStepLogId) +  '''',@stTagName, ''', '''
	--	--, FORMAT(@stStartDate, 'yyyy-MM-dd'), ''', ''', CONVERT(varchar(255), @stEndDate, 126), ''', '
	--	--, CONVERT(varchar(255), @stMinThreshold), ', ', CONVERT(varchar(255), @stMaxThreshold)
	--	--);
	--	INSERT INTO @ExcPoints
	--	EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @stStartDate, @stEndDate, @stMinThreshold, @stMaxThreshold
	--	, @stTagId, @stStepLogId, @stThresholdDuration, @stSetPoint;

	--	FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinThreshold, @stMaxThreshold
	--	, @stStartDate, @stEndDate, @stThresholdDuration, @stSetPoint;
	--END;
	--CLOSE stepsCsr;
	--DEALLOCATE stepsCsr;

	--IF EXISTS (SELECT PaceId FROM @PointsStepsLog) BEGIN
	--	-- Create a new PointsPaces row for next iteration
	--	INSERT INTO PointsPaces (StageDateId, NextStepStartDate, StepSizeDays)
	--	SELECT pps.StageDateId, pps.NextStepEndDate as NextStepStartDate, pps.StepSizeDays 
	--	FROM PointsPaces as pps
	--	WHERE pps.ProcessedDate IS NULL;
	--	-- Update PointsPaces's row that was processed
	--	UPDATE dbo.PointsPaces 
	--	SET  ProcessedDate = GetDate()
	--	WHERE PaceId IN (SELECT PaceId FROM @PointsStepsLog) AND ProcessedDate IS NULL;

	--END

	--Insert into ExcursionPoints ( 
	--	TagName, TagExcNbr
	--	, RampInDate, RampInValue, FirstExcDate, FirstExcValue
	--	, LastExcDate, LastExcValue, RampOutDate, RampOutValue
	--	, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
	--	, MinValue, MaxValue, AvergValue, StdDevValue
	--	, ThresholdDuration, SetPoint
	--	)
	--SELECT TagName, TagExcNbr
	--	, RampInDate, RampInValue, FirstExcDate, FirstExcValue
	--	, LastExcDate, LastExcValue, RampOutDate, RampOutValue
	--	, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
	--	, MinValue, MaxValue, AvergValue, StdDevValue
	--	, ThresholdDuration, SetPoint
	--FROM @ExcPoints;

	--SELECT * FROM @ExcPoints;

	--COMMIT TRAN;

-- UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-01';
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2222-11-01';
--SELECT * FROM [dbo].[PointsStepsLog];
--DELETE FROM [dbo].[PointsStepsLog];
PRINT 'spDriverExcursionsPointsForDate ends <<<'

END;
GO
/****** Object:  StoredProcedure [dbo].[spGetInterop2]    Script Date: 3/17/2023 11:44:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spGetInterop2] 
	-- Add the parameters for the stored procedure here
	@Tag nvarchar(4000)
	, @StartTime datetime2
	, @EndTime datetime2
	, @TimeStep time = '00:00:05'
AS
BEGIN

	SET NOCOUNT ON;

	--Set @Tag = NULLIF(LTRIM(RTRIM(@Tag)), ''); -- NULL if has blanks or emptry string
	--Set @StartTime = NULLIF(@StartTime, ''); -- NULL if has blanks or emptry string
	--Set @EndTime = NULLIF(@EndTime, ''); -- NULL if has blanks or emptry string
	Set @TimeStep = NULLIF(LTRIM(RTRIM(@TimeStep)), ''); -- NULL if has blanks or emptry string
	
	DECLARE @Sql nvarchar(max) = '';

	--SET @Sql = ' tag = ''''' + @Tag + '''''';
	IF @Tag is NOT NULL AND len(@Tag)>0
		SET @Sql = ' tag in ('+ [dbo].[fn_SplitJoin](@Tag,',','''''','''''',',') + ')'

	PRINT(@Sql);


	SET @Sql = @Sql + ' AND time BETWEEN ''''' + Convert(varchar(20), @StartTime, 20) + ''''' AND ''''' + Convert(varchar(20), @EndTime, 20) + '''''';

	IF (@TimeStep Is Not NULL)		
	SET @Sql = @Sql + ' AND TimeStep=''''' + Convert(varchar(20), @TimeStep, 8) + '''''';

	SET @Sql = '''SELECT * FROM piarchive..piinterp2 WHERE ' + @Sql + '';

	--SELECT @Sql;
	--PRINT(@Sql);
	
	DECLARE @OuterQuery nvarchar(max) = 
	'SELECT * FROM OPENQUERY(PI, ' + @Sql + ' '' )';

	--DECLARE @OuterQuery nvarchar(max) = 
	--'SELECT * FROM OPENQUERY(PI, ''SELECT * FROM piarchive..piinterp2 WHERE ' + @Sql + ''' )';

	--PRINT(@OuterQuery);
	--DECLARE @Tbl Table ([tag] nvarchar(4000) NOT  NULL, [Time] datetime2(7) NOT  NULL,
	--[Value] nvarchar(4000)  NULL, [Status] int NOT  NULL, [TimeStep] time(0)  NULL);
	--Insert @Tbl exec(@OuterQuery);
	--SELECT * FROM @Tbl;

	PRINT(@OuterQuery);
	EXEC SP_ExecuteSql @OuterQuery;
END
GO
/****** Object:  StoredProcedure [dbo].[spGetStats]    Script Date: 3/17/2023 11:44:34 AM ******/
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
			FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate,'00:10:00');

		--SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].Interpolated as Stat
		--	WHERE Stat.tag = @TagName  and Stat.time >= @FirstExcDate And Stat.Time <= @LastExcDate;

--PRINT 'spGetStats ends <<<'
--DECLARE @OMinValue    float;
--DECLARE @OMaxValue    float;
--DECLARE @OAvergValue  float;
--DECLARE @OStdDevValue float;
------insert into[dbo].[ExcursionStats]
--EXECUTE dbo.spGetStats chamber_report_tag_1, '2022-11-01 12:03:00.00', '2022-11-01 13:57:00.000'
--	, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
--PRINT CONCAT(@OMinValue,' ', @OMaxValue,' ', @OAvergValue,' ', @OStdDevValue);

		--DECLARE @TimeStep time(0);
		--SELECT @TimeStep = [dbo].fnCalcTimeStep(@FirstExcDate, @LastExcDate, 60);
		--SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate, @TimeStep);
END
GO
/****** Object:  StoredProcedure [dbo].[spPivotExcursionPoints]    Script Date: 3/17/2023 11:44:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (	
	  @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
	, @LowThreashold float, @HiThreashold float 
	, @ThresholdDuration int = null, @SetPoint float = null
)
AS
BEGIN
PRINT '>>> spPivotExcursionPoints begins'
PRINT CONCAT('INPUT: @TagName:',@TagName, ' @StartDate:', @StartDate, ' @EndDate:', @EndDate
		, ' @ThresholdDuration:', @ThresholdDuration, ' @SetPoint:', @SetPoint);

	--Declare input cursor values
	DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 1; 
	DECLARE @IsHiExc int = -1;

	-- Currently in-process Excursion in date range for Tag (TagName)
	DECLARE @ExcPoint1 as TABLE ( ExcPriority int, 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int
			, LowThreashold float, HiThreashold float
			, MinValue float, MaxValue float
			, AvergValue float, StdDevValue float
			, ThresholdDuration int, SetPoint float);
	-- Finished processed (saved) Excursions in date range
	DECLARE @ExcPoints as TABLE ( ExcPriority int,
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  
			, LowThreashold float, HiThreashold float
			, MinValue float, MaxValue float
			, AvergValue float, StdDevValue float
			, ThresholdDuration int, SetPoint float);
	DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
	DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
	DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
	DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
	DECLARE @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	PRINT 'GET LAST Excursion or Empty (start up) Excursion row'
	INSERT INTO @ExcPoint1 (ExcPriority, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
		, HiPointsCt, LowPointsCt, LowThreashold, HiThreashold
		, MinValue, MaxValue, AvergValue, StdDevValue
		, ThresholdDuration, SetPoint)
		SELECT TOP 1 ExcPriority, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
		, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
		, MinValue, MaxValue, AvergValue, StdDevValue
		, ThresholdDuration, SetPoint
		FROM (
			-- get last incomplete Excursion (RampIn only) if one exists
			SELECT TOP 1 3 as ExcPriority, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
			, NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
			, 120 as ThresholdDuration, 150 as SetPoint FROM [dbo].[ExcursionPoints] 
			WHERE TagName = @TagName AND RampOutDate is NULL
			ORDER BY TagName, TagExcNbr Desc
			UNION ALL
			-- get completed Excursion (RampIn and RampOut populated) if one exists
			SELECT TOP 1 2 as ExcPriority, TagName, TagExcNbr, NULL as RampInDate, NULL as RampInValue, NULL as FirstExcDate, NULL as FirstExcValue
			, 0 as HiPointsCt, 0 as LowPointsCt, 100 as MinThreshold, 200 as MaxThreshold
			, NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
			, 120 as ThresholdDuration, 150 as SetPoint FROM [dbo].[ExcursionPoints] 
			WHERE TagName = @TagName AND RampInDate is NOT NULL AND RampOutDate is NOT NULL
			ORDER BY TagName, TagExcNbr Desc
			UNION ALL
			SELECT 1 as ExcPriority, @TagName as TagName, 1 as TagExcNbr, NULL, NULL, NULL, NULL
			, 0, 0, 100, 200
			, NULL, NULL, NULL, NULL
			, 120, 150
			) as allExc
		ORDER BY ExcPriority DESC;

	PRINT '@TagExcNbr to latest (or empty) Excursion number'
	DECLARE @ExcPriority int;
	SELECT  @ExcPriority = ExcPriority, @TagExcNbr = TagExcNbr
	, @RampInDate = RampInDate, @RampInValue = RampInValue, @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue
	, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue
	, @LowPointsCt = LowPointsCt, @HiPointsCt = HiPointsCt
	FROM @ExcPoint1;
	IF (@ExcPriority = 3) BEGIN
		IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
		ELSE SET @IsHiExc = 0;
		PRINT Concat('IsHiExc: ', @IsHiExc);
	END
	IF (@ExcPriority = 2) BEGIN
		SET @TagExcNbr = @TagExcNbr + 1;
		UPDATE @ExcPoint1 SET TagExcNbr = @TagExcNbr;
	END



	--FOR SELECT [tag], [time], [value] from  PI.piarchive..picomp
	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName 
		AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

	OPEN CPoint;
	FETCH NEXT FROM CPoint INTO @tag, @time, @value;
	PRINT Concat('First Excursion point: @time:', @time,' @Value:', @value);

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
			PRINT 'Find RampIn point'
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time <= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Desc;
			IF (@RampInDate IS NOT NULL) BEGIN
				UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
				PRINT Concat('RampIn point: RampInDate:', @RampInDate,' RampInValue:', @RampInValue);
			END
		END
		
		IF (@RampOutDate IS NULL) BEGIN
			PRINT 'Find RampOut point'
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName 
				AND time >= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
				AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Asc;
			IF (@RampOutDate IS NOT NULL) BEGIN 
				UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
				PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
			END
		END

		--PRINT 'Get RampOut point'
		--IF (@RampOutDate IS NULL AND @LastExcDate IS NOT NULL ) BEGIN
		--	SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
		--	WHERE tag = @TagName AND time >= FORMAT(@LastExcDate,'yyyy-MM-dd HH:mm:ss') 
		--		AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
		--	ORDER BY time Asc;
		--	IF (@RampOutDate IS NOT NULL) BEGIN 
		--		UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
		--	END
		--END

		PRINT 'keep updating Last Excursion point (until the end) if RampOut is found and is within date range'
		IF (@RampOutDate IS NOT NULL AND @RampOutDate < @EndDate) BEGIN
			UPDATE @ExcPoint1 SET LastExcDate = @time, LastExcValue = @value;
			SELECT TOP 1 @LastExcDate = LastExcDate, @LastExcValue = LastExcValue FROM @ExcPoint1;
			PRINT CONCAT('Last Excursion Point: @LastExcDate:', @LastExcDate,' @LastExcValue:', @LastExcValue);
		END


		FETCH NEXT FROM CPoint INTO @tag, @time, @value; 
		PRINT Concat('Next Excursion point: @time:',@time ,' @Value:', @Value);

		PRINT 'Set up a new Excursion Cycle if ..'
		PRINT '.. Next Excursion date is after RampOut date or ..'
		PRINT '.. Excursion type changed from Hi to Low or vice-versa'
		IF (@@FETCH_STATUS = 0 ) BEGIN
			IF (@time >= @RampOutDate OR (@IsHiExc = 1 AND @value < @HiThreashold) OR (@IsHiExc = 0 AND @value >= @LowThreashold) ) BEGIN
				PRINT 'Finalize Current Excursion to process up coming newer Excursion'
				PRINT 'Update aggregated values (Min, Max, Averg, StdDev) if full Excursion found'
				IF (@RampInDate IS NOT NULL AND @RampOutDate IS NOT NULL) BEGIN
					PRINT 'Update aggregated values'
					DECLARE @OMinValue float, @OMaxValue float, @OAvergValue float, @OStdDevValue float;
					EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
						, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
						, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
					UPDATE @ExcPoint1 SET MinValue = @OMinValue, MaxValue = @OMaxValue
							, AvergValue = @OAvergValue, StdDevValue = @OStdDevValue;
				END

				PRINT 'Save Current Excursion and prepare for Next'
				INSERT INTO @ExcPoints Select * FROM @ExcPoint1;
				DELETE FROM @ExcPoint1;
				SET @TagExcNbr = @TagExcNbr + 1;
				SET @RampInDate = NULL; SET @RampInValue = NULL; SET @FirstExcDate = NULL; SET @FirstExcValue = NULL;
				SET @LastExcDate = NULL; SET @LastExcValue = NULL; SET @RampOutDate = NULL; SET @RampOutValue = NULL;
				SET @HiPointsCt = 0; SET @LowPointsCt = 0;
				INSERT INTO @ExcPoint1 VALUES (0, @TagName, @TagExcNbr
					, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
					, @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold, NULL, NULL
					, NULL, NULL, @ThresholdDuration, @SetPoint);
			END
		END
	END;

	CLOSE CPoint;
	DEALLOCATE CPoint;
	
	PRINT 'finalize LAST Excursion in date range (end of cursor)'
		IF (@RampInDate IS NOT NULL AND @RampOutDate IS NOT NULL) BEGIN
		PRINT 'Update aggregated values'
		EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
			, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
			, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
		UPDATE @ExcPoint1 SET MinValue = @OMinValue, MaxValue = @OMaxValue
				, AvergValue = @OAvergValue, StdDevValue = @OStdDevValue;
	END
	PRINT 'Save LAST Excursion in date range (end of cursor)'
	INSERT INTO @ExcPoints Select * FROM @ExcPoint1;

	SELECT 
	  [TagName], [TagExcNbr]
	  , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
	  , [HiPointsCt], [LowPointsCt], @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
	  , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
	  , [ThresholdDuration], [SetPoint]
	FROM @ExcPoints 
	WHERE (HiPointsCt > 0 OR LowPointsCt > 0) AND RampInDate IS NOT NULL;

-- UNIT TESTS
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
--		, @LowThreashold = 100, @HiThreashold = 200;
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-05'
--		, @LowThreashold = 100, @HiThreashold = 200;
PRINT 'spPivotExcursionPoints ends <<<'

END
GO
