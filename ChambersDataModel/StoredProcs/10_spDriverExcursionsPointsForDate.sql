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

	DECLARE @PointsStepsLog as TABLE (
	[StageDateId] [int] NOT NULL, [StageName] [nvarchar](255) NOT NULL, [TagId] [int] NOT NULL, [TagName] [varchar](255) NOT NULL,
	[StageStartDate] [datetime] NOT NULL, [StageEndDate] [datetime] NULL, [MinValue] [float] NOT NULL, [MaxValue] [float] NOT NULL,
	[PaceId] [int] NOT NULL, [PaceStartDate] [datetime] NOT NULL, [PaceEndDate] [datetime] NOT NULL,
	[StartDate] [datetime] NULL, [EndDate] [datetime] NULL
	)

	IF (@StageDateId IS NULL AND @TagName IS NULL) 
		INSERT INTO @PointsStepsLog
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
	ELSE IF (@StageDateId Is NOT NULL AND @TagName IS NULL)
		INSERT INTO @PointsStepsLog
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId
	ELSE IF (@StageDateId Is NULL AND @TagName IS NOT NULL)
		INSERT INTO @PointsStepsLog
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.TagName = @TagName
	ELSE
		INSERT INTO @PointsStepsLog
		SELECT * FROM [dbo].[PointsStepsLogNextValues] as nxt
		WHERE nxt.StartDate <= @ForDate AND @ForDate < nxt.EndDate
		AND nxt.StageDateId = @StageDateId AND nxt.TagName = @TagName
	
	INSERT INTO [dbo].[PointsStepsLog]
	SELECT * FROM @PointsStepsLog;

	--spProcessSteps
	-- each iteration populates excursionPoints
	-- iteratations should be under the context of a transaction.

	-- After Transaction completed succesfully update PointsPaces


    -- Insert statements for procedure here

-- UNIT TESTS
--EXEC [dbo].[spDriverExcursionsPointsForDate] @ForDate = '2022-11-01';
--SELECT * FROM [dbo].[PointsStepsLog];
--DELETE FROM [dbo].[PointsStepsLog];
END;