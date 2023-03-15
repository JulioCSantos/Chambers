/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 3/14/2023 11:46:39 AM ******/
DROP PROCEDURE [dbo].[spDriverExcursionsPointsForDate]
GO
/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 3/14/2023 11:46:39 AM ******/
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
	
	-- Processing StageDates
	DECLARE @StageDateIdsTable TABLE (StageDateId int);
	IF (@StageDateIds IS NOT NULL) BEGIN
		INSERT INTO @StageDateIdsTable
		SELECT cast(DATA as int) from dbo.fnSplit(@StageDateIds, ',')
	END;

	-- Processing Tag details
	DECLARE @StagesLimitsAndDatesCore TABLE (
		TagId int, TagName nvarchar(255), StageDateId int, StageName nvarchar(255) NULL
		, MinThreshold float, MaxThreshold float, StartDate datetime, EndDate datetime
		, TimeStep float null, StageId int, ThresholdDuration int NULL, SetPoint float NULL
		, StageDeprecatedDate datetime NULL, StageDateDeprecatedDate datetime NULL
		, ProductionDate datetime NULL, IsDeprecated int 
	)

	INSERT INTO @StagesLimitsAndDatesCore
	SELECT TagId, TagName, StageDateId, StageName 
		, MinThreshold, MaxThreshold, StartDate, EndDate
		, TimeStep, StageId, ThresholdDuration, SetPoint 
		, StageDeprecatedDate, StageDateDeprecatedDate 
		, ProductionDate, IsDeprecated 
		FROM [dbo].[StagesLimitsAndDatesCore]
		WHERE (@StageDateIds IS NULL OR StageDateId in (SELECT StageDateId From @StageDateIdsTable));

	DECLARE @ExcPoints as TABLE ( TagId int NULL
	, TagName varchar(255), TagExcNbr int NULL
	, StepLogId int NULL
	, RampInDate DateTime NULL, RampInValue float NULl
	, FirstExcDate DateTime NULL, FirstExcValue float NULL
	, LastExcDate DateTime NULL, LastExcValue float NULL
	, RampOutDate DateTime NULL, RampOutValue float NULL
	, HiPointsCt int NULL, LowPointsCt int NULL
	, MinThreshold float NULL, MaxThreshold float NULL
	, MinValue float, MaxValue float
	, AvergValue float, StdDevValue float
	, ThresholdDuration int, SetPoint float);

	-- If no Tag details found abort (details are not configured).
	IF (NOT EXISTS(SELECT * FROM @StagesLimitsAndDatesCore)) BEGIN
		PRINT '<<< spDriverExcursionsPointsForDate aborted';
		SELECT * FROM @ExcPoints;
		RETURN;
	END;

	DECLARE @PointsPacesTbl TABLE (
		RowID int not null primary key identity(1,1)
		, PaceId int, StageDateId int, NextStepStartDate datetime, StepSizeDays int, NextStepEndDate datetime, ProcessedDate datetime NULL
	  );

	-- 
	INSERT INTO @PointsPacesTbl (PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate)
	SELECT PaceId, StageDateId, NextStepStartDate, StepSizeDays, NextStepEndDate, ProcessedDate 
	FROM [dbo].[PointsPaces]
	WHERE (@StageDateIds IS NULL OR StageDateId in (SELECT StageDateId From @StageDateIdsTable))
	AND ProcessedDate IS NULL;
	
	--
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
		BEGIN TRAN;
		PRINT 'PROCESS Tag through the date date range'
		WHILE @StepEndDate < @ToDate BEGIN
			PRINT Concat('@CurrStageDateId:', @CurrStageDateId, ' @StepStartDate:', @StepStartDate,' @StepEndDate:', @StepEndDate);

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

			INSERT INTO @ExcPoints
			EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @StepStartDate, @StepEndDate, @stMinThreshold, @stMaxThreshold
				, @stTagId, @stStepLogId, @stThresholdDuration, @stSetPoint;

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

		END

		-- Last PointsPace row of the date range
		INSERT INTO [dbo].[PointsPaces] ([StageDateId],[NextStepStartDate],[StepSizeDays],[ProcessedDate])
		VALUES (@CurrStageDateId, @StepStartDate, @StepSizedays, NULL ); 

		COMMIT TRAN;


		SELECT * FROM @ExcPoints;

	END

	--UNIT TESTS
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', NULL
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', '15,14'
	--EXEC [dbo].[spDriverExcursionsPointsForDate] '2023-03-01', '2023-03-31', 12341234

PRINT 'spDriverExcursionsPointsForDate ends <<<'

END;

GO
