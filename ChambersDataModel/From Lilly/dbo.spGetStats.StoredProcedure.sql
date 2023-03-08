/****** Object:  StoredProcedure [dbo].[spGetStats]    Script Date: 03/07/2023 00:12:30 ******/
DROP PROCEDURE [dbo].[spGetStats]
GO
/****** Object:  StoredProcedure [dbo].[spGetStats]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

		--DECLARE @TimeStep time(0);
		--SELECT @TimeStep = [dbo].fnCalcTimeStep(@FirstExcDate, @LastExcDate, 60);
		--SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate, @TimeStep);
		SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
			FROM [dbo].fnGetInterp2(@TagName,@FirstExcDate,@LastExcDate,'00:10:00');

		--SELECT @MinValue = Min(Value), @MaxValue = max(Value), @AvergValue = Avg(Value), @StdDevValue = STDEV(value)
		--	FROM [dbo].Interpolated as Stat
		--	WHERE Stat.tag = @TagName  and Stat.time >= @FirstExcDate And Stat.Time <= @LastExcDate;

PRINT 'spGetStats ends <<<'
--DECLARE @OMinValue    float;
--DECLARE @OMaxValue    float;
--DECLARE @OAvergValue  float;
--DECLARE @OStdDevValue float;
------insert into[dbo].[ExcursionStats]
--EXECUTE dbo.spGetStats chamber_report_tag_1, '2022-11-01 12:03:00.00', '2022-11-01 13:57:00.000'
--	, @MinValue = @OMinValue OUTPUT, @MaxValue = @OMaxValue OUTPUT, @AvergValue = @OAvergValue OUTPUT, @StdDevValue = @OStdDevValue OUTPUT;
--PRINT CONCAT(@OMinValue,'-', @OMaxValue,'-', @OAvergValue,'-', @OStdDevValue);
END
GO
