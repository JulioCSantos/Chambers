CREATE PROCEDURE [dbo].[spDriverExcursionsPointsForDate] 
	-- Add the parameters for the stored procedure here
	@ForDate datetime, -- Processing date
	@StageDateId int = null,
	@TagName varchar(255) = NULL -- StageDateId is enough but pass TagName for better performance. 

AS
BEGIN
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
			INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])			SELECT sld.StageDateId, DATEADD(month, -1, GETDATE()) as NextStepStartDate, 2 as StepSizeDays
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

	CREATE TABLE #PointsStepsLog ( [StepLogId] int IDENTITY(1,1) NOT NULL,
	[StageDateId] [int] NOT NULL, [StageName] [nvarchar](255) NOT NULL, [TagId] [int] NOT NULL, [TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL, [StageEndDate] [datetime] NULL, [MinValue] [float] NOT NULL, [MaxValue] [float] NOT NULL,
	[PaceId] [int] NOT NULL, [PaceStartDate] [datetime] NOT NULL, [PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL, [EndDate] [datetime] NULL
	);

	DECLARE @lastStepLogId int;
	SELECT @lastStepLogId = ISNULL(IDENT_CURRENT('dbo.PointsStepsLog'), 1) + 1;
	DBCC CHECKIDENT (#PointsStepsLog, RESEED, @lastStepLogId);


	--SET IDENTITY_INSERT #PointsStepsLog OFF;
	IF (@StageDateId IS NULL AND @TagName IS NULL) 
		INSERT INTO #PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinValue], [MaxValue], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
		INSERT INTO #PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinValue], [MaxValue], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId
	ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
		INSERT INTO #PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinValue], [MaxValue], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.TagName = @TagName
	ELSE
		INSERT INTO #PointsStepsLog ([StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinValue], [MaxValue], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId AND nxt.TagName = @TagName

	--SET IDENTITY_INSERT #PointsStepsLog OFF;

	--DECLARE @lastStepLogId int;
	--SELECT @lastStepLogId = ISNULL(MAX(StepLogId), 1) FROM [dbo].[PointsStepsLog];
	--UPDATE #PointsStepsLog SET StepLogId = StepLogId + @lastStepLogId;

	SET IDENTITY_INSERT [dbo].[PointsStepsLog] ON;
	--INSERT INTO [dbo].[PointsStepsLog] 
	--SELECT * FROM #PointsStepsLog;
	INSERT INTO [dbo].[PointsStepsLog] ([StepLogId], [StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinValue], [MaxValue], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate])
	SELECT [StepLogId], [StageDateId], [StageName], [TagId], [TagName], [StageStartDate], [StageEndDate]
		, [MinValue], [MaxValue], [PaceId], [PaceStartDate], [PaceEndDate], [StartDate], [EndDate] 
	FROM #PointsStepsLog;
	SET IDENTITY_INSERT [dbo].[PointsStepsLog] OFF;

	--spProcessSteps
	-- each iteration populates excursionPoints
	-- iterations should be under the context of a transaction.
	DECLARE @stTagId int, @stTagName varchar(255), @stStepLogId int
	, @stMinValue float, @stMaxValue float, @stStartDate as datetime, @stEndDate as datetime;
	DECLARE stepsCsr CURSOR FORWARD_ONLY 
	FOR SELECT psl.TagId, psl.TagName, psl.StepLogId, psl.MinValue, psl.MaxValue, psl.StartDate, psl.EndDate FROM #PointsStepsLog as psl;
	OPEN stepsCsr;
	FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinValue, @stMaxValue, @stStartDate, @stEndDate;
	WHILE @@FETCH_STATUS = 0 BEGIN
		PRINT CONCAT('EXECUTE [dbo].[spPivotExcursionPoints] ' + Convert(varchar(16), @stTagId) + Convert(varchar(16), @stStepLogId) +  '''',@stTagName, ''', '''
		, FORMAT(@stStartDate, 'yyyy-MM-dd'), ''', ''', CONVERT(varchar(255), @stEndDate, 126), ''', '
		, CONVERT(varchar(255), @stMinValue), ', ', CONVERT(varchar(255), @stMaxValue)
		);
		EXECUTE [dbo].[spPivotExcursionPoints] @stTagName, @stStartDate, @stEndDate, @stMinValue, @stMaxValue, @stTagId, @stStepLogId;

		FETCH NEXT FROM stepsCsr INTO @stTagId, @stTagName, @stStepLogId, @stMinValue, @stMaxValue, @stStartDate, @stEndDate;
	END;
	CLOSE stepsCsr;
	DEALLOCATE stepsCsr;

	-- Update PointsPaces to next iteration
	UPDATE dbo.PointsPaces 
	SET  NextStepStartDate = NextStepEndDate
	WHERE PaceId IN (SELECT PaceId FROM #PointsStepsLog);

	COMMIT TRAN;

-- UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-01';
--SELECT * FROM [dbo].[PointsStepsLog];
--DELETE FROM [dbo].[PointsStepsLog];
END;