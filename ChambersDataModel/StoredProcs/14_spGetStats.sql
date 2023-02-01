CREATE PROCEDURE [dbo].[spGetStats]
	@TagName varchar(255), 
	@FirstExcDate DateTime,
	@LastExcDate DateTime,
	@MinValue float NULL OUTPUT,
	@MaxValue float NULL OUTPUT,
	@AvergValue float NULL OUTPUT,
	@StdDevValue float NULL OUTPUT
AS
BEGIN
PRINT '>>> spGetStats begins'

		SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
			FROM [dbo].Interpolated as Stat
			WHERE Stat.tag = @TagName  and Stat.time >= @FirstExcDate And Stat.Time <= @LastExcDate;

PRINT 'spGetStats ends <<<'
--DECLARE @OMinValue    float;
--DECLARE @OMaxValue    float;
--DECLARE @OAvergValue  float;
--DECLARE @OStdDevValue float;
----insert into[dbo].[ExcursionStats]
--EXECUTE dbo.spGetStats chamber_report_tag_1, '2022-11-01 12:03:00.00', '2022-11-01 13:57:00.000'
--	, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
--PRINT CONCAT(@OMinValue,'-', @OMaxValue,'-', @OAvergValue,'-', @OStdDevValue);
END