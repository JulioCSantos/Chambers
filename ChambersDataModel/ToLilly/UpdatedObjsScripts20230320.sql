
ALTER PROCEDURE [dbo].[spGetStats]
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
			FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate,'00:00:01');

		--SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [BB50PCSjsantos].Interpolated as Stat
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

ALTER PROCEDURE [dbo].[spPivotExcursionPoints] (       
         @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
       , @LowThreashold float, @HiThreashold float, @TimeStep time(0) NULL
)
AS
BEGIN
PRINT '>>> spPivotExcursionPoints begins'
IF (@TimeStep IS NULL) SET @TimeStep = CAST('00:00:01' as time(0));

PRINT CONCAT('INPUT: @TagName:',@TagName, ' @StartDate:', @StartDate, ' @EndDate:', @EndDate
              , ' @TimeStep:', @TimeStep);

       --Declare input cursor values
       DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 1; 
       DECLARE @IsHiExc int = -1;

       -- Currently in-process Excursion in date range for Tag (TagName)
       DECLARE @ExcPoint1 as TABLE ( ExcPriority int, CycleId int,
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
       DECLARE @ExcPoints as TABLE ( ExcPriority int, CycleId int,
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
       DECLARE @CycleId int;
       DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
       DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
       DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
       DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
       DECLARE @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

       PRINT 'GET LAST Excursion or Empty (start up) Excursion row'
       INSERT INTO @ExcPoint1 (ExcPriority, CycleId, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
              , HiPointsCt, LowPointsCt, LowThreashold, HiThreashold
              , MinValue, MaxValue, AvergValue, StdDevValue
              , ThresholdDuration, SetPoint)
              SELECT TOP 1 ExcPriority, CycleId, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
              , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
              , MinValue, MaxValue, AvergValue, StdDevValue
              , ThresholdDuration, SetPoint
              FROM (
                      -- get last incomplete Excursion (RampIn only) if one exists
                      SELECT TOP 1 3 as ExcPriority, CycleId, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                      , NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
                      , 120 as ThresholdDuration, 150 as SetPoint FROM [dbo].[ExcursionPoints] 
                      WHERE TagName = @TagName AND RampOutDate is NULL
                      ORDER BY TagName, TagExcNbr Desc
                      UNION ALL
                      -- get completed Excursion (RampIn and RampOut populated) if one exists
                      SELECT TOP 1 2 as ExcPriority, CycleId, TagName, TagExcNbr, NULL as RampInDate, NULL as RampInValue, NULL as FirstExcDate, NULL as FirstExcValue
                      , 0 as HiPointsCt, 0 as LowPointsCt, 100 as MinThreshold, 200 as MaxThreshold
                      , NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
                      , 120 as ThresholdDuration, 150 as SetPoint FROM [dbo].[ExcursionPoints] 
                      WHERE TagName = @TagName AND RampInDate is NOT NULL AND RampOutDate is NOT NULL
                      ORDER BY TagName, TagExcNbr Desc
                      UNION ALL
                      -- Create a new Excursion 
                      SELECT 1 as ExcPriority, -1 as  CycleId, @TagName as TagName, 1 as TagExcNbr, NULL, NULL, NULL, NULL
                      , 0, 0, 100, 200
                      , NULL, NULL, NULL, NULL
                      , 120, 150
                      ) as allExc
              ORDER BY ExcPriority DESC;

       PRINT '@TagExcNbr to latest (or empty) Excursion number'
       DECLARE @ExcPriority int;
       SELECT  @ExcPriority = ExcPriority, @CycleId = CycleId, @TagExcNbr = TagExcNbr
       , @RampInDate = RampInDate, @RampInValue = RampInValue, @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue
       , @RampOutDate = RampOutDate, @RampOutValue = RampOutValue, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue
       , @LowPointsCt = LowPointsCt, @HiPointsCt = HiPointsCt
       FROM @ExcPoint1;
       IF (@ExcPriority = 3) BEGIN
              Print 'In-Progress Excursion found'
              IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
              ELSE SET @IsHiExc = 0;
              PRINT Concat('IsHiExc: ', @IsHiExc);
       END
       ELSE IF (@ExcPriority = 2) BEGIN
              Print 'Completed Excursion found'
              SET @TagExcNbr = @TagExcNbr + 1;
              UPDATE @ExcPoint1 SET TagExcNbr = @TagExcNbr;
       END
       ELSE IF (@ExcPriority = 1) Print 'First Excursion for StageDate (tag) created'

       DECLARE CPoint CURSOR
              --FOR SELECT [tag], [time], [value] from [BB50PCSjsantos].[Interpolated]
              FOR SELECT [tag], [time], [value] from  PI.piarchive..piinterp
              WHERE tag = @TagName 
              AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
              AND (value >= @HiThreashold OR value < @LowThreashold)
              --AND timestep = @TimeStep
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
                      --SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                      SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM PI.piarchive..piinterp
                      WHERE tag = @TagName
                             AND time < FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
                             AND time >= FORMAT(DateAdd(day,-1,@FirstExcDate),'yyyy-MM-dd HH:mm:ss')
                             AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
                             --AND timestep = @TimeStep
                      ORDER BY time Desc;
                      IF (@RampInDate IS NOT NULL) BEGIN
                             UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
                             PRINT Concat('RampIn point: RampInDate:', @RampInDate,' RampInValue:', @RampInValue);
                      END
              END
              
              IF (@RampOutDate IS NULL) BEGIN
                      PRINT 'Find RampOut point'
                      --SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                      SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  PI.piarchive..piinterp
                      WHERE tag = @TagName 
                             AND time > FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                             AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised
                             AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
                             --AND timestep = @TimeStep
                      ORDER BY time Asc;
                      IF (@RampOutDate IS NOT NULL) BEGIN 
                             UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
                             PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
                      END
              END

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
                             INSERT INTO @ExcPoint1 VALUES (0, @CycleId, @TagName, @TagExcNbr
                                    , NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                                    , @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold, NULL, NULL
                                    , NULL, NULL, NULL, NULL);
                      END
              END
       END;

       CLOSE CPoint;
       DEALLOCATE CPoint;
       
       PRINT 'finalize LAST Excursion in date range (end of cursor)'
              IF (@FirstExcDate IS NOT NULL AND @RampOutDate IS NOT NULL) BEGIN
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
              [CycleId], [TagName], [TagExcNbr]
         , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
         , [HiPointsCt], [LowPointsCt], @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
         , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
         , [ThresholdDuration], [SetPoint]
       FROM @ExcPoints 
       WHERE (HiPointsCt > 0 OR LowPointsCt > 0) AND FirstExcDate IS NOT NULL;

-- UNIT TESTS
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
--, @LowThreashold = 100, @HiThreashold = 200;
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-05'
--, @LowThreashold = 100, @HiThreashold = 200;
PRINT 'spPivotExcursionPoints ends <<<'

END
ALTER PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
	@FromDate datetime, -- Processing Start date
	@ToDate datetime, -- Processing ENd date
	@StageDateIds nvarchar(max) = null

AS
BEGIN
PRINT '>>> spDriverExcursionsPointsForDate begins'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
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

	PRINT 'Get PointPaces for all StagesDatesId. If PointsPaces doesnt exist for a StageDate manufacture one.'
	PRINT 'If StagesDatesId list not informed use all StagesDates configured'
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
		(			SELECT P1.PaceId, P1.StageDateId, P1.NextStepStartDate, P1.NextStepEndDate, P1.ProcessedDate, P1.StepSizeDays 
				FROM PointsPaces as P1 WHERE P1.ProcessedDate IS NULL 
		) as PP 
		ON sldc.StageDateId = PP.StageDateId OR PP.PaceId = -1
		WHERE (@StageDateIds IS NULL OR sldc.StageDateId in (SELECT StageDateId From @StageDateIdsTable));


	DECLARE @ExcPoints as TABLE ( CycleId int, TagId int NULL
	, TagName varchar(255), TagExcNbr int NULL
	, StepLogId int NULL, StageDateId int NULL
	, RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
	, LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
	, HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
	, MinValue float, MaxValue float, AvergValue float, StdDevValue float
	, ThresholdDuration int, SetPoint float);

	DECLARE @ExcPointsOutput as TABLE ( CycleId int, TagId int NULL
	, TagName varchar(255), TagExcNbr int NULL
	, StepLogId int NULL, StageDateId int NULL
	, RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
	, LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
	, HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
	, MinValue float, MaxValue float, AvergValue float, StdDevValue float
	, ThresholdDuration int, SetPoint float);

	-- If no Tag details found abort (details are not configured).
	IF (NOT EXISTS(SELECT * FROM @StagesLimitsAndDatesCore)) BEGIN
		PRINT '<<< spDriverExcursionsPointsForDate aborted';
		SELECT * FROM @ExcPoints;
		RETURN;
	END;

	DECLARE @StgDtCount int, @CurrStgDt int = 1;
	SELECT @StgDtCount = count(*) from @StagesLimitsAndDatesCore;
	PRINT 'Process every StageDate'
	WHILE @CurrStgDt <= @StgDtCount BEGIN
		DECLARE @CurrStageDateId int,@TagId int, @TagName varchar(255)
		, @ProductionDate datetime, @DeprecatedDate datetime
		, @CurrStepStartDate datetime, @CurrStepEndDate datetime, @StepSizedays int
		, @MinThreshold float, @MaxThreshold float, @ThresholdDuration float, @SetPoint float
		, @PaceId int;
		SELECT @CurrStageDateId = StageDateId, @TagId = TagId, @TagName = TagName
		, @ProductionDate = ProductionDate, @DeprecatedDate = DeprecatedDate
		, @CurrStepStartDate = NextStepStartDate, @CurrStepEndDate = NextStepEndDate, @StepSizedays = StepSizedays
		, @MinThreshold = MinThreshold, @MaxThreshold = MaxThreshold
		, @ThresholdDuration = ThresholdDuration, @SetPoint = SetPoint
		, @PaceId = PaceId
		FROM @StagesLimitsAndDatesCore WHERE RowID = @CurrStgDt;

		PRINT CONCAT('Processing StageDateId:', @CurrStageDateId,' TagName:', @TagName, ' for ...');
		--Get processing date region
		DECLARE @ProcStartDate as datetime, @ProcEndDate as datetime;
		SELECT @ProcStartDate = StartDate,  @ProcEndDate = EndDate 
			FROM [dbo].[fnGetOverlappingDates](@ProductionDate, @DeprecatedDate, @FromDate, @ToDate);
		PRINT CONCAT('...- Processing Start date:'
			, Format(@ProcStartDate,'yyyy-MM-dd'),' and End date:', FORMAT(@ProcEndDate, 'yyyy-MM-dd'));
		IF (@ProcStartDate is NULL) BEGIN 
			PRINT CONCAT('valid processing dates not found for StageDateId', @CurrStageDateId);
			SET @CurrStgDt=@CurrStgDt+1;
			CONTINUE; 
		END;

		DECLARE @ProcNextStepStartDate datetime, @ProcNextStepEndDate datetime
		SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
			FROM [dbo].[fnGetOverlappingDates](@ProcStartDate, @ProcEndDate
			, @CurrStepStartDate, ISNULL(@CurrStepEndDate, DATEADD(day,@StepSizedays,@CurrStepStartDate)));
		PRINT 'processing first Step using...'; 
		PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd')
			,' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));
		WHILE @ProcNextStepEndDate < @ProcEndDate BEGIN

			BEGIN TRAN;

			PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @TagName, ''', '''
				, FORMAT(@ProcNextStepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'), ''', '
				, CONVERT(varchar(255), @MinThreshold), ', ', CONVERT(varchar(255), @MaxThreshold), ', '
				, Convert(varchar(16), @TagId), ', ' 
				, Convert(varchar(16), @ThresholdDuration), ', ', Convert(varchar(16), @SetPoint)
				);

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

			END

			INSERT INTO @ExcPoints (
				[CycleId], [TagName], [TagExcNbr]
			  , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
			  , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
			  , [HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
			  , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
			  , [ThresholdDuration], [SetPoint]
			)
			EXECUTE [dbo].[spPivotExcursionPoints] @TagName, @ProcNextStepStartDate, @ProcNextStepEndDate
				, @MinThreshold, @MaxThreshold, '00:00:01';

			IF (EXISTS(SELECT * FROM @ExcPoints)) BEGIN
				UPDATE @ExcPoints Set TagId = @TagId, StageDateId = @CurrStageDateId;
				DECLARE @CycleId int, @LastExcDate datetime, @LastExcValue float, @RampOutDate datetime, @RampOutValue float
				, @HiPointsCt int, @LowPointsCt int
				, @MinValue float, @MaxValue float, @AvergValue float, @StdDevValue float;
				SELECT TOP 1 @CycleId = CycleId
				, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
				, @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
				, @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
				FROM @ExcPoints;
				IF (@CycleId < 0) BEGIN
				Insert into ExcursionPoints ( 
					TagId, TagName, TagExcNbr, StageDateId
					, RampInDate, RampInValue, FirstExcDate, FirstExcValue
					, LastExcDate, LastExcValue, RampOutDate, RampOutValue
					, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
					, MinValue, MaxValue, AvergValue, StdDevValue
					, ThresholdDuration, SetPoint
					)
					SELECT TagId, TagName, TagExcNbr, StageDateId
					, RampInDate, RampInValue, FirstExcDate, FirstExcValue
					, LastExcDate, LastExcValue, RampOutDate, RampOutValue
					, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
					, MinValue, MaxValue, AvergValue, StdDevValue
					, ThresholdDuration, SetPoint
					FROM @ExcPoints;
					UPDATE @ExcPoints SET CycleId = SCOPE_IDENTITY();
				END
				ELSE BEGIN
					UPDATE ExcursionPoints 
					SET LastExcDate = @LastExcDate, LastExcValue = @LastExcValue, RampOutDate = @RampOutDate, @RampOutValue = RampOutValue
					, HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt
					, MinValue = @MinValue, MaxValue = @MaxValue, AvergValue = @AvergValue, StdDevValue = @StdDevValue
					WHERE CycleId = @CycleId;
				END
				Insert into @ExcPointsOutput
				SELECT * FROM @ExcPoints;
				DELETE FROM @ExcPoints;
			END


			-- prepare for next Point's step run
			SET @ProcNextStepStartDate = @ProcNextStepEndDate; 
			SET @ProcNextStepEndDate = DateAdd(day, @StepSizedays, @ProcNextStepStartDate);
			PRINT 'processing next Step using...'; 
			PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd')
				,' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));
			
			COMMIT TRAN;

		END
		
		-- Insert PointsPaces' next process row
		INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
			VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays, NULL );

		SET @CurrStgDt=@CurrStgDt+1;
	END;
 

	SELECT * FROM @ExcPointsOutput;

	--UNIT TESTS
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', 12341234

	--***********************************************************
	--DECLARE @PointsPacesTbl TABLE (
	--	RowID int not null primary key identity(1,1)
	--	, PaceId int, StageDateId int, NextStepStartDate datetime, StepSizeDays int, NextStepEndDate datetime, ProcessedDate datetime NULL
	--  );

	----
	--INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
	--SELECT PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate 
	--FROM [dbo].[PointsPaces]
	--WHERE (@StageDateIds IS NULL OR StageDateId in (SELECT StageDateId From @StageDateIdsTable))
	--AND ProcessedDate IS NULL;

	--IF (@StageDateIds IS NULL) BEGIN
	--	INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
	--	SELECT -1 as PaceId, StageDateId, @FromDate as NextStepStartDate, 2 as StepSizeDays
	--		, DateAdd(day,2,@FromDate) as NextStepEndDate, NULL as ProcessedDate 
	--	FROM (SELECT StageDateID from [dbo].[StagesLimitsAndDatesCore] WHERE StageDateId Not IN (SELECT StageDateId FROM @PointsPacesTbl)) as ppsTbl
	--END
	--ELSE BEGIN
	--	INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
	--	SELECT -1 as PaceId, StageDateId, @FromDate as NextStepStartDate, 2 as StepSizeDays
	--		, DateAdd(day,2,@FromDate) as NextStepEndDate, NULL as ProcessedDate 
	--	FROM (SELECT StageDateID from @StageDateIdsTable WHERE StageDateId Not IN (SELECT StageDateId FROM @PointsPacesTbl)) as ppsTbl
	--END

	--DECLARE @stTagId int, @stTagName varchar(255), @stStepLogId int
	--	, @stMinThreshold float, @stMaxThreshold float, @stStartDate as datetime, @stEndDate as datetime
	--	, @stThresholdDuration int, @stSetPoint float;

	--DECLARE @PacesCount int, @CurrPaceRow int = 0;
	--DECLARE @PaceId int, @CurrStageDateId int, @StepStartDate datetime, @StepEndDate datetime, @StepSizedays int;
	--SELECT @PacesCount = count(*) from @PointsPacesTbl;
	--WHILE @CurrPaceRow < @PacesCount BEGIN
	--	SET @CurrPaceRow=@CurrPaceRow+1;
	--	SELECT @PaceId = PaceId, @CurrStageDateId = StageDateId,  @StepStartDate = NextStepStartDate 
	--		, @StepEndDate = NextStepEndDate, @StepSizedays = StepSizeDays
	--	FROM @PointsPacesTbl
	--	WHERE RowID = @CurrPaceRow;
	--	PRINT 'PROCESS Tag through the date date range'
	--	WHILE @StepEndDate < @ToDate BEGIN

	--		BEGIN TRAN;

	--		PRINT Concat('@CurrStageDateId:', @CurrStageDateId, ' @StepStartDate:', @StepStartDate,' @StepEndDate:', @StepEndDate);

	--		SELECT @stTagId = TagId, @stTagName = TagName, @stMinThreshold = MinThreshold, @stMaxThreshold = MaxThreshold
	--			, @stThresholdDuration = ThresholdDuration , @stSetPoint = SetPoint
	--		FROM @StagesLimitsAndDatesCore
	--		WHERE StageDateId = @CurrStageDateId

	--		PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @stTagName, ''', '''
	--			, FORMAT(@StepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@StepEndDate, 'yyyy-MM-dd'), ''', '
	--			, CONVERT(varchar(255), @stMinThreshold), ', ', CONVERT(varchar(255), @stMaxThreshold), ', '
	--			, Convert(varchar(16), @stTagId), ', ', Convert(varchar(16), @stStepLogId), ', '
	--			, Convert(varchar(16), @stThresholdDuration), ', ', Convert(varchar(16), @stSetPoint)
	--			);

	--		INSERT INTO @ExcPoints (
	--			[CycleId], [TagName], [TagExcNbr]
	--		  , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
	--		  , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
	--		  , [HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
	--		  , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
	--		  , [ThresholdDuration], [SetPoint]
	--		)
	--		EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @StepStartDate, @StepEndDate, @stMinThreshold, @stMaxThreshold
	--			, @stThresholdDuration, @stSetPoint;
			
	--		DECLARE @CycleId int
	--		, @LastExcDate datetime, @LastExcValue float,  @RampOutDate DateTime, @RampOutValue float
	--		, @HiPointsCt int, @LowPointsCt int
	--		, @MinValue float, @MaxValue float, @AvergValue float, @StdDevValue float
	--		SELECT TOP 1 @CycleId = CycleId
	--		, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue 
	--		, @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
	--		, @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
	--		From @ExcPoints;

	--		IF (@CycleId < 0) BEGIN
	--		Insert into ExcursionPoints ( 
	--			TagName, TagExcNbr
	--			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
	--			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
	--			, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
	--			, MinValue, MaxValue, AvergValue, StdDevValue
	--			, ThresholdDuration, SetPoint
	--			)
	--			SELECT TagName, TagExcNbr
	--			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
	--			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
	--			, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
	--			, MinValue, MaxValue, AvergValue, StdDevValue
	--			, ThresholdDuration, SetPoint
	--			FROM @ExcPoints;
	--		END
	--		ELSE BEGIN
	--			UPDATE ExcursionPoints 
	--			SET LastExcDate = @LastExcDate, LastExcValue = @LastExcValue, RampOutDate = @RampOutDate, @RampOutValue = RampOutValue
	--			, HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt
	--			, MinValue = @MinValue, MaxValue = @MaxValue, AvergValue = @AvergValue, StdDevValue = @StdDevValue
	--			WHERE CycleId = @CycleId;
	--		END

	--		IF (@PaceId <= 0) BEGIN
	--			INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
	--				 VALUES (@CurrStageDateId, @StepStartDate, @StepSizedays, GetDate() ); 
	--		END
	--		ELSE BEGIN
	--			UPDATE [dbo].[PointsPaces] SET ProcessedDate = GetDate()
	--			WHERE PaceId = @PaceId;
	--		END

	--		-- prepare for next Point's step run
	--		SET @StepStartDate = @StepEndDate; 
	--		SET @StepEndDate = DateAdd(day, @StepSizedays, @StepEndDate) ;
	--		SET @PaceId = -1;

	--		COMMIT TRAN;

	--	END

	--	-- Last PointsPace row of the date range
	--	INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
	--	VALUES (@CurrStageDateId, @StepStartDate, @StepSizedays, NULL ); 

	--	Insert into @ExcPointsOutput
	--	SELECT * FROM @ExcPoints;

	--END

	--SELECT * FROM @ExcPointsOutput;


	----UNIT TESTS
	----EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
	----EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
	----EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', 12341234

	----***************************************************************************************************************


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