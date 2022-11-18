-- GetScheduleDatesForDate('2022-11-03', '2022-10-02', 1, week, 1, month) returns '2022-10-30', '2022-11-05'
-- find schedule dates for date 2022-11-03 when schedule starts on 2022-10-02 (Sunday) and is active for one week 
-- when it repeats every month (first Sunday of the month for a full week)
CREATE FUNCTION fnGetScheduleDates 
(	
	-- Add the parameters for the function here
	@ForDate date, 
	@StartDate date,
	@CoverageValue int,
	@CoverageIntervalUnit varchar(16),
	@RepeatEveryValue int,
	@RepeatEveryIntervalUnit varchar(16)
)
RETURNS @ScheduleDates TABLE (StartDate date NULL, EndDate date NULL)
AS
BEGIN
	DECLARE @SchedStartDate Date , @SchedEndDate Date ;

	-- Compute the RepeatEveryInterval in days
	DECLARE @FirstIntervalEndDate datetime;
	SELECT @FirstIntervalEndDate = (
    CASE 
        WHEN  @RepeatEveryIntervalUnit = 'year' THEN DATEADD(year, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'quarter' THEN DATEADD(quarter, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'month' THEN DATEADD(month, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'dayofyear' THEN DATEADD(dayofyear, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'day' THEN DATEADD(day, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'week' THEN DATEADD(week, @RepeatEveryValue,@StartDate)
        WHEN  @RepeatEveryIntervalUnit = 'weekday' THEN DATEADD(weekday, @RepeatEveryValue,@StartDate)
	END)

	DECLARE @DaysInInterval int;
	
	-- Determine how many RepeatEvery intervals fit between ForDate and StartDate

	-- days in Repeat Every Interval
	SET @DaysInInterval = DATEDIFF(DAY, @StartDate, @FirstIntervalEndDate);

	-- ForDate minus StartDate in days
	DECLARE @DaysBetweenForDateAndStartDate int = DATEDIFF(DAY,@StartDate, @ForDate);

	-- Number of intervals from StartDate to ForDate
	DECLARE @NbrOfIntervals int = FLOOR(@DaysBetweenForDateAndStartDate/@DaysInInterval);

	-- Determine if adjusted StartDate is in Coverage interval (fuzzy logic)

	-- adjusted StartDate is the closest StartDate to ForDate 
	SET @SchedStartDate  = DATEADD(day,@NbrOfIntervals * @DaysInInterval,@StartDate);

	SELECT @SchedEndDate = (
    CASE 
        WHEN @CoverageIntervalUnit = 'year' THEN DATEADD(year, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'quarter' THEN DATEADD(quarter, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'month' THEN DATEADD(month, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'dayofyear' THEN DATEADD(dayofyear, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'day' THEN DATEADD(day, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'week' THEN DATEADD(week, @CoverageValue, @SchedStartDate)
        WHEN @CoverageIntervalUnit = 'weekday' THEN DATEADD(weekday, @CoverageValue, @SchedStartDate)
	END)

	-- Add the SELECT statement with parameter references here
	if (@SchedStartDate <= @ForDate AND @ForDate <= @SchedEndDate) BEGIN
		INSERT @ScheduleDates
		SELECT  @SchedStartDate,  @SchedEndDate;
	END
	ELSE BEGIN
		INSERT @ScheduleDates
		SELECT  NULL,  NULL;
	END

	RETURN ;

END
--DateAdd's interval The time/date interval to add. Can be one of the following values:
--year, yyyy, yy = Year"
--quarter, qq, q = Quarter
--month, mm, m = month
--dayofyear, dy, y = Day of the year
--day, dd, d = Day
--week, ww, wk = Week
--weekday, dw, w = Weekday
--hour, hh = hour
--minute, mi, n = Minute
--second, ss, s = Second
--millisecond, ms = Millisecond


-- UNIT TESTS
-- SELECT * from GetScheduleDatesForDate('2022-11-03', '2022-10-02', 1, 'week', 1, 'month')
-- 2022-11-02	2022-11-09
-- SELECT * from GetScheduleDatesForDate('2022-11-10', '2022-10-02', 1, 'week', 1, 'month')
-- NULL	NULL
