CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
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
	, StepLogId int NULL
	, RampInDate DateTime NULL, RampInValue float NULL, FirstExcDate DateTime NULL, FirstExcValue float NULL
	, LastExcDate DateTime NULL, LastExcValue float NULL, RampOutDate DateTime NULL, RampOutValue float NULL
	, HiPointsCt int NULL, LowPointsCt int NULL, MinThreshold float NULL, MaxThreshold float NULL
	, MinValue float, MaxValue float, AvergValue float, StdDevValue float
	, ThresholdDuration int, SetPoint float);

	DECLARE @ExcPointsOutput as TABLE ( CycleId int, TagId int NULL
	, TagName varchar(255), TagExcNbr int NULL
	, StepLogId int NULL
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

			INSERT INTO @ExcPoints (
				[CycleId], [TagName], [TagExcNbr]
			  , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
			  , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
			  , [HiPointsCt], [LowPointsCt], [MinThreshold], [MaxThreshold]
			  , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
			  , [ThresholdDuration], [SetPoint]
			)
			EXECUTE [dbo].[spPivotExcursionPoints] @TagName, @ProcNextStepStartDate, @ProcNextStepEndDate
				, @MinThreshold, @MaxThreshold, @ThresholdDuration, @SetPoint;

			IF (EXISTS(SELECT * FROM @ExcPoints)) BEGIN
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

			-- Update or insert PointsPaces row
			IF (@PaceId <= 0) BEGIN
				INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
					 VALUES (@CurrStageDateId, @ProcNextStepStartDate, @StepSizedays , GetDate() ); 
			END
			ELSE BEGIN
				UPDATE [dbo].[PointsPaces] SET ProcessedDate = GetDate()
				WHERE PaceId = @PaceId;
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