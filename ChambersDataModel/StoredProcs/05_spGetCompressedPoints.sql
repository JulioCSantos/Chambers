CREATE PROCEDURE [dbo].[spGetCompressedPoints] 
(	
	-- Add the parameters for the function here
	  @TagName varchar(255)
	, @StartDate DateTime 
	, @EndDate DateTime
	, @LowThreshold float
	, @HiThreashold float 
)
AS
BEGIN
DECLARE @ExcId int = 0, @HiExcType varchar(16) = 'HiExcursion'
, @RampOutFromHiExcType varchar(16) = 'RampOut' 
, @RampInToHiExcType varchar(16) = 'RampIn' ;

DECLARE @FullExcCycle as TABLE ( ExcId int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE @HiExcPoints as TABLE ( ExcId int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampOutPoints as TABLE ( ExcId int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampInPoints as TABLE ( ExcId int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE  @tag varchar(255), @time DateTime, @value float;
DECLARE @ROexcId int,  @ROtag varchar(255), @ROtime DateTime, @ROvalue float, @ROexcType varchar(16);

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate 
		AND (value > @HiThreashold OR value < @LowThreshold)
		ORDER BY time;

		SET @ExcId = @ExcId + 1;
		OPEN CPoint;
		PRINT 'Fetch first Excursion point'
		FETCH NEXT FROM CPoint INTO @tag, @time, @value;

		PRINT 'Loop through Excursion points in the time period if any'
		WHILE @@FETCH_STATUS = 0  
		BEGIN

			PRINT 'IF RampOut exists ..'
			IF EXISTS (SELECT * FROM @RampOutPoints) BEGIN 
				PRINT '..If current Excursion Time greater than RampOut Time (next Excursion cycle) ..'
				IF (@time > @ROtime) BEGIN
					PRINT '.. save current full Excursion in @FullExcCycle tmpTbl, and  ..'
					INSERT INTO @FullExcCycle
					SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @HiExcPoints UNION SELECT * FROM @RampOutPoints;
					PRINT '.. prepare for next Excursion by clearing Temp tables and incrementing ExcId'
					DELETE @HiExcPoints;
					DELETE @RampInPoints;
					DELETE @RampOutPoints;
					SET @ExcId = @ExcId + 1;
					UPDATE @HiExcPoints Set ExcId = @ExcId;
				END
			END
			
			PRINT 'Save Excursion point in Temp table'
			INSERT INTO @HiExcPoints VALUES (@ExcId, @tag, @time, @value, @HiExcType);

			PRINT 'Create Ramp points if they don''t exist for this Excursion cycle'
			IF NOT EXISTS (SELECT * FROM @RampOutPoints) BEGIN
				PRINT 'RampIn being created' 
				INSERT INTO @RampInPoints 
				SELECT TOP 1 @ExcId as 'ExcId', [tag], [time], [value], @RampInToHiExcType as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time < @time AND value < @HiThreashold
				ORDER BY [time] DESC; 
				--UPDATE @RampInPoints SET ExcId = @ExcId, ExcType = @RampInToHiExcType;

				PRINT 'RampOut being created' 
				INSERT INTO @RampOutPoints
				SELECT TOP 1 @ExcId as 'ExcId', [tag], [time], [value], @RampOutFromHiExcType as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time >= @time AND value < @HiThreashold
				ORDER BY [time] ASC; 
				PRINT 'Save RampOut point''s time'
				SELECT Top 1 @ROtime = time from @RampOutPoints;
			END

			PRINT 'Fetch next High Excursion point'
			FETCH NEXT FROM CPoint INTO @tag, @time, @value;  
		END;

		PRINT 'if Excursion point exists ..'
		IF EXISTS (SELECT TOP 1 * FROM @HiExcPoints) BEGIN
			PRINT '..save final points as last Full Excursion Cycle'
			INSERT INTO @FullExcCycle
			SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @HiExcPoints UNION SELECT * FROM @RampOutPoints;

		END

	CLOSE CPoint;
	DEALLOCATE CPoint;

	PRINT 'RETURN ALL Full Excursion Cycles'
	SELECT * FROM @FullExcCycle;

END