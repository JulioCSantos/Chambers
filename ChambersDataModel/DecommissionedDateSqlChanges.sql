Use ELChambers_Copy;
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Alter Table Tags
Add [DecommissionedDate] datetime
Alter Table [dbo].[PointsStepsLog]
Add [DecommissionedDate] datetime
Alter Table [dbo].[ExcursionPoints]
Add [DecommissionedDate] datetime
GO
USE [ELChambers_copy]
GO
DROP INDEX [ixExcursionPointsStageDateId] 
ON [dbo].[ExcursionPoints]
GO
Alter Table [dbo].[ExcursionPoints]
alter column StageDateId int not null;
USE [ELChambers_copy]
GO
CREATE NONCLUSTERED INDEX [ixExcursionPointsStageDateId] ON [dbo].[ExcursionPoints] ( [StageDateId] ASC )
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

USE [ELChambers_copy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[StagesLimitsAndDatesCore]
AS
SELECT t.TagId, t.TagName, t.DecommissionedDate, std.StageDateId, st.StageName, st.MinThreshold, st.MaxThreshold, std.StartDate, std.EndDate, st.TimeStep, st.StageId
, st.ThresholdDuration, st.SetPoint, st.DeprecatedDate AS StageDeprecatedDate, std.DeprecatedDate AS StageDateDeprecatedDate, st.ProductionDate
, COALESCE(st.DeprecatedDate, std.DeprecatedDate) as DeprecatedDate
, IIF((st.DeprecatedDate IS NULL AND std.DeprecatedDate IS NULL), Cast(0 as bit), Cast(1 as bit)) AS IsDeprecated
FROM  dbo.Stages AS st INNER JOIN
         dbo.StagesDates AS std ON st.StageId = std.StageId INNER JOIN
         dbo.Tags AS t ON st.TagId = t .TagId
WHERE (MinThreshold IS NOT NULL or MaxThreshold IS NOT NULL)
GO

USE [ELChambers_copy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[StagesLimitsAndDates]
AS
SELECT std.TagId, std.TagName, std.StageDateId, std.StageName, std.MinThreshold, std.MaxThreshold, std.StartDate, std.EndDate
, std.TimeStep, std.StageId, std.ThresholdDuration, std.SetPoint
FROM  StagesLimitsAndDatesCore as std
WHERE (std.DeprecatedDate is null and std.DecommissionedDate is null)
GO

USE [ELChambers_copy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO 
CREATE VIEW [dbo].[StagesLimitsAndDatesChanged] AS
with SLD as (
Select * from [dbo].[StagesLimitsAndDatesCore] as s1 Where s1.DeprecatedDate is not null or s1.DecommissionedDate is not null
)
, SLD1 as (SELECT * From StagesLimitsAndDatesCore as s2 
where ( s2.TagId in (Select TagId From SLD))
)
SELECT * FROM SLD1
UNION
Select * from SLD
GO


USE [ELChambers_copy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spPropagateDeprecatedDecomissioned] (       
         @dStageDateId int
)
AS
BEGIN
PRINT '>>> spPropagateDeprecatedDecomissioned'

-- Get tag and dates (Deprecated and Decommissioned) for @stageDateId
DECLARE @tagId int, @deprecatedDate dateTime, @decommissionedDate DateTime
select @tagId = TagId, @deprecatedDate = DeprecatedDate, @decommissionedDate = DecommissionedDate 
from [dbo].[StagesLimitsAndDatesCore] where StageDateId = @dStageDateId;
       -- If no Tag details found abort (details are not configured).
       IF (@deprecatedDate is null and @decommissionedDate is null) BEGIN
              PRINT 'a StageDateId that points to a Deprecated or Decommissioned tag must be selected';
              RETURN -1;
       END;

-- Get all StageDates' rows after Deprecated/Decommissioned for tag
DECLARE  @stageDateId int, @startDate datetime
DECLARE @stagesDatesTbl as Table (StageDateId int, startDate datetime, RowNbr int, DeprecatedDate datetime, DecommissionedDate datetime)
INSERT INTO @stagesDatesTbl
SELECT StageDateId, StartDate, ROW_NUMBER() OVER(ORDER BY StageId ASC) AS RowNbr, DeprecatedDate,  DecommissionedDate
from [dbo].[StagesLimitsAndDatesCore]
where TagId = @tagId and StageDateId > @dStageDateId
order by StageId asc

DECLARE @StgDtCount int, @CurrStgDtIx int = 1;
SELECT @StgDtCount = COUNT(*) from @stagesDatesTbl
WHILE @CurrStgDtIx <= @StgDtCount BEGIN
	select @stageDateId = StageDateId, @startDate = StartDate
	from @stagesDatesTbl where RowNbr = @CurrStgDtIx;

	Declare @earliestDeprecatedDate datetime, @earlistDecommissionedDate datetime
	if (@startDate < @decommissionedDate) Begin
		update dbo.ExcursionPoints Set DecommissionedDate = @decommissionedDate
		where TagId = @tagId and (FirstExcDate > @decommissionedDate or LastExcDate > @decommissionedDate)
		IF (@earlistDecommissionedDate is null or @decommissionedDate < @earlistDecommissionedDate)
			SET @earlistDecommissionedDate = @decommissionedDate;
	end
	else if (@startDate < @deprecatedDate) Begin
		update dbo.ExcursionPoints Set DeprecatedDate = @deprecatedDate
		where TagId = @tagId and (FirstExcDate > @deprecatedDate or LastExcDate > @deprecatedDate)
		IF (@earliestDeprecatedDate is null or @deprecatedDate < @earliestDeprecatedDate)
			SET @earliestDeprecatedDate = @deprecatedDate;
	end

	-- get next Deprecated/Decommission date if any
	select @deprecatedDate = DeprecatedDate, @decommissionedDate = DecommissionedDate
	from @stagesDatesTbl where RowNbr = @CurrStgDtIx;

	SET @CurrStgDtIx = @CurrStgDtIx + 1;
END


	Select * from dbo.ExcursionPoints where TagId = @tagId and (FirstExcDate > @earliestDeprecatedDate or LastExcDate > @earliestDeprecatedDate)
	UNION ALL
	Select * from dbo.ExcursionPoints where TagId = @tagId and (FirstExcDate > @earlistDecommissionedDate or LastExcDate > @earlistDecommissionedDate)

--else select * from ExcursionPoints where 1 != 1
PRINT 'spPropagateDeprecatedDecomissioned <<<'

END
GO

USE [ELChambers_copy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spPivotExcursionPoints] (       
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
       DECLARE @ExcPointsOutput as TABLE ( ExcPriority int, CycleId int, StageDateId int Not Null, TagId int
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

USE [ELChambers_copy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
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
              , TagId int, TagName nvarchar(255), DecommissionedDate datetime, StageDateId int, StageName nvarchar(255) NULL
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
       SELECT TagId, TagName, DecommissionedDate, sldc.StageDateId, StageName 
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
       , DeprecatedDate datetime, DecommissionedDate datetime, ThresholdDuration int, SetPoint float);

       DECLARE @ExcPointsWIP as TABLE ( RowID int NULL
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
 , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, DecommissionedDate datetime, ThresholdDuration int, SetPoint float);

       DECLARE @ExcPointsOutput as TABLE ( RowID int NULL, NewRowId int
       , CycleId int, TagId int NULL
       , TagName varchar(255), TagExcNbr int NULL
       , StepLogId int NULL, StageDateId int NULL
       , RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
       , LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
       , HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
       , MinValue float, MaxValue float, AvergValue float, StdDevValue float
       , DeprecatedDate datetime, DecommissionedDate datetime, ThresholdDuration int, SetPoint float);

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
              , @ProductionDate datetime, @DeprecatedDate datetime, @DecommissionedDate datetime
              , @StageStartDate datetime, @StageEndDate datetime
              , @CurrStepStartDate datetime, @CurrStepEndDate datetime, @StepSizedays int
              , @MinThreshold float, @MaxThreshold float, @ThresholdDuration float, @SetPoint float
              , @PaceId int, @IsDeprecated bit;
              SELECT @CurrStageDateId = StageDateId, @StageId = StageId, @TagId = TagId, @TagName = TagName
              , @ProductionDate = ProductionDate, @DeprecatedDate = DeprecatedDate, @DecommissionedDate = DecommissionedDate
              , @StageStartDate = StartDate, @StageEndDate = EndDate
              , @CurrStepStartDate = NextStepStartDate, @CurrStepEndDate = NextStepEndDate, @StepSizedays = StepSizedays
              , @MinThreshold = MinThreshold, @MaxThreshold = MaxThreshold
              , @ThresholdDuration = ThresholdDuration, @SetPoint = SetPoint
              , @PaceId = PaceId, @IsDeprecated = IsDeprecated
              FROM @StagesLimitsAndDatesCore WHERE RowID = @CurrStgDtIx;
              --PRINT CONCAT('@StagesLimitsAndDatesCore @ProductionDate:', Format(@ProductionDate,'yyyy-MM-dd'),' @DeprecatedDate:', FORMAT(@DeprecatedDate, 'yyyy-MM-dd'));


              if (@CurrStepStartDate < @ProductionDate) BEGIN
                      SET @CurrStepStartDate = @ProductionDate;
              END
              SET @CurrStepEndDate = DateAdd(day, @StepSizedays, @CurrStepStartDate);

			  IF (@DeprecatedDate IS NOT NULL OR @DecommissionedDate is NOT NULL) BEGIN 
                IF (ISNULL(@DeprecatedDate,'9999-01-01') < ISNULL(@DecommissionedDate,'9999-01-01')) BEGIN
				    IF (@DeprecatedDate >= @CurrStepStartDate AND @DeprecatedDate <= @CurrStepEndDate) BEGIN
                        PRINT CONCAT('Stage ', @CurrStageDateId, ' deprecated as of ',@DeprecatedDate);
                        Set @CurrStepEndDate = @DeprecatedDate;
                        IF (@CurrStepEndDate <= @CurrStepStartDate) GOTO NextStageDate;
                    END
				END
                ELSE BEGIN
				    IF (@DecommissionedDate >= @CurrStepStartDate AND @DecommissionedDate <= @CurrStepEndDate) BEGIN
                        PRINT CONCAT('Stage ', @CurrStageDateId, ' decommissioned as of ',@DecommissionedDate);
                        Set @CurrStepEndDate = @DecommissionedDate;
                        IF (@CurrStepEndDate <= @CurrStepStartDate) GOTO NextStageDate;
                    END
                END
              End
                        
              PRINT CONCAT('Processing StageDateId:', @CurrStageDateId,' TagName:', @TagName, ' for ...');
              --Get processing date region

              DECLARE @ProcStartDate as datetime, @ProcEndDate as datetime;
			  IF (ISNULL(@DeprecatedDate,'9999-01-01') < ISNULL(@DecommissionedDate,'9999-01-01')) BEGIN
				  SELECT @ProcStartDate = StartDate,  @ProcEndDate = EndDate 
						  FROM [dbo].[fnGetOverlappingDates](@ProductionDate, @DeprecatedDate, @FromDate, @ToDate);
			  END
			  ELSE BEGIN
			  		SELECT @ProcStartDate = StartDate,  @ProcEndDate = EndDate 
						  FROM [dbo].[fnGetOverlappingDates](@ProductionDate, @DecommissionedDate, @FromDate, @ToDate);
			  END
              PRINT CONCAT('...- Processing Start date:', Format(@ProcStartDate,'yyyy-MM-dd'),' and End date:', FORMAT(@ProcEndDate, 'yyyy-MM-dd'));
              IF (@ProcStartDate is NULL) BEGIN 
                      --PRINT CONCAT('valid processing dates not found for StageDateId', @CurrStageDateId);
                      SET @CurrStgDtIx=@CurrStgDtIx+1;
                      CONTINUE; 
              END;

              DECLARE @ProcNextStepStartDate datetime, @ProcNextStepEndDate datetime
              SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
                      FROM [dbo].[fnGetOverlappingDates](@ProcStartDate, @ProcEndDate
                      , @CurrStepStartDate, ISNULL(@CurrStepEndDate, DATEADD(day,@StepSizedays,@CurrStepStartDate)));

			  IF (ISNULL(@DeprecatedDate,'9999-01-01') < ISNULL(@DecommissionedDate,'9999-01-01')) BEGIN
				  IF (@DeprecatedDate IS NOT NULL) SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
					  FROM [dbo].[fnGetOverlappingDates](@ProcNextStepStartDate, @ProcNextStepEndDate, NULL, @DeprecatedDate);
			  END
			  ELSE BEGIN
				  IF (@DecommissionedDate IS NOT NULL) SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
					  FROM [dbo].[fnGetOverlappingDates](@ProcNextStepStartDate, @ProcNextStepEndDate, NULL, @DecommissionedDate);
			  END

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
								,[StageStartDate], [StageEndDate], [DeprecatedDate], [DecommissionedDate]
								,[MinThreshold], [MaxThreshold]
								,[PaceId], [PaceStartDate]
								,[StartDate], [EndDate]
								,[ThresholdDuration], [SetPoint]
							)
						VALUES (
									@CurrStageDateId, @StageId, @TagId, @TagName
								,@StageStartDate, @StageEndDate, @DeprecatedDate, @DecommissionedDate
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
                        , SetPoint = @SetPoint, DeprecatedDate = @DeprecatedDate, DecommissionedDate = @DecommissionedDate, NewRowId = RowId;

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
                                    --, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
                                    , @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
                                    , @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
                                    FROM @ExcPointsWIP;
                                    UPDATE @ExcPoints SET CycleId = @CycleId,  HiPointsCt = HiPointsCt + @HiPointsCt
                                    , LowPointsCt = LowPointsCt + @LowPointsCt
                                                                 --, LastExcDate = @LastExcDate, LastExcValue = @LastExcValue
         --                           , RampOutDate = @RampOutDate, RampOutValue = @RampOutValue
                                    where NewRowId = 1;
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
                      , DeprecatedDate, DecommissionedDate, ThresholdDuration, SetPoint
                      )
              SELECT 
                      --TagId, TagName, IsNull(TagExcNbr,0), StageDateId, @StepLogId as StepLogId
                TagId, TagName, IsNull(TagExcNbr,0), StageDateId, StepLogId
                      , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , LastExcDate, LastExcValue, RampOutDate, RampOutValue
                      , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                      , MinValue, MaxValue, AvergValue, StdDevValue
                      , DeprecatedDate, DecommissionedDate, ThresholdDuration, SetPoint
                      FROM @ExcPoints

              --SELECT @dbgExcsFound = count(*) from @ExcPoints;
              --SELECT top 1 @dbgFirstExcDate = FirstExcDate from @ExcPoints;
              --PRINT CONCAT(' <<< Persist excursions to table: @dbgExcsFound:',@dbgExcsFound,' @dbgFirstExcDate:',@dbgFirstExcDate);

              PRINT ' <<< Persist excursions to table ENDED'
--*****************************************************************************************
              -- Insert PointsPaces' next process row if Tag was not deprecated in the next PointsPace time interval
              if ((@DeprecatedDate IS NULL OR @DeprecatedDate > DateAdd(day,@StepSizeDays,@ProcNextStepStartDate)) OR 
                  (@DecommissionedDate IS NULL OR @DecommissionedDate > DateAdd(day,@StepSizeDays,@ProcNextStepStartDate)) )
                    INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
                        VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays, NULL );

NextStageDate:
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