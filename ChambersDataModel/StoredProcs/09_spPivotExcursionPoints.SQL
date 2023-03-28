CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (       
         @StageDateId int, @StartDate DateTime, @EndDate DateTime
       , @LowThreashold float, @HiThreashold float, @TimeStep time(0) NULL
)
AS
BEGIN
PRINT '>>> spPivotExcursionPoints begins'
DECLARE @MaximumDate datetime = DateAdd(day,-1,GetDate()) ;
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

PRINT CONCAT('INPUT: @StageDateId:',@StageDateId, ' @StartDate:', @StartDate, ' @EndDate:', @EndDate
              ,' @LowThreashold:',@LowThreashold, ' @HiThreashold:',@HiThreashold, ' @TimeStep:', @TimeStep);

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

	Print 'Set First Excursion for tag (StageDateId, TagId and TagName) created'
	INSERT INTO @ExcPoint1
		-- Create a new Excursion 
	SELECT 1 as ExcPriority, -1 as  CycleId, @StageDateId as StageDateId, @TagId as TagId
		, @TagName as TagName, 1 as TagExcNbr
		, NULL, NULL, NULL, NULL
		, NULL, NULL, NULL, NULL
		, 0, 0, @LowThreashold, @HiThreashold
		, NULL, NULL, NULL, NULL
		, @ThresholdDuration, @SetPoint

    PRINT '@TagExcNbr from latest Excursion number (if any)'
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

    PRINT 'Loop datetime range'
    DECLARE @CurrStartDate datetime = @StartDate;
    WHILE @CurrStartDate < @EndDate  BEGIN
                             
		PRINT 'Find First Excursion Point using ..'
		PRINT CONCAT('.. @CurrStartDate', FORMAT(@CurrStartDate,'yyyy-MM-dd HH:mm:ss')
				,' @EndDate', FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss')
				,' @HiThreashold:',@HiThreashold,' @LowThreashold:',@LowThreashold);
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
		PRINT Concat('First Excursion point: @@FirstExcDate:', @FirstExcDate,' @FirstExcValue:', @FirstExcValue);

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
        PRINT Concat('IsHiExc: ', @IsHiExc);

        if (@RampInDate IS NULL) BEGIN -- dont get RampIn Point for In-Progress excursion
                PRINT 'Find RampIn point'
                --SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM PI.piarchive..piinterp
                SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                WHERE tag = @TagName
                        AND time < FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
                        AND time >= FORMAT(DateAdd(day,-1,@FirstExcDate),'yyyy-MM-dd HH:mm:ss')
                        AND value is not null
                        AND (
                        (@IsHiExc = 1 AND @HiThreashold IS NOT NULL AND value < @HiThreashold) 
                        OR 
                        (@IsHiExc = 0 AND @LowThreashold IS NOT NULL AND value > @LowThreashold )
                    )
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
                        AND (
                        (@LowThreashold IS NULL OR value >= @LowThreashold)  
                        AND 
                        (@HiThreashold IS NULL OR value < @HiThreashold)
                    )
                        --AND timestep = @TimeStep
                ORDER BY time Asc;
                UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
                PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
        END

        -- find last excursion point
        IF (@FirstExcDate IS NOT NULL) BEGIN
            PRINT 'Find Last Excursion point'
            PRINT Concat(' RampOutValue:', @RampOutValue, ' @FirstExcDate:', @FirstExcDate
                        , ' @EndDate:', @EndDate, ' @IsHiExc:', @IsHiExc, ' @HiThreashold:', @HiThreashold
                        ,  ' @LowThreashold:', @LowThreashold );
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
        PRINT Concat('Last Excursion point: @LastExcDate:', @LastExcDate, ' @LastExcValue:', @LastExcValue);
        END

        PRINT 'Prepare for a new Excursion Cycle or terminate while loop if RampOutDate or LastExcDate is before @EndDate'
        PRINT CONCAT('@CurrStartDate:',@CurrStartDate,' @RampOutDate:', @RampOutDate, ' @LastExcDate:', @LastExcDate, ' @EndDate:', @EndDate);
        
        IF (@RampOutDate is not null and @RampOutDate < @EndDate) SET @CurrStartDate = DateAdd(SECOND,1,@RampOutDate)
        ELSE IF (@LastExcDate is not null and @LastExcDate < @EndDate) SET @CurrStartDate = DateAdd(SECOND,1,@LastExcDate)
        ELSE SET @CurrStartDate = @EndDate; --finalize while loop
        PRINT CONCAT('@CurrStartDate:',@CurrStartDate);
                      
        IF (@FirstExcDate IS NOT NULL AND @LastExcDate IS NOT NULL) BEGIN
            PRINT 'Update aggregated values (count, Min, Max, Averg, StdDev) if full Excursion found'
            DECLARE @OExcPointsCount int, @OMinValue float, @OMaxValue float, @OAvergValue float, @OStdDevValue float;
            EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
                    , @ExcPointsCount = @OExcPointsCount OUTPUT, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
                    , @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
            UPDATE @ExcPoint1 SET MinValue = @OMinValue, MaxValue = @OMaxValue
                            , AvergValue = @OAvergValue, StdDevValue = @OStdDevValue;
            IF (@IsHiExc = 1) Update @ExcPoint1 Set HiPointsCt = @OExcPointsCount
            ELSE Update @ExcPoint1 Set LowPointsCt = @OExcPointsCount
            PRINT 'aggregated values updated'
        END

        PRINT 'Save Current Excursion and prepare for Next'
        INSERT INTO @ExcPointsOutput Select * FROM @ExcPoint1;
        DELETE FROM @ExcPoint1;
        DECLARE @ExcSavedCount int; SELECT @ExcSavedCount = count(*) from @ExcPointsOutput;
        PRINT CONCAT('Number of excursions saved:',@ExcSavedCount);
           
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

          PRINT 'spPivotExcursionPoints ends <<<'
          RETURN @returnValue;

                 -- Latest Excursion for tag (TagName)
       --DECLARE @PreviousExcurson as TABLE ( ExcPriority int, CycleId int, StageDateId int, TagId int
       --     , TagName varchar(255), TagExcNbr int
       --     , RampInDate DateTime, RampInValue float
       --     , FirstExcDate DateTime, FirstExcValue float
       --     , LastExcDate DateTime, LastExcValue float
       --     , RampOutDate DateTime, RampOutValue float
       --     , HiPointsCt int, LowPointsCt int
       --     , LowThreashold float, HiThreashold float
       --     , MinValue float, MaxValue float
       --     , AvergValue float, StdDevValue float
       --     , ThresholdDuration int, SetPoint float);

          --    PRINT 'GET Latest Excursion row from [ExcursionPoints] table'
   --    INSERT INTO @PreviousExcurson (ExcPriority, CycleId, StageDateId, TagName, TagExcNbr
   --         , RampInDate, RampInValue, FirstExcDate, FirstExcValue
   --         , HiPointsCt, LowPointsCt, LowThreashold, HiThreashold
   --         , MinValue, MaxValue, AvergValue, StdDevValue
   --         , ThresholdDuration, SetPoint)
   --         SELECT TOP 1 ExcPriority, CycleId, StageDateId, TagName, TagExcNbr
   --         , RampInDate, RampInValue, FirstExcDate, FirstExcValue
   --         , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
   --         , MinValue, MaxValue, AvergValue, StdDevValue
   --         , ThresholdDuration, SetPoint
   --         FROM (
   --             -- get last incomplete Excursion (RampIn only) if one exists
   --             SELECT TOP 1 3 as ExcPriority, CycleId, StageDateId, TagName, TagExcNbr
   --                             , RampInDate, RampInValue, FirstExcDate, FirstExcValue
   --             , HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
   --             , NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
   --             , ThresholdDuration, SetPoint FROM [dbo].[ExcursionPoints] 
   --             WHERE StageDateId = @StageDateId AND RampOutDate is NULL
   --             ORDER BY TagName, TagExcNbr Desc
   --             UNION ALL
   --             -- get completed Excursion (RampIn and RampOut populated) if one exists
   --             SELECT TOP 1 2 as ExcPriority, -1 as CycleId, StageDateId, TagName, TagExcNbr
   --                             , NULL as RampInDate, NULL as RampInValue, NULL as FirstExcDate, NULL as FirstExcValue
   --             , 0 as HiPointsCt, 0 as LowPointsCt, 100 as MinThreshold, 200 as MaxThreshold
   --             , NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
   --             , ThresholdDuration, SetPoint FROM [dbo].[ExcursionPoints] 
   --             WHERE StageDateId = @StageDateId AND RampInDate is NOT NULL AND RampOutDate is NOT NULL
   --             ORDER BY TagName, TagExcNbr Desc
			--) as LatestExc
   --         ORDER BY ExcPriority DESC;

END
