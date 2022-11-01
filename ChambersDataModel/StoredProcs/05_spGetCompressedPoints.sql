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
, @RampOutFromHiExcType varchar(16) = 'RampOutFromHi' 
, @RampInToHiExcType varchar(16) = 'RampInToHi' ;

DECLARE @HiExcPoints as TABLE ( ExcId int Not Null, tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampOutPoints as TABLE ( ExcId int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );
DECLARE @RampInPoints as TABLE ( ExcId int Not Null,  tag varchar(255) NOT NULL, time DateTime NOT NULL
, value float NOT NULL, excType varchar(16) NOT NULL );

DECLARE  @tag varchar(255), @time DateTime, @value float;

	DECLARE CPoint CURSOR
		FOR SELECT [tag], [time], [value] from  [dbo].[CompressedPoints]
		WHERE tag = @TagName AND time >= @StartDate AND time < @EndDate AND value > @HiThreashold
		ORDER BY time;

		SET @ExcId = @ExcId + 1;
		OPEN CPoint;
		PRINT 'Fetch first Excursion point'
		FETCH NEXT FROM CPoint INTO @tag, @time, @value;

		WHILE @@FETCH_STATUS = 0  
		BEGIN
			IF EXISTS (SELECT * FROM @RampOutPoints) BEGIN 
				PRINT 'RampOut found' 
			END
			ELSE BEGIN
				PRINT 'RampIn being created' 
				INSERT INTO @RampInPoints
				SELECT TOP 1 @ExcId as 'ExcId', [tag], [time], [value], @RampInToHiExcType as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time < @time AND value < @HiThreashold
				ORDER BY [time] DESC; 

				PRINT 'RampOut being created' 
				INSERT INTO @RampOutPoints
				SELECT TOP 1 @ExcId as 'ExcId', [tag], [time], [value], @RampOutFromHiExcType as 'ExcType' 
					from  [dbo].[CompressedPoints]
				WHERE tag = @tag AND time >= @time AND value < @HiThreashold
				ORDER BY [time] ASC; 
			END

			PRINT 'Saving High Excursion point'
			INSERT INTO @HiExcPoints VALUES (@ExcId, @tag, @time, @value, @HiExcType);

			PRINT 'Fetch next High Excursion point'
			FETCH NEXT FROM CPoint INTO @tag, @time, @value;  
		END;

		CLOSE CPoint;
		DEALLOCATE CPoint;

	--PRINT 'SELECT * FROM @HiExcPoints';
	SELECT * FROM @RampInPoints UNION ALL SELECT * FROM @HiExcPoints UNION SELECT * FROM @RampOutPoints;

END;