﻿CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
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

				
		DECLARE @wCycleId int, @wLastExcDate datetime, @wLastExcValue float, @wRampOutDate datetime, @wRampOutValue float
		, @wHiPointsCt int, @wLowPointsCt int
		, @wMinValue float, @wMaxValue float, @wAvergValue float, @wStdDevValue float;		

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
				, @wHiPointsCt = HiPointsCt, @wLowPointsCt = LowPointsCt
				, @wMinValue = MinValue, @wMaxValue = MaxValue, @wAvergValue = AvergValue, @wStdDevValue = StdDevValue
				FROM @ExcPointsWIP

				SET @pvtExcIx=@pvtExcIx+1;
				CONTINUE; --skip to next excursion (if any)
			END

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

			IF (@wRampOutDate IS NULL) BEGIN
				PRINT 'MERGE' -- Must use Minimum and Maximum calculations for stats
				UPDATE @ExcPointsWIP SET HiPointsCt = HiPointsCt + @HiPointsCt
				, LowPointsCt = LowPointsCt + @LowPointsCt, LastExcDate = @LastExcDate, LastExcValue = @LastExcValue
				, RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
			END
			ELSE BEGIN
				PRINT 'RELEASE TO OUTPUT and Insert the focused ExcPoints row'
				INSERT INTO @ExcPointsOutput
				SELECT * FROM @ExcPointsWIP;
				
				DELETE FROM @ExcPointsWIP;
				
				Insert into @ExcPointsWIP 
				SELECT * FROM @ExcPoints WHERE RowId = @pvtExcIx;
			END

			SET @pvtExcIx=@pvtExcIx+1;

		END -- Next spPivot excursion row
		
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

		-- Insert PointsPaces' next process row
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

--UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '12341234'


				--Insert into @ExcPointsWIP ( 
				--	RowId, TagId, TagName, TagExcNbr, StageDateId, StepLogId
				--	, RampInDate, RampInValue, FirstExcDate, FirstExcValue
				--	, LastExcDate, LastExcValue, RampOutDate, RampOutValue
				--	, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
				--	, MinValue, MaxValue, AvergValue, StdDevValue
				--	, DeprecatedDate, ThresholdDuration, SetPoint
				--	)
				--SELECT 
				--	RowId, TagId, TagName, TagExcNbr, StageDateId, @StepLogId as StepLogId
				--	, RampInDate, RampInValue, FirstExcDate, FirstExcValue
				--	, LastExcDate, LastExcValue, RampOutDate, RampOutValue
				--	, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
				--	, MinValue, MaxValue, AvergValue, StdDevValue
				--	, DeprecatedDate, ThresholdDuration, SetPoint
				--	FROM @ExcPoints
				--	WHERE RowId = @pvtExcIx;

			--IF (@pivotReturnValue = 0 AND EXISTS(SELECT * FROM @ExcPoints)) BEGIN
			--	UPDATE @ExcPoints Set TagId = @TagId, StageDateId = @CurrStageDateId;
			--	DECLARE @CycleId int, @LastExcDate datetime, @LastExcValue float, @RampOutDate datetime, @RampOutValue float
			--	, @HiPointsCt int, @LowPointsCt int
			--	, @MinValue float, @MaxValue float, @AvergValue float, @StdDevValue float;
			--	-- Get latest result from spPivot into variables
			--	SELECT TOP 1 @CycleId = CycleId
			--	, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue
			--	, @HiPointsCt = HiPointsCt, @LowPointsCt = LowPointsCt
			--	, @MinValue = MinValue, @MaxValue = MaxValue, @AvergValue = AvergValue, @StdDevValue = StdDevValue
			--	FROM @ExcPoints;
			--	UPDATE @ExcPoints SET DeprecatedDate = @DeprecatedDate;
			--	IF (@CycleId < 0) BEGIN
			--	UPDATE @ExcPoints SET ThresholdDuration = @ThresholdDuration, SetPoint = @SetPoint;
			--	PRINT 'Insert Excursion Point';  
			--	Insert into ExcursionPoints ( 
			--		TagId, TagName, TagExcNbr, StageDateId, StepLogId
			--		, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			--		, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			--		, HiPointsCt, LowPointsCt, MinThreshold,MaxThreshold
			--		, MinValue, MaxValue, AvergValue, StdDevValue
			--		, DeprecatedDate, ThresholdDuration, SetPoint
			--		)
			--		SELECT TagId, TagName, TagExcNbr, StageDateId, @StepLogId as StepLogId
			--		, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			--		, LastExcDate, LastExcValue, RampOutDate, RampOutValue
			--		, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
			--		, MinValue, MaxValue, AvergValue, StdDevValue
			--		, DeprecatedDate, ThresholdDuration, SetPoint
			--		FROM @ExcPoints;
			--		UPDATE @ExcPoints SET CycleId = SCOPE_IDENTITY();
			--	END
			--	ELSE BEGIN
			--	PRINT CONCAT('Excursion Point updated. CycleId:', @CycleId)
			--	UPDATE ExcursionPoints 
			--		SET LastExcDate = @LastExcDate, LastExcValue = @LastExcValue, RampOutDate = @RampOutDate, @RampOutValue = RampOutValue
			--		, HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt, DeprecatedDate = DeprecatedDate, StepLogId = @StepLogId
			--		, MinValue = @MinValue, MaxValue = @MaxValue, AvergValue = @AvergValue, StdDevValue = @StdDevValue
			--		WHERE CycleId = @CycleId;
			--	END
			--	Insert into @ExcPointsOutput
			--	SELECT * FROM @ExcPoints;
			--	DELETE FROM @ExcPoints;
			--END

			--IF (@pivotReturnValue = 0) COMMIT TRAN;
			--ELSE BEGIN 
			--	ROLLBACK TRAN; 
			--	PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ''', @TagName, ''', '''
			--	, ' StageDateId:', @CurrStageDateId 
			--	, FORMAT(@ProcNextStepStartDate, 'yyyy-MM-dd'), ''', ''', FORMAT(@ProcNextStepEndDate, 'yyyy-MM-dd')
			--	, 'ROLLED BACK')
			--END

			-- prepare for next Point's step run
			

END;