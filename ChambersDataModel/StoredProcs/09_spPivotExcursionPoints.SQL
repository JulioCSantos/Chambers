CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (	
	  @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
	, @LowThreashold float, @HiThreashold float 
	, @ThresholdDuration int = null, @SetPoint float = null
)
AS
BEGIN
PRINT '>>> spPivotExcursionPoints begins'
PRINT CONCAT('INPUT: @TagName:',@TagName, ' @StartDate:', @StartDate, ' @EndDate:', @EndDate
		, ' @ThresholdDuration:', @ThresholdDuration, ' @SetPoint:', @SetPoint);

	--Declare input cursor values
	DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 1; 
	DECLARE @IsHiExc int = -1;

	-- Currently in-process Excursion in date range for Tag (TagName)
	DECLARE @ExcPoint1 as TABLE ( ExcPriority int, 
			TagName varchar(255), TagExcNbr int
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
	DECLARE @ExcPoints as TABLE ( ExcPriority int,
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  
			, LowThreashold float, HiThreashold float
			, MinValue float, MaxValue float
			, AvergValue float, StdDevValue float
			, ThresholdDuration int, SetPoint float);
	DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
	DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
	DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
	DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
	DECLARE @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	PRINT 'GET LAST Excursion or Empty (start up) Excursion row'
	INSERT INTO @ExcPoint1 (ExcPriority, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
		, HiPointsCt, LowPointsCt, LowThreashold, HiThreashold
		, MinValue, MaxValue, AvergValue, StdDevValue
		, ThresholdDuration, SetPoint)
		SELECT TOP 1 ExcPriority, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
		, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
		, MinValue, MaxValue, AvergValue, StdDevValue
		, ThresholdDuration, SetPoint
		FROM (
			-- get last incomplete Excursion (RampIn only) if one exists
			SELECT TOP 1 3 as ExcPriority, TagName, TagExcNbr, RampInDate, RampInValue, FirstExcDate, FirstExcValue
			, HiPointsCt, LowPointsCt, MinThreshold, MaxThreshold
			, NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
			, 120 as ThresholdDuration, 150 as SetPoint FROM [dbo].[ExcursionPoints] 
			WHERE TagName = @TagName AND RampOutDate is NULL
			ORDER BY TagName, TagExcNbr Desc
			UNION ALL
			-- get completed Excursion (RampIn and RampOut populated) if one exists
			SELECT TOP 1 2 as ExcPriority, TagName, TagExcNbr, NULL as RampInDate, NULL as RampInValue, NULL as FirstExcDate, NULL as FirstExcValue
			, 0 as HiPointsCt, 0 as LowPointsCt, 100 as MinThreshold, 200 as MaxThreshold
			, NULL as MinValue, NULL as MaxValue, NULL as AvergValue, NULL as StdDevValue
			, 120 as ThresholdDuration, 150 as SetPoint FROM [dbo].[ExcursionPoints] 
			WHERE TagName = @TagName AND RampInDate is NOT NULL AND RampOutDate is NOT NULL
			ORDER BY TagName, TagExcNbr Desc
			UNION ALL
			SELECT 1 as ExcPriority, @TagName as TagName, 1 as TagExcNbr, NULL, NULL, NULL, NULL
			, 0, 0, 100, 200
			, NULL, NULL, NULL, NULL
			, 120, 150
			) as allExc
		ORDER BY ExcPriority DESC;

	PRINT '@TagExcNbr to latest (or empty) Excursion number'
	DECLARE @ExcPriority int;
	SELECT  @ExcPriority = ExcPriority, @TagExcNbr = TagExcNbr
	, @RampInDate = RampInDate, @RampInValue = RampInValue, @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue
	, @RampOutDate = RampOutDate, @RampOutValue = RampOutValue, @LastExcDate = LastExcDate, @LastExcValue = LastExcValue
	, @LowPointsCt = LowPointsCt, @HiPointsCt = HiPointsCt
	FROM @ExcPoint1;
	IF (@ExcPriority = 3) BEGIN
		IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
		ELSE SET @IsHiExc = 0;
		PRINT Concat('IsHiExc: ', @IsHiExc);
	END
	IF (@ExcPriority = 2) BEGIN
		SET @TagExcNbr = @TagExcNbr + 1;
		UPDATE @ExcPoint1 SET TagExcNbr = @TagExcNbr;
	END



	--FOR SELECT [tag], [time], [value] from  PI.piarchive..picomp
	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName 
		AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

	OPEN CPoint;
	FETCH NEXT FROM CPoint INTO @tag, @time, @value;
	PRINT Concat('First Excursion point: @time:', @time,' @Value:', @value);

	PRINT 'Loop through Excursion points in the time period if any'
	WHILE @@FETCH_STATUS = 0  BEGIN
			
		IF (@FirstExcDate IS NULL) BEGIN
			PRINT 'Get First Excursion Point'
			UPDATE @ExcPoint1 SET FirstExcDate = @time, FirstExcValue = @value;
			SELECT TOP 1 @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue FROM @ExcPoint1;
			PRINT 'Determine if cycle is for Hi or Low Excursion'
			IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
			ELSE SET @IsHiExc = 0;
			PRINT Concat('IsHiExc: ', @IsHiExc);
		END

		PRINT 'Increase Excursion Counter'
		IF (@IsHiExc = 1) SET @HiPointsCt = @HiPointsCt + 1;
		ELSE SET @LowPointsCt = @LowPointsCt + 1;
		UPDATE @ExcPoint1 SET HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt;

		IF (@FirstExcDate IS NOT NULL AND @RampInDate IS NULL) BEGIN
			PRINT 'Find RampIn point'
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time <= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Desc;
			IF (@RampInDate IS NOT NULL) BEGIN
				UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
				PRINT Concat('RampIn point: RampInDate:', @RampInDate,' RampInValue:', @RampInValue);
			END
		END
		
		IF (@RampOutDate IS NULL) BEGIN
			PRINT 'Find RampOut point'
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName 
				AND time >= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss') 
				AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') -- cant go beyond invoked date range or future ExPs will be compromised
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Asc;
			IF (@RampOutDate IS NOT NULL) BEGIN 
				UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
				PRINT Concat('RampOut point: RampOutDate:', @RampOutDate,' RampOutValue:', @RampOutValue);
			END
		END

		--PRINT 'Get RampOut point'
		--IF (@RampOutDate IS NULL AND @LastExcDate IS NOT NULL ) BEGIN
		--	SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
		--	WHERE tag = @TagName AND time >= FORMAT(@LastExcDate,'yyyy-MM-dd HH:mm:ss') 
		--		AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
		--	ORDER BY time Asc;
		--	IF (@RampOutDate IS NOT NULL) BEGIN 
		--		UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
		--	END
		--END

		PRINT 'keep updating Last Excursion point (until the end) if RampOut is found and is within date range'
		IF (@RampOutDate IS NOT NULL AND @RampOutDate < @EndDate) BEGIN
			UPDATE @ExcPoint1 SET LastExcDate = @time, LastExcValue = @value;
			SELECT TOP 1 @LastExcDate = LastExcDate, @LastExcValue = LastExcValue FROM @ExcPoint1;
			PRINT CONCAT('Last Excursion Point: @LastExcDate:', @LastExcDate,' @LastExcValue:', @LastExcValue);
		END


		FETCH NEXT FROM CPoint INTO @tag, @time, @value; 
		PRINT Concat('Next Excursion point: @time:',@time ,' @Value:', @Value);

		PRINT 'Set up a new Excursion Cycle if ..'
		PRINT '.. Next Excursion date is after RampOut date or ..'
		PRINT '.. Excursion type changed from Hi to Low or vice-versa'
		IF (@@FETCH_STATUS = 0 ) BEGIN
			IF (@time >= @RampOutDate OR (@IsHiExc = 1 AND @value < @HiThreashold) OR (@IsHiExc = 0 AND @value >= @LowThreashold) ) BEGIN
				PRINT 'Finalize Current Excursion to process up coming newer Excursion'
				PRINT 'Update aggregated values (Min, Max, Averg, StdDev) if full Excursion found'
				IF (@RampInDate IS NOT NULL AND @RampOutDate IS NOT NULL) BEGIN
					PRINT 'Update aggregated values'
					DECLARE @OMinValue float, @OMaxValue float, @OAvergValue float, @OStdDevValue float;
					EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
						, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
						, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
					UPDATE @ExcPoint1 SET MinValue = @OMinValue, MaxValue = @OMaxValue
							, AvergValue = @OAvergValue, StdDevValue = @OStdDevValue;
				END

				PRINT 'Save Current Excursion and prepare for Next'
				INSERT INTO @ExcPoints Select * FROM @ExcPoint1;
				DELETE FROM @ExcPoint1;
				SET @TagExcNbr = @TagExcNbr + 1;
				SET @RampInDate = NULL; SET @RampInValue = NULL; SET @FirstExcDate = NULL; SET @FirstExcValue = NULL;
				SET @LastExcDate = NULL; SET @LastExcValue = NULL; SET @RampOutDate = NULL; SET @RampOutValue = NULL;
				SET @HiPointsCt = 0; SET @LowPointsCt = 0;
				INSERT INTO @ExcPoint1 VALUES (0, @TagName, @TagExcNbr
					, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
					, @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold, NULL, NULL
					, NULL, NULL, @ThresholdDuration, @SetPoint);
			END
		END
	END;

	CLOSE CPoint;
	DEALLOCATE CPoint;
	
	PRINT 'finalize LAST Excursion in date range (end of cursor)'
		IF (@RampInDate IS NOT NULL AND @RampOutDate IS NOT NULL) BEGIN
		PRINT 'Update aggregated values'
		EXECUTE dbo.spGetStats @TagName, @FirstExcDate, @LastExcDate
			, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT
			, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
		UPDATE @ExcPoint1 SET MinValue = @OMinValue, MaxValue = @OMaxValue
				, AvergValue = @OAvergValue, StdDevValue = @OStdDevValue;
	END
	PRINT 'Save LAST Excursion in date range (end of cursor)'
	INSERT INTO @ExcPoints Select * FROM @ExcPoint1;

	SELECT 
	  [TagName], [TagExcNbr]
	  , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
	  , [HiPointsCt], [LowPointsCt], @LowThreashold as [MinThreshold], @HiThreashold as [MaxThreshold]
	  , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
	  , [ThresholdDuration], [SetPoint]
	FROM @ExcPoints 
	WHERE (HiPointsCt > 0 OR LowPointsCt > 0) AND RampInDate IS NOT NULL;

-- UNIT TESTS
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
--		, @LowThreashold = 100, @HiThreashold = 200;
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-05'
--		, @LowThreashold = 100, @HiThreashold = 200;
PRINT 'spPivotExcursionPoints ends <<<'

END