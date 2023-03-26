ALTER PROCEDURE [dbo].[spPivotExcursionPoints] (       
         @StageDateId int, @StartDate DateTime, @EndDate DateTime
       , @LowThreashold float, @HiThreashold float, @TimeStep time(0) NULL,  @TimeOutDayFactor float NULL
)
AS
BEGIN
PRINT '>>> spPivotExcursionPoints begins'
DECLARE @MaximumDate datetime = DateAdd(day,-1,GetDate()) ;
IF (@EndDate > @MaximumDate) SET @EndDate = @MaximumDate;

DECLARE  @TagName varchar(255), @returnValue int = 0;;
SELECT TOP 1 @TagName = sldc.TagName
FROM StagesLimitsAndDatesCore as sldc
WHERE sldc.StageDateId = @StageDateId;
IF (@TagName IS NULL) BEGIN
	PRINT CONCAT('TagName not found for StageDateId:', @StageDateId);
	RAISERROR ('TagName not found for StageDateId',1,1);
	SET @returnValue = -1;
	GOTO ReturnResult;
END

PRINT CONCAT('INPUT: @StageDateId:',@StageDateId, ' @StartDate:', @StartDate, ' @EndDate:', @EndDate
              ,' @LowThreashold:',@LowThreashold, ' @TimeStep:', @TimeStep);

       --Declare input cursor values
       DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 1; 
       DECLARE @IsHiExc int = -1;

       -- Currently in-process Excursion in date range for Tag (TagName)
       DECLARE @ExcPoint1 as TABLE ( ExcPriority int, CycleId int, StageDateId int
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
       -- Finished processed (saved) Excursions in date range
       DECLARE @ExcPointsOutput as TABLE ( ExcPriority int, CycleId int, StageDateId int
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
       DECLARE @CycleId int;
       DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
       DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
       DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
       DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
       DECLARE @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

       PRINT 'GET LAST Excursion or Empty (start up) Excursion row'
       INSERT INTO @ExcPoint1 (ExcPriority, CycleId, StageDateId, TagName, TagExcNbr
              , RampInDate, RampInValue, FirstExcDate, FirstExcValue
              , HiPointsCt, LowPointsCt, LowThreashold, HiThreashold
              , MinValue, MaxValue, AvergValue, StdDevValue
              , ThresholdDuration, SetPoint)
              SELECT TOP 1 ExcPriority, CycleId, StageDateId, TagName, TagExcNbr
              , RampInDate, RampInValue, FirstExcDate, FirstExcValue
              , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
              , MinValue, MaxValue, AvergValue, StdDevValue
              , ThresholdDuration, SetPoint
              FROM (
                      -- get last incomplete Excursion (RampIn only) if one exists
                      SELECT TOP 1 3 as ExcPriority, CycleId, StageDateId, TagName, TagExcNbr
					  , RampInDate, RampInValue, FirstExcDate, FirstExcValue
                      , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
                      , NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
                      , ThresholdDuration, SetPoint FROM [dbo].[ExcursionPoints] 
                      WHERE StageDateId = @StageDateId AND RampOutDate is NULL
                      ORDER BY TagName, TagExcNbr Desc
                      UNION ALL
                      -- get completed Excursion (RampIn and RampOut populated) if one exists
                      SELECT TOP 1 2 as ExcPriority, -1 as CycleId, StageDateId, TagName, TagExcNbr
					  , NULL as RampInDate, NULL as RampInValue, NULL as FirstExcDate, NULL as FirstExcValue
                      , 0 as HiPointsCt, 0 as LowPointsCt, 100 as MinThreshold, 200 as MaxThreshold
                      , NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
                      , ThresholdDuration, SetPoint FROM [dbo].[ExcursionPoints] 
                      WHERE StageDateId = @StageDateId AND RampInDate is NOT NULL AND RampOutDate is NOT NULL
                      ORDER BY TagName, TagExcNbr Desc
                      UNION ALL
                      -- Create a new Excursion 
                      SELECT 1 as ExcPriority, -1 as  CycleId, @StageDateId as StageDateId, @TagName as TagName, 1 as TagExcNbr
					  , NULL, NULL, NULL, NULL
                      , 0, 0, 100, 200
                      , NULL, NULL, NULL, NULL
                      , NULL, NULL
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

       --DECLARE CPoint CURSOR
       --       --FOR SELECT [tag], [time], [value] from  PI.piarchive..piinterp
       --       FOR SELECT [tag], [time], [value] from [BB50PCSjsantos].[Interpolated]
       --       WHERE tag = @TagName 
       --       AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
       --       AND (value >= @HiThreashold OR value < @LowThreashold)
       --       --AND timestep = @TimeStep
       --       ORDER BY time;

       --OPEN CPoint;
       --FETCH NEXT FROM CPoint INTO @tag, @time, @value;
       --PRINT Concat('First Excursion point: @time:', @time,' @Value:', @value);

    PRINT 'Loop datetime range'
	DECLARE @CurrStartDate datetime = @StartDate;
    WHILE @CurrStartDate < @EndDate  BEGIN
				
		IF (@FirstExcDate IS NULL) BEGIN -- dont get the First Excursion Point for In-Progress excursion
			PRINT 'Find First Excursion Point'
			--SELECT TOP 1 @FirstExcDate = [time], @FirstExcValue = [value] FROM PI.piarchive..piinterp
			SELECT TOP 1 @FirstExcDate = [time], @FirstExcValue = [value] FROM [BB50PCSjsantos].[Interpolated]
				WHERE tag = @TagName 
				AND time >= FORMAT(@CurrStartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
				AND value is not null
				AND (value >= @HiThreashold OR value < @LowThreashold)
				--AND timestep = @TimeStep
				ORDER BY time;
			UPDATE @ExcPoint1 SET FirstExcDate = @FirstExcDate, FirstExcValue = @FirstExcValue;
		END

		-- if no excursion point found break away
		IF (@FirstExcDate IS NULL) BREAK;

		-- determine if this is a High or Low excursion
		IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
        ELSE SET @IsHiExc = 0;
        PRINT Concat('IsHiExc: ', @IsHiExc);

		if (@ExcPriority <> 3) BEGIN -- dont get RampIn Point for In-Progress excursion
			PRINT 'Find RampIn point'
			--SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM PI.piarchive..piinterp
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
			WHERE tag = @TagName
				AND time < FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
				AND time >= FORMAT(DateAdd(day,-1,@FirstExcDate),'yyyy-MM-dd HH:mm:ss')
				AND value is not null
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
				--AND timestep = @TimeStep
			ORDER BY time Desc;
			UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
			PRINT Concat('RampIn point: RampInDate:', @RampInDate,' RampInValue:', @RampInValue);
		END

		-- find RampOut point
		IF (@RampOutDate IS NULL AND @FirstExcDate IS NOT NULL) BEGIN
			PRINT 'Find RampOut point'
			--SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  PI.piarchive..piinterp
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
			WHERE tag = @TagName 
				AND time > FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
				AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised
				AND value is not null
				AND value >= @LowThreashold  AND value < @HiThreashold
				--AND timestep = @TimeStep
			ORDER BY time Asc;
			UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
			PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
        END

		-- find last excursion point
		IF (@RampOutDate IS NULL AND @FirstExcDate IS NOT NULL) BEGIN
            PRINT 'Find RampOut point'
            --SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  PI.piarchive..piinterp
            SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
            WHERE tag = @TagName 
                AND time > FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised
				AND value is not null
                AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
                --AND timestep = @TimeStep
            ORDER BY time Asc;
            UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
            PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
            END

			PRINT 'Prepare for a new Excursion Cycle or end of while loop if RampOutDate or LastExcDate is before @EndDate'
            IF (@RampOutDate is not null and @RampOutDate < @EndDate) SET @CurrStartDate = DateAdd(SECOND,1,@RampOutDate)
			ELSE IF (@LastExcDate is not null and @LastExcDate < @EndDate) SET @CurrStartDate = DateAdd(SECOND,1,@LastExcDate)
			ELSE SET @CurrStartDate = @EndDate; --finalize while loop
			
            PRINT 'Update aggregated values (Min, Max, Averg, StdDev) if full Excursion found'
            IF (@FirstExcDate IS NOT NULL AND @LastExcDate IS NOT NULL) BEGIN
            PRINT 'Update aggregated values'
            DECLARE @OMinValue float, @OMaxValue float, @OAvergValue float, @OStdDevValue float;
            EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
                    , @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
                    , @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
            UPDATE @ExcPoint1 SET MinValue = @OMinValue, MaxValue = @OMaxValue
                            , AvergValue = @OAvergValue, StdDevValue = @OStdDevValue;
            END

					
            IF (@CurrStartDate < @EndDate) BEGIN
                PRINT 'Save Current Excursion and prepare for Next'
                INSERT INTO @ExcPointsOutput Select * FROM @ExcPoint1;
                DELETE FROM @ExcPoint1;
                SET @TagExcNbr = @TagExcNbr + 1;
                SET @RampInDate = NULL; SET @RampInValue = NULL; SET @FirstExcDate = NULL; SET @FirstExcValue = NULL;
                SET @LastExcDate = NULL; SET @LastExcValue = NULL; SET @RampOutDate = NULL; SET @RampOutValue = NULL;
                SET @HiPointsCt = 0; SET @LowPointsCt = 0;
                INSERT INTO @ExcPoint1 VALUES (0, @CycleId, @StageDateId, @TagName, @TagExcNbr
                    , NULL, NULL, NULL, NULL
                    , NULL, NULL, NULL, NULL
                    , @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold, NULL, NULL
                    , NULL, NULL, NULL, NULL);
            END

       END;

ReturnResult:
       SELECT 
         [CycleId], [StageDateId], [TagName], [TagExcNbr]
         , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
         , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
         , [HiPointsCt], [LowPointsCt], @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
         , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
         , [ThresholdDuration], [SetPoint]
       FROM @ExcPointsOutput 
      -- WHERE (HiPointsCt > 0 OR LowPointsCt > 0);
       --WHERE (HiPointsCt > 0 OR LowPointsCt > 0) AND FirstExcDate IS NOT NULL;

	   PRINT 'spPivotExcursionPoints ends <<<'
	   RETURN @returnValue;

END