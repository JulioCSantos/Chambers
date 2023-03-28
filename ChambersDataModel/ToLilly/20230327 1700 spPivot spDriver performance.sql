ALTER PROCEDURE [dbo].[spPivotExcursionPoints] (       
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
                SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM PI.piarchive..piinterp
                --SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                WHERE tag = @TagName
                        AND time < FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
                        AND time >= FORMAT(DateAdd(day,-1,@FirstExcDate),'yyyy-MM-dd HH:mm:ss')
                        AND value is not null
                        AND (
                        (@IsHiExc = 1 AND @HiThreashold IS NOT NULL AND value < @HiThreashold) 
                        OR 
                        (@IsHiExc = 0 AND @LowThreashold IS NOT NULL AND value > @LowThreashold )
                    )
                        AND timestep = @TimeStep
                ORDER BY time Desc;
                UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
                PRINT Concat('RampIn point: RampInDate:', @RampInDate,' RampInValue:', @RampInValue);
        END

        -- find RampOut point
        IF (@RampOutDate IS NULL AND @FirstExcDate IS NOT NULL) BEGIN
                PRINT 'Find RampOut point'
                SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  PI.piarchive..piinterp
                --SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                WHERE tag = @TagName 
                        AND time > FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                        AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised 
                        AND value is not null
                        AND (
                        (@LowThreashold IS NULL OR value >= @LowThreashold)  
                        AND 
                        (@HiThreashold IS NULL OR value < @HiThreashold)
                    )
                        AND timestep = @TimeStep
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
                                SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM  PI.piarchive..piinterp
                                --SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                                WHERE tag = @TagName 
                                    AND time >= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND time < FORMAT(@RampOutDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND value is not null
                                    AND ((@IsHiExc = 1 AND value >= @HiThreashold) OR (@IsHiExc = 0 AND value < @LowThreashold ))
                                    AND timestep = @TimeStep
                                ORDER BY time Desc;
                        END
                        ELSE BEGIN
                                SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM  PI.piarchive..piinterp
                                --SELECT TOP 1 @LastExcDate = [time], @LastExcValue =  [value] FROM [BB50PCSjsantos].[Interpolated]
                                WHERE tag = @TagName 
                                    AND time >= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
                                    AND value is not null
                                    AND ((@IsHiExc = 1 AND value >= @HiThreashold) OR (@IsHiExc = 0 AND value < @LowThreashold ))
                                    AND timestep = @TimeStep
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

END
GO
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


	DECLARE @ExcPoints as TABLE ( RowID int not null primary key identity(1,1)
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

	DECLARE @ExcPointsOutput as TABLE ( RowID int NULL
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
	DECLARE @StgDtCount int, @CurrStgDtIx int = 1;
	SELECT @StgDtCount = count(*) from @StagesLimitsAndDatesCore;
	PRINT 'Process every StageDate'
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

		PRINT CONCAT('Processing StageDateId:', @CurrStageDateId,' TagName:', @TagName, ' for ...');
		--Get processing date region
		DECLARE @ProcStartDate as datetime, @ProcEndDate as datetime;
		SELECT @ProcStartDate = StartDate,  @ProcEndDate = EndDate 
			FROM [dbo].[fnGetOverlappingDates](@ProductionDate, @DeprecatedDate, @FromDate, @ToDate);
		PRINT CONCAT('...- Processing Start date:'
			, Format(@ProcStartDate,'yyyy-MM-dd'),' and End date:', FORMAT(@ProcEndDate, 'yyyy-MM-dd'));
		IF (@ProcStartDate is NULL) BEGIN 
			PRINT CONCAT('valid processing dates not found for StageDateId', @CurrStageDateId);
			SET @CurrStgDtIx=@CurrStgDtIx+1;
			CONTINUE; 
		END;

		DECLARE @ProcNextStepStartDate datetime, @ProcNextStepEndDate datetime
		SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
			FROM [dbo].[fnGetOverlappingDates](@ProcStartDate, @ProcEndDate
			, @CurrStepStartDate, ISNULL(@CurrStepEndDate, DATEADD(day,@StepSizedays,@CurrStepStartDate)));

		IF (@DeprecatedDate IS NOT NULL) SELECT @ProcNextStepStartDate = StartDate,  @ProcNextStepEndDate = EndDate 
					FROM [dbo].[fnGetOverlappingDates](@ProcNextStepStartDate, @ProcNextStepEndDate, NULL, @DeprecatedDate);

		PRINT 'processing first Step using...'; 
		PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd')
			,' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));
			
		--BEGIN TRAN;
		PRINT 'Process one day'
		WHILE @ProcNextStepEndDate < @ProcEndDate BEGIN


			PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @TagName, ''', '''
				, ' StageDateId:', @CurrStageDateId 
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

			-- Find Excursions in date range
			DECLARE @pivotReturnValue int = 0;
			--INSERT INTO @ExcPoints (
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

			DECLARE @ExcsFound int;
			SELECT @ExcsFound = count(*) from @ExcPoints;

			SET @ProcNextStepStartDate = @ProcNextStepEndDate; 
			SET @ProcNextStepEndDate = DateAdd(day, @StepSizedays, @ProcNextStepStartDate);
			PRINT 'processing next Step using...'; 
			PRINT CONCAT(' @ProcNextStepStartDate:', FORMAT(@ProcNextStepStartDate,'yyyy-MM-dd')
				,' @ProcNextStepEndDate:', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd'));

		END -- Next day in date Range
--*****************************************************************************************

       PRINT 'GET Latest Excursion row from [ExcursionPoints] table'
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


		DECLARE @wCycleId int, @wLastExcDate datetime, @wLastExcValue float, @wRampOutDate datetime, @wRampOutValue float
		, @wHiPointsCt int, @wLowPointsCt int, @wTagExcNbr int
		, @wMinValue float, @wMaxValue float, @wAvergValue float, @wStdDevValue float;
		DECLARE @currTagExcNbr int;

		IF (EXISTS(SELECT * FROM @ExcPointsWIP)) BEGIN
			SELECT TOP 1 @wCycleId = CycleId
			, @wLastExcDate = LastExcDate, @wLastExcValue = LastExcValue, @wRampOutDate = RampOutDate, @wRampOutValue = RampOutValue
			, @wHiPointsCt = HiPointsCt, @wLowPointsCt = LowPointsCt, @wTagExcNbr = TagExcNbr
			, @wMinValue = MinValue, @wMaxValue = MaxValue, @wAvergValue = AvergValue, @wStdDevValue = StdDevValue
			FROM @ExcPointsWIP;
			IF (@wRampOutDate IS NOT NULL) BEGIN -- Only TagExcNbr is needed from a completed Excursion 
				SET @currTagExcNbr = @wTagExcNbr + 1;
				IF (@wRampOutValue > @ProcNextStepStartDate) SET @ProcNextStepStartDate = @wRampOutValue;
				DELETE FROM @ExcPointsWIP
			END
		END
		ELSE SET @currTagExcNbr = 1; -- initialize TagExcNbr for Tag's (StageDateId) first Excursion

		IF (@wTagExcNbr IS NULL) SET @currTagExcNbr = 1
		ELSE BEGIN
			IF (@wRampOutDate IS NOT NULL) BEGIN
				SET @currTagExcNbr = @wTagExcNbr + 1;
				DELETE FROM @ExcPointsWIP
			END
		END
		

		DELETE FROM @ExcPointsOutput;
		DELETE FROM @ExcPointsWIP;
		DECLARE @pvtExcCount int, @pvtExcIx int = 1;
		SELECT @pvtExcCount = count(*) from @ExcPoints;
		PRINT 'Process every spPivot excursion result'
		WHILE @pvtExcIx <= @pvtExcCount BEGIN

			if (NOT EXISTS(SELECT * FROM @ExcPointsWIP)) BEGIN
				PRINT 'INSERT'
				Insert into @ExcPointsWIP 
				SELECT * FROM @ExcPoints WHERE RowId = @pvtExcIx;

				SELECT @wCycleId = CycleId
				, @wLastExcDate = LastExcDate, @wLastExcValue = LastExcValue, @wRampOutDate = RampOutDate, @wRampOutValue = RampOutValue
				, @wHiPointsCt = HiPointsCt, @wLowPointsCt = LowPointsCt, @wTagExcNbr = TagExcNbr
				, @wMinValue = MinValue, @wMaxValue = MaxValue, @wAvergValue = AvergValue, @wStdDevValue = StdDevValue
				FROM @ExcPointsWIP
				UPDATE @ExcPointsWIP SET ThresholdDuration = @ThresholdDuration, SetPoint = @SetPoint, DeprecatedDate = @DeprecatedDate;

				IF (@currTagExcNbr IS NOT NULL) UPDATE @ExcPointsWIP SET TagExcNbr = @currTagExcNbr;

				SET @pvtExcIx=@pvtExcIx+1;
				CONTINUE; --skip to next excursion (if any)
			END

			IF (@wRampOutDate IS NULL) BEGIN
				PRINT 'Get current Excursion'
				DECLARE @CycleId int, @LastExcDate datetime, @LastExcValue float, @RampOutDate datetime, @RampOutValue float
				, @HiPointsCt int, @LowPointsCt int
				, @MinValue float, @MaxValue float, @AvergValue float, @StdDevValue float;
				SELECT @CycleId = CycleId
				, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
				, @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
				, @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
				FROM @ExcPoints
				WHERE RowId = @pvtExcIx;

				PRINT 'MERGE' -- Must use Minimum and Maximum calculations for stats
				UPDATE @ExcPointsWIP SET HiPointsCt = HiPointsCt + @HiPointsCt
				, LowPointsCt = LowPointsCt + @LowPointsCt, LastExcDate = @LastExcDate, LastExcValue = @LastExcValue
				, RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
			END
			ELSE BEGIN
				PRINT 'RELEASE TO OUTPUT and save the current Excursion in @ExcPointsWIP'
				INSERT INTO @ExcPointsOutput
				SELECT * FROM @ExcPointsWIP;
				
				DELETE FROM @ExcPointsWIP;
				
				Insert into @ExcPointsWIP 
				SELECT * FROM @ExcPoints WHERE RowId = @pvtExcIx;
				SET @currTagExcNbr = @currTagExcNbr + 1;
			END

			SET @pvtExcIx=@pvtExcIx+1;

		END -- Next spPivot excursion row
--*****************************************************************************************
		
		DELETE FROM @ExcPoints;

		-- handle the last Excursion
		INSERT INTO @ExcPointsOutput
		SELECT * FROM @ExcPointsWIP;
		DELETE FROM @ExcPointsWIP;

		Insert into ExcursionPoints ( 
			TagId, TagName, TagExcNbr, StageDateId, StepLogId
			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
			, MinValue, MaxValue, AvergValue, StdDevValue
			, DeprecatedDate, ThresholdDuration, SetPoint
			)
		SELECT 
			TagId, TagName, TagExcNbr, StageDateId, @StepLogId as StepLogId
			, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
			, MinValue, MaxValue, AvergValue, StdDevValue
			, DeprecatedDate, ThresholdDuration, SetPoint
			FROM @ExcPointsOutput;

		-- Insert PointsPaces' next process row if Tag was not deprecated in the next PointsPace time interval
		if (@DeprecatedDate IS NULL OR @DeprecatedDate > DateAdd(day,1,@ProcNextStepStartDate))
		INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
			VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays, NULL );

		--IF (@pivotReturnValue = 0) COMMIT TRAN;
		--ELSE BEGIN 
		--	ROLLBACK TRAN; 
		--	PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @TagName, ''', '''
		--	, ' StageDateId:', @CurrStageDateId 
		--	, FORMAT(@ProcNextStepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd')
		--	, 'ROLLED BACK')
		--	SET @pivotReturnValue = -1;
		--	GOTO spDriverExit;
		--END


		SET @CurrStgDtIx=@CurrStgDtIx+1;
	END; -- Next stageDate
 

spDriverExit:
			
SELECT * FROM @ExcPointsOutput;
--SELECT * FROM @ExcPoints;

PRINT 'spDriverExcursionsPointsForDate ends <<<'

RETURN @pivotReturnValue;
--RETURN 0;;


END;
