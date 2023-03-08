/****** Object:  UserDefinedFunction [BB50PCS\jsantos].[fnYYYYMM]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [BB50PCS\jsantos].[fnYYYYMM]
GO
/****** Object:  UserDefinedFunction [BB50PCS\jsantos].[fnYYYYMM]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Name
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [BB50PCS\jsantos].[fnYYYYMM] 
(
	-- Add the parameters for the function here
	@date DateTime
)
RETURNS char(6)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result char(6)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = CONCAT(YEAR(@date), RIGHT(CONCAT('00',  MONTH(@date)), 2))

	-- Return the result of the function
	RETURN @Result

END
GO
