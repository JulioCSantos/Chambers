CREATE PROCEDURE [dbo].[spGetCompressedPoints] 
(	
	-- Add the parameters for the function here
	  @TagName varchar(255)
	, @StartDate DateTime 
	, @EndDate DateTime
	, @LowThreashold float
	, @HiThreashold float 
)
AS
BEGIN
DECLARE @ExcNbr int = 0
, @RampOut varchar(16) = 'RampOut' 
, @RampIn varchar(16) = 'RampIn' ;

DECLARE @FullExcCycle as TABLE ( ExcNbr int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE @ExcPoints as TABLE ( ExcNbr int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampOutPoints as TABLE ( ExcNbr int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampInPoints as TABLE ( ExcNbr int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE  @tag varchar(255), @time DateTime, @value float;
DECLARE  @ROtime DateTime, @HiOrLow varchar(16);

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate 
		AND (value >= @HiThreashold OR value < @LowThreashold)
		ORDER BY time;

		SET @ExcNbr = @ExcNbr + 1;
		OPEN CPoint;
		PRINT 'Fetch first Excursion point'
		FETCH NEXT FROM CPoint INTO @tag, @time, @value;

		PRINT 'Determine if it is a HiExcursion or a LowExcursion'
		if (@value >=  @HiThreashold) SET @HiOrLow = 'HiExcursion'
		ELSE SET @HiOrLow = 'LowExcursion';

		PRINT 'Loop through Excursion points in the time period if any'
		WHILE @@FETCH_STATUS = 0  
		BEGIN

			PRINT 'IF RampOut exists ..'
			IF EXISTS (SELECT * FROM @RampOutPoints) BEGIN 
				PRINT '..If current Excursion Time greater than RampOut Time (next Excursion cycle) ..'
				IF (@time > @ROtime) BEGIN
					PRINT '.. save current full Excursion in @FullExcCycle tmpTbl, and  ..'
					INSERT INTO @FullExcCycle
					SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @ExcPoints UNION SELECT * FROM @RampOutPoints;
					PRINT '.. prepare for next Excursion by clearing Temp tables and incrementing ExcNbr'
					DELETE @ExcPoints;
					DELETE @RampInPoints;
					DELETE @RampOutPoints;
					SET @ExcNbr = @ExcNbr + 1;
					--UPDATE @ExcPoints Set ExcNbr = @ExcNbr;
				END
			END
			
			PRINT 'Save Excursion point in Temp table'
			INSERT INTO @ExcPoints VALUES (@ExcNbr, @tag, @time, @value, @HiOrLow);

			PRINT 'Create Ramp points if they don''t exist for this Excursion cycle'
			IF NOT EXISTS (SELECT * FROM @RampOutPoints) BEGIN
				PRINT 'RampIn being created' 
				INSERT INTO @RampInPoints 
				SELECT TOP 1 @ExcNbr as 'ExcNbr', [tag], [time], [value], @RampIn as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time < @time AND 
				(@HiOrLow = 'HiExcursion' AND value < @HiThreashold OR @HiOrLow = 'LowExcursion' AND value >= @LowThreashold)
				ORDER BY [time] DESC; 

				PRINT 'RampOut being created' 
				INSERT INTO @RampOutPoints
				SELECT TOP 1 @ExcNbr as 'ExcNbr', [tag], [time], [value], @RampOut as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time >= @time AND 
				(@HiOrLow = 'HiExcursion' AND value < @HiThreashold OR @HiOrLow = 'LowExcursion' AND value >= @LowThreashold)
				ORDER BY [time] ASC; 
				PRINT 'Save RampOut point''s time'
				SELECT Top 1 @ROtime = time from @RampOutPoints;
			END

			PRINT 'Fetch next High Excursion point'
			FETCH NEXT FROM CPoint INTO @tag, @time, @value;  
		END;

		PRINT 'if Excursion point exists ..'
		IF EXISTS (SELECT TOP 1 * FROM @ExcPoints) BEGIN
			PRINT '..save final points as last Full Excursion Cycle'
			INSERT INTO @FullExcCycle
			SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @ExcPoints UNION SELECT * FROM @RampOutPoints;

		END

	CLOSE CPoint;
	DEALLOCATE CPoint;

	PRINT 'RETURN ALL Full Excursion Cycles'
	SELECT * FROM @FullExcCycle;

END