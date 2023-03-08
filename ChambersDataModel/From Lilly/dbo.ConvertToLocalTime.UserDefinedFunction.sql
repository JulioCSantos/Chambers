/****** Object:  UserDefinedFunction [dbo].[ConvertToLocalTime]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [dbo].[ConvertToLocalTime]
GO
/****** Object:  UserDefinedFunction [dbo].[ConvertToLocalTime]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Bill Coleman
-- Create date: Jan 27, 2009
-- Description:	Converts UTC time to Local (Eastern) time
-- =============================================
CREATE FUNCTION [dbo].[ConvertToLocalTime]
(
	@UTCdt DateTime
)
RETURNS DateTime
AS
BEGIN 
	DECLARE @offset INT
	DECLARE @sdt SMALLDATETIME 
	DECLARE @edt SMALLDATETIME 
	DECLARE @i TINYINT 
	  
	SET @offset = 5;   --EST
	SET @i = 1; 
	 
	-- find second Sunday in March 
	 
	WHILE @i <= 7 
	BEGIN 
		SET @sdt = RTRIM(YEAR(@UTCdt))+'030'+RTRIM(@i) 
		IF DATEPART(weekday,@sdt)=1  
		BEGIN 
			SET @i = @i + 7 
			SET @sdt = RTRIM(YEAR(@UTCdt))+'03'+RIGHT('0'+RTRIM(@i),2)			
		END 
		SET @i = @i + 1 
	END 
	 
	-- find first Sunday in Nov 
	 
	SET @i = 1
	WHILE @i < 7 
	BEGIN 
		SET @edt = RTRIM(YEAR(@UTCdt))+'110'+RTRIM(@i) 
		IF DATEPART(weekday,@edt)=1  
		BEGIN 
			SET @i = 24 
		END 
		SET @i = @i + 1 
	END 
	 
	-- subtract hour from offset if within DST 
	 
	IF (@UTCdt>=@sdt AND @UTCdt<@edt) 
		SET @offset = @offset - 1 
	
	SET @offset = -1 * @offset
	
	RETURN DATEADD(hour, @offset, @UTCdt) 
END


GO
