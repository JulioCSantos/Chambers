CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (	
	  @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
	, @LowThreashold float, @HiThreashold float, @TagId int = null, @StepLogId int = null 
)
AS
BEGIN

	--Declare input cursor values
	DECLARE  @tag varchar(255), @time DateTime, @value float, @TagExcNbr int = 0; 
	DECLARE @IsHiExc int = -1;

	-- Output results
	DECLARE @ExcPoint1 as TABLE ( 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int
			, LowThreashold float, HiThreashold float);
	DECLARE @ExcPoints as TABLE ( 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  
			, LowThreashold float, HiThreashold float);
	DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
	DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
	DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
	DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
	DECLARE @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	PRINT 'GET initial TagExcNbr'
	SELECT TOP 1 @TagExcNbr = ISNULL(TagExcNbr,0) + 1 FROM [dbo].[ExcursionPoints] 
		WHERE TagName = @TagName
		ORDER BY TagName, TagExcNbr Desc
	PRINT 'Create Output record'
	INSERT INTO @ExcPoint1 VALUES (@TagName, @TagExcNbr
	, NULL, NULL -- RampIn
	, NULL, NULL -- FirstExc
	, NULL, NULL -- LastExc
	, NULL, NULL -- RampOut
	, @HiPointsCt, @LowPointsCt
	, @LowThreashold, @HiThreashold );

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName 
		AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time < FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

	OPEN CPoint;
	FETCH NEXT FROM CPoint INTO @tag, @time, @value;
	PRINT Concat('First Excursion point. Value ', @time, @Value);

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
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time <= FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Desc;
			IF (@RampInDate IS NOT NULL) UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
			PRINT Concat('RampIn point: RampInDate RampInValue', @RampInDate, @RampInValue);
END

		PRINT 'Always Reset Last Excursion Point until end of cursor'
		UPDATE @ExcPoint1 SET LastExcDate = @time, LastExcValue = @value;
		SELECT TOP 1 @LastExcDate = LastExcDate, @LastExcValue = LastExcValue FROM @ExcPoint1;
		
		PRINT 'Get RampOut point'
		IF (@RampOutDate IS NULL AND @LastExcDate IS NOT NULL ) BEGIN
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time >= FORMAT(@LastExcDate,'yyyy-MM-dd HH:mm:ss') 
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Asc;
			IF (@RampOutDate IS NOT NULL) UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
		END

		FETCH NEXT FROM CPoint INTO @tag, @time, @value; 
		PRINT Concat('Next Excursion point: time Value ', @time, @Value);

		PRINT 'Set up a new Excursion Cycle if ..'
		PRINT '.. Next Excursion date is after RampOut date or ..'
		PRINT '.. Excursion type changed from Hi to Low or vice-versa'
		IF (@@FETCH_STATUS = 0 ) BEGIN
			IF (@time > @RampOutDate OR (@IsHiExc = 1 AND @value < @HiThreashold) OR (@IsHiExc = 0 AND @value >= @LowThreashold) ) BEGIN
				INSERT INTO @ExcPoints Select * FROM @ExcPoint1;
				DELETE FROM @ExcPoint1;
				SET @TagExcNbr = @TagExcNbr + 1;
				SET @RampInDate = NULL; SET @RampInValue = NULL; SET @FirstExcDate = NULL; SET @FirstExcValue = NULL;
				SET @LastExcDate = NULL; SET @LastExcValue = NULL; SET @RampOutDate = NULL; SET @RampOutValue = NULL;
				SET @HiPointsCt = 0; SET @LowPointsCt = 0;
				INSERT INTO @ExcPoint1 VALUES (@TagName, @TagExcNbr
					, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
					, @HiPointsCt, @LowPointsCt, @LowThreashold, @HiThreashold);
			END
		END
	END;

	CLOSE CPoint;
	DEALLOCATE CPoint;
	
	INSERT INTO @ExcPoints Select * FROM @ExcPoint1;

	INSERT INTO [dbo].[ExcursionPoints]
	SELECT 
	 @TagId as [TagId], [TagName], [TagExcNbr], @StepLogId as [StepLogId], [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      ,[LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue], [HiPointsCt], [LowPointsCt]
	  , @LowThreashold as [MinValue], @HiThreashold as [MaxValue]
	FROM @ExcPoints WHERE HiPointsCt > 0 OR LowPointsCt > 0; -- select only full Excursions
	PRINT 'ALL Excursion Cycles inserted'

	SELECT 
	 @TagId as [TagId], [TagName], [TagExcNbr], @StepLogId as [StepLogId], [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
      ,[LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue], [HiPointsCt], [LowPointsCt]
	  , @LowThreashold as [MinValue], @HiThreashold as [MaxValue]
	FROM @ExcPoints WHERE HiPointsCt > 0 OR LowPointsCt > 0;

-- UNIT TESTS
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-03'
--		, @LowThreashold = 100, @HiThreashold = 200, @TagId = 111, @StepLogId = 222;
--EXEC [dbo].[spPivotExcursionPoints] @TagName = 'chamber_report_tag_1', @StartDate = '2022-11-01', @EndDate = '2022-11-05'
--		, @LowThreashold = 100, @HiThreashold = 200;

END