CREATE PROCEDURE MergeIncompleteCycles 
	---- Add the parameters for the stored procedure here
	--@p1 int = 0, 
	--@p2 int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE  @RampInResults TABLE ( CycleId int, RampInDate DateTime NULL, RampInValue float, LowPointsCt int, HiPointsCt int);
	DECLARE  @RampOutResults TABLE ( CycleId int, TagName varchar(255), TagExcNbr int, RampInDate DateTime NULL, RampInValue float
	, RampOutDate DateTime NULL, LowPointsCt int, HiPointsCt int);
	DECLARE @OCycleId int, @OTagName varchar(255), @OTagExcNbr int, @OPrevTagExcNbr int, @ORampOutDate datetime, @OLowPointsCt int, @OHiPointsCt int;
	DECLARE RampOutCyclesCsr CURSOR 
	FOR SELECT CycleId,  TagName, TagExcNbr, ISNULL((lag(TagExcNbr,1) OVER (ORDER BY TagName)),0)
		, RampOutDate, LowPointsCt, HiPointsCt 
		FROM [dbo].[ExcursionPoints]
		WHERE RampInDate is null AND RampOutDate is NOT NULL;
	OPEN RampOutCyclesCsr;
	-- Fetch next RampOut Cycle row
	FETCH NEXT FROM RampOutCyclesCsr INTO @OCycleId, @OTagName, @OTagExcNbr, @OPrevTagExcNbr, @ORampOutDate, @OLowPointsCt, @OHiPointsCt;

	WHILE @@FETCH_STATUS = 0 BEGIN

		-- Get RampIn (and Intermediate) Cycles' rows 
		DELETE @RampInResults;
		INSERT INTO @RampInResults
		SELECT CycleId,  RampInDate, RampInValue, LowPointsCt, HiPointsCt 
			FROM [dbo].[ExcursionPoints] 
		WHERE TagName = @OTagName and TagExcNbr > @OPrevTagExcNbr and TagExcNbr < @OTagExcNbr;

		-- Compute RampIn's datetime and value and Points High and Low Count
		DECLARE  @GRampInDate DateTime, @GRampInValue float, @GLowPointsCt int, @GHiPointsCt int;
		SELECT @GRampInDate = MIN(RampInDate), @GRampInValue= Min(RampInValue), @GLowPointsCt = SUM(LowPointsCt), @GHiPointsCt = SUM(HiPointsCt) FROM @RampInResults;

		-- Update the RampOut Cycle row
		UPDATE [dbo].[ExcursionPoints]
		SET RampInDate = @GRampInDate, RampInValue = @GRampInValue, LowPointsCt = @OLowPointsCt + @GLowPointsCt, HiPointsCt =  @OHiPointsCt + @GHiPointsCt
		WHERE CycleId = @OCycleId;

		-- Save the updated RampOut cycle in RampOutResults
		INSERT INTO @RampOutResults
		SELECT CycleId , TagName , TagExcNbr , RampInDate , RampInValue, RampOutDate , LowPointsCt , HiPointsCt  
		FROM [dbo].[ExcursionPoints] WHERE CycleId = @OCycleId;

		-- Clear used RampIn (and Intermediate) Cycles' rows
		DELETE FROM [dbo].[ExcursionPoints] WHERE CycleId IN (SELECT CycleId FROM @RampInResults)

		-- Fetch next RampOut Cycle row
		FETCH NEXT FROM RampOutCyclesCsr INTO @OCycleId, @OTagName, @OTagExcNbr, @OPrevTagExcNbr, @ORampOutDate, @OLowPointsCt, @OHiPointsCt;
	END
	CLOSE RampOutCyclesCsr;
	DEALLOCATE RampOutCyclesCsr;
		

    -- Insert statements for procedure here
	SELECT * FROM @RampOutResults;
END
GO