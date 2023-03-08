/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 03/07/2023 00:12:30 ******/
DROP PROCEDURE [dbo].[spDriverExcursionsPointsForDate]
GO
/****** Object:  StoredProcedure [dbo].[spDriverExcursionsPointsForDate]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
	-- Add the parameters for the stored procedure here
	@ForDate datetime, -- Processing date
	@StageDateId int = null,
	@TagName varchar(255) = NULL -- StageDateId is enough but pass TagName for better performance. 

AS
BEGIN
PRINT '>>> spDriverExcursionsPointsForDate begins'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRAN;

		-- find all (or selected by StageDateId) StagesLimitsAndDates (STADs) left join with PointsPaces
		-- default PointsPaces will be assigned to STADs that don't have one.
		IF (@StageDateId IS NULL AND @TagName IS NULL) 
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
			FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL;
		ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])			
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
			FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL AND sld.StageDateId = @StageDateId;
		ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays 
			FROM [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL AND sld.TagName = @TagName;
		ELSE
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
			from [dbo].[StagesLimitsAndDates] as sld LEFT JOIN PointsPaces as PPs ON sld.StageDateId = PPs.StageDateId
			WHERE PPs.PaceId IS NULL AND sld.TagName = @TagName AND sld.StageDateId = @StageDateId;

	
	--spCreateSteps
	-- iterate all PointsPaces or just the ones associated with input StageDateId.
	-- Iterate ends when PointsPaces' end date exceeds ForDate
	-- each iteration creates associated PointsStepsLog
	-- insert into [dbo].[PointsStepsLog]

	DECLARE  @PointsStepsLog TABLE ( [StepLogId] [int] NULL,
	[StageDateId] [int] NOT NULL, [StageName] [nvarchar](255) NOT NULL, [TagId] [int] NOT NULL, [TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL, [StageEndDate] [datetime] NULL, [MinThreshold] [float] NOT NULL, [MaxThreshold] [float] NOT NULL,
	[PaceId] [int] NOT NULL, [PaceStartDate] [datetime] NOT NULL, [PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL, [EndDate] [datetime] NULL, [ThresholdDuration] int NULL, SetPoint float NULL
	);



	IF (@StageDateId IS NULL AND @TagName IS NULL) 
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId
	ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.TagName = @TagName
	ELSE
		INSERT INTO @PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId AND nxt.TagName = @TagName



	INSERT INTO [dbo].[PointsStepsLog] ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint])
	SELECT [StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinThreshold], [MaxThreshold], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate], [ThresholdDuration], [SetPoint] 
	FROM @PointsStepsLog;

	--spProcessSteps
	-- each iteration populates excursionPoints
	-- iterations should be under the context of a transaction.
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
	DECLARE @stTagId int, @stTagName varchar(255), @stStepLogId int
	, @stMinThreshold float, @stMaxThreshold float, @stStartDate as datetime, @stEndDate as datetime
	, @stThresholdDuration int, @stSetPoint float;
	DECLARE stepsCsr CURSOR 
	FOR SELECT psl.TagId, psl.TagName, psl.StepLogId, psl.MinThreshold, psl.MaxThreshold, psl.StartDate, psl.EndDate, psl.ThresholdDuration, psl.SetPoint 
		FROM PointsStepsLog as psl
		WHERE psl.PaceId in (SELECT vpsl.PaceId From @PointsStepsLog as vpsl);
	OPEN stepsCsr;
	FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinThreshold, @stMaxThreshold
	, @stStartDate, @stEndDate, @stThresholdDuration, @stSetPoint;
	WHILE @@FETCH_STATUS = 0 BEGIN
		--PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ' + Convert(varchar(16), @stTagId) + Convert(varchar(16), @stStepLogId) +  '''',@stTagName, ''', '''
		--, FORMAT(@stStartDate, 'yyyy-MM-dd'), ''', ''', CONVERT(varchar(255), @stEndDate, 126), ''', '
		--, CONVERT(varchar(255), @stMinThreshold), ', ', CONVERT(varchar(255), @stMaxThreshold)
		--);
		INSERT INTO @ExcPoints
		EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @stStartDate, @stEndDate, @stMinThreshold, @stMaxThreshold
		, @stTagId, @stStepLogId, @stThresholdDuration, @stSetPoint;

		FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinThreshold, @stMaxThreshold
		, @stStartDate, @stEndDate, @stThresholdDuration, @stSetPoint;
	END;
	CLOSE stepsCsr;
	DEALLOCATE stepsCsr;

	IF EXISTS (SELECT PaceId FROM @PointsStepsLog) BEGIN
		-- Create a new PointsPaces row for next iteration
		INSERT INTO PointsPaces (StageDateId, NextStepStartDate, StepSizeDays)
		SELECT pps.StageDateId, pps.NextStepEndDate as NextStepStartDate, pps.StepSizeDays 
		FROM PointsPaces as pps
		WHERE pps.ProcessedDate IS NULL;
		-- Update PointsPaces's row that was processed
		UPDATE dbo.PointsPaces 
		SET  ProcessedDate = GetDate()
		WHERE PaceId IN (SELECT PaceId FROM @PointsStepsLog) AND ProcessedDate IS NULL;

	END

	SELECT * FROM @ExcPoints;

	COMMIT TRAN;

-- UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-01';
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2222-11-01';
--SELECT * FROM [dbo].[PointsStepsLog];
--DELETE FROM [dbo].[PointsStepsLog];
PRINT 'spDriverExcursionsPointsForDate ends <<<'

END;
GO
