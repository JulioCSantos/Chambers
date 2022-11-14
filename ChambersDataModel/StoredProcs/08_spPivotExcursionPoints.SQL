CREATE PROCEDURE [dbo].[spPivotExcursionPoints] (	
	  @TagName varchar(255), @StartDate DateTime, @EndDate DateTime
	, @LowThreashold float, @HiThreashold float 
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
			, HiPointsCt int, LowPointsCt int  );
	DECLARE @ExcPoints as TABLE ( 
			TagName varchar(255), TagExcNbr int
			, RampInDate DateTime, RampInValue float
			, FirstExcDate DateTime, FirstExcValue float
			, LastExcDate DateTime, LastExcValue float
			, RampOutDate DateTime, RampOutValue float
			, HiPointsCt int, LowPointsCt int  );
	DECLARE @RampInDate DateTime = NULL, @RampInValue float = NULL;
	DECLARE @FirstExcDate DateTime = NULL, @FirstExcValue float = NULL;
	DECLARE @LastExcDate DateTime = NULL, @LastExcValue float = NULL;
	DECLARE @RampOutDate DateTime = NULL, @RampOutValue float = NULL;
	DECLARE  @HiPointsCt int = 0, @LowPointsCt int = 0; --Declare output counter values

	PRINT 'GET initial TagExcNbr'
	SELECT TOP 1 @TagExcNbr = ISNULL(TagExcNbr,0) + 1 FROM [dbo].[ExcursionPointsNew] 
		WHERE TagName = @TagName
		ORDER BY TagName, TagExcNbr Desc
	PRINT 'Create Output record'
	INSERT INTO @ExcPoint1 VALUES (@TagName, @TagExcNbr
	, NULL, NULL -- RampIn
	, NULL, NULL -- FirstExc
	, NULL, NULL -- LastExc
	, NULL, NULL -- RampOut
	, @HiPointsCt, @LowPointsCt);

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

	OPEN CPoint;
	PRINT Concat('Fetch First Excursion point. Value ', @Value);
	FETCH NEXT FROM CPoint INTO @tag, @time, @value;

	PRINT 'Loop through Excursion points in the time period if any'
	WHILE @@FETCH_STATUS = 0  BEGIN
			
		IF (@FirstExcDate IS NULL) BEGIN
			PRINT 'Get First Excursion Point'
			UPDATE @ExcPoint1 SET FirstExcDate = @time, FirstExcValue = @value;
			SELECT TOP 1 @FirstExcDate = FirstExcDate, @FirstExcValue = FirstExcValue FROM @ExcPoint1;
			PRINT 'Determine if cycle is for Hi or Low Excursion'
			IF (@FirstExcValue >= @HiThreashold) SET @IsHiExc = 1;
			ELSE SET @IsHiExc = 0;
		END

		PRINT 'Increase Excursion Counter'
		IF (@IsHiExc = 1) SET @HiPointsCt = @HiPointsCt + 1;
		ELSE SET @LowPointsCt = @LowPointsCt + 1;
		UPDATE @ExcPoint1 SET HiPointsCt = @HiPointsCt, LowPointsCt = @LowPointsCt;

		IF (@FirstExcDate IS NOT NULL AND @RampInDate IS NULL) BEGIN
			PRINT 'Get RampIn point'
			SELECT TOP 1 @RampInDate = [time], @RampInValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time <= @FirstExcDate 
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Desc;
			IF (@RampInDate IS NOT NULL) UPDATE @ExcPoint1 SET RampInDate = @RampInDate, RampInValue = @RampInValue;
		END

		PRINT 'Always Reset Last Excursion Point until end of cursor'
		UPDATE @ExcPoint1 SET LastExcDate = @time, LastExcValue = @value;
		SELECT TOP 1 @LastExcDate = LastExcDate, @LastExcValue = LastExcValue FROM @ExcPoint1;

		PRINT 'Get RampOut point'
		IF (@RampOutDate IS NULL AND @LastExcDate IS NOT NULL ) BEGIN
			SELECT TOP 1 @RampOutDate = [time], @RampOutValue =  [value] FROM  [dbo].[CompressedPoints]
			WHERE tag = @TagName AND time >= @LastExcDate 
				AND ((@IsHiExc = 1 AND value < @HiThreashold) OR (@IsHiExc = 0 AND value > @LowThreashold ))
			ORDER BY time Asc;
			IF (@RampOutDate IS NOT NULL) UPDATE @ExcPoint1 SET RampOutDate = @RampOutDate, RampOutValue = @RampOutValue;
		END

		PRINT Concat('Next High Excursion point. Value ', @Value);
		FETCH NEXT FROM CPoint INTO @tag, @time, @value; 

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
					, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, @HiPointsCt, @LowPointsCt);
			END
		END
	END;

	CLOSE CPoint;
	DEALLOCATE CPoint;
	
	INSERT INTO @ExcPoints Select * FROM @ExcPoint1;

	PRINT 'RETURN ALL Full Excursion Cycles'
	SELECT * FROM @ExcPoints WHERE HiPointsCt > 0 OR LowPointsCt > 0;
END