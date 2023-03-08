/****** Object:  UserDefinedFunction [BB50PCS\jsantos].[fnGetNewExcursions]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [BB50PCS\jsantos].[fnGetNewExcursions]
GO
/****** Object:  UserDefinedFunction [BB50PCS\jsantos].[fnGetNewExcursions]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [BB50PCS\jsantos].[fnGetNewExcursions](
@minThreshold float = -25.0, @maxThreshold float = -15.0, @daysToAdd as int = 100
)
RETURNS TABLE
AS RETURN
(
	SELECT *, DATEADD(d,@daysToAdd,XdateStr) as newDate, (a*CVal + b) as newValue  FROM (
		SELECT (@minThreshold-a*100) as b, * FROM (
			SELECT ((@minThreshold-@maxThreshold)/(100.0-200.0)) as a
			) as i1
		) as i2 cross 
		join 
		(
			SELECT * FROM 	[BB50PCS\jsantos].HiExcursion
			UNION ALL
			SELECT * FROM 	[BB50PCS\jsantos].LowExcursion
			UNION ALL
			SELECT * FROM 	[BB50PCS\jsantos].OneHiOneLowOneDay
			UNION ALL
			SELECT * FROM 	[BB50PCS\jsantos].OneHiOneLowTwoDays
		) as I5
)
--GO
--select * from fnGetNewExcursions(-25,-15,106) Order by newDate;
--select * from fnGetNewExcursions(-25,-15,DateDiff(d,'2022-11-01','2023-02-15')) Order by newDate;
--SELECT Min([newDate]) as minDate, Min(NewValue) as MinVal, Max([NewDate]) as MaxDate, Max(newValue) as MaxValue
--	, count(*) as points FROM (
--		select * from fnGetNewExcursions(-25,-15,105) 
--) as i4;
GO
