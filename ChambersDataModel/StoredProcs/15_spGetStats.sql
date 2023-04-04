CREATE PROCEDURE [dbo].[spGetStats]
	@TagName varchar(255), 
	@FirstExcDate DateTime,
	@LastExcDate DateTime,
	@ExcPointsCount int NULL OUTPUT,
	@MinValue float NULL OUTPUT,
	@MaxValue float NULL OUTPUT,
	@AvergValue float NULL OUTPUT,
	@StdDevValue float NULL OUTPUT
AS
BEGIN
PRINT '>>> spGetStats begins'

		--DECLARE @t1 DATETIME, @t2 DATETIME, @elapsedTime int;
		--DECLARE @days int, @mins int, @secs int, @stepsize time(0);
		--SET @days = DATEDIFF(day, @FirstExcDate, @LastExcDate);
		--SET @mins = @days/60;
		--SET @secs = IIF(@days - @mins*60 < 1,IIF(@mins = 0,1,@days - @mins*60),@days - @mins*60);
		--SET @stepSize = CAST(CONCAT('00:',@mins,':',@secs) as time(0));

		--PRINT CONCAT('@TagName:',@TagName,' @FirstExcDate:', FORMAT(@FirstExcDate,'yyyy-MM-dd HH:mm:ss')
		--	,' @LastExcDate:', FORMAT(@LastExcDate,'yyyy-MM-dd HH:mm:ss'))

		SELECT @ExcPointsCount = count(*),  @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
			FROM [BB50PCSjsantos].Interpolated as Stat
			WHERE Stat.tag = @TagName  and Stat.time >= @FirstExcDate And Stat.Time <= @LastExcDate;

		--SET @t1 = GETDATE();
		--SELECT @ExcPointsCount = count(*), @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate,@stepSize);
		--SET @t2 = GETDATE();
		
		--SELECT @elapsedTime = DATEDIFF(millisecond,@t1,@t2);
		--PRINT CONCAT('@elapsedTime:', @elapsedTime);
		--PRINT CONCAT('@ExcPointsCount:',@ExcPointsCount,' @MinValue:', @MinValue,' @MaxValue:', @MaxValue);
		--PRINT CONCAT('@AvergValue:', @AvergValue, ' @StdDevValue:',@StdDevValue,' @stepSize:',@stepSize)



PRINT 'spGetStats ends <<<'

END
