CREATE FUNCTION [dbo].[fnGetOverlappingDates] 
(	
	-- Add the parameters for the function here
	@StartDate1 DateTime 
	, @endDate1 DateTime
	, @StartDate2 DateTime 
	, @endDate2 DateTime
)
RETURNS @OverlappingSates TABLE ( StartDate DateTime NULL, EndDate DateTime NULL )
AS
BEGIN
	DECLARE @StartDate DateTime , @EndDate DateTime ;
	
	SELECT 
		@StartDate = 
			CASE
				WHEN @StartDate1 > @EndDate2 THEN NULL
				WHEN @StartDate1 < @StartDate2 THEN @StartDate2
				ELSE @StartDate1
			END,
		@EndDate = 
			CASE
				WHEN @EndDate1 < @StartDate2 THEN NULL
				WHEN @EndDate1 > @EndDate2 THEN @EndDate2
				ELSE @EndDate1
			END;
	IF @StartDate IS NULL OR @EndDate IS NULL
		BEGIN INSERT @OverlappingSates SELECT NULL, NULL END
	ELSE 
		BEGIN INSERT @OverlappingSates SELECT @StartDate, @EndDate END

	RETURN;
	--Unit Tests
--SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-03-31','2023-02-01','2023-02-27') 
	--> 2023-02-01 00:00:00.000 | 2023-02-27 00:00:00.000
--SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-03-31','2023-02-01',NULL) 
	--> 2023-02-01 00:00:00.000 | 2023-03-31 00:00:00.000
--SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-01-31','2023-02-01','2023-02-27') 
	--> NULL | NULL

--SELECT StartDate From (SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-03-31','2023-02-01',NULL)) as ovr
	-->2023-02-01 00:00:00.000
--SELECT CASE WHEN StartDate IS NULL THEN 'True' ELSE ' false' END From (SELECT * FROM [dbo].[fnGetOverlappingDates]('2023-01-01', '2023-01-31','2023-02-01','2023-02-27')) as ovr
	-->True
END;
