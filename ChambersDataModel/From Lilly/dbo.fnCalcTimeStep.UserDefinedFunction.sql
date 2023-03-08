/****** Object:  UserDefinedFunction [dbo].[fnCalcTimeStep]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [dbo].[fnCalcTimeStep]
GO
/****** Object:  UserDefinedFunction [dbo].[fnCalcTimeStep]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[fnCalcTimeStep] 
(
	-- Add the parameters for the function here
	@StartDate DateTime,
	@EndDate DateTime,
	@NbrOfPoints int
)
RETURNS Time(0)
AS
BEGIN
	DECLARE @Result time(0), @holderDate DateTime

	IF (@StartDate > @EndDate) BEGIN
		SET @holderDate = @EndDate;
		SET @EndDate = @StartDate;
		SET @StartDate = @holderDate;
	END

	DECLARE @seconds int = DateDiff(SECOND,@StartDate,@EndDate);
	DECLARE @timeStep int = @seconds/@NbrOfPoints;
	


	-- Compute in milliseconds to facilitate conversion
	SELECT @Result = Cast(CONVERT(varchar, DATEADD(ms, @timeStep * 1000, 0), 114) as time(0));

	-- Return the result of the function
	RETURN @Result

-- Unit Tests
--SELECT [dbo].fnCalcTimeStep('2023-01-01 00:01:00', '2023-01-01 00:02:00', 60) --> 00:00:01 
--SELECT [dbo].fnCalcTimeStep('2023-01-01 01:00:00', '2023-01-01 02:00:00', 60) --> 00:01:00 
--SELECT [dbo].fnCalcTimeStep('2023-01-01 01:00:00', '2023-01-07 01:00:00', 60) --> > 02:00:00 

END
GO
