/****** Object:  UserDefinedFunction [dbo].[fnToStructDuration]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [dbo].[fnToStructDuration]
GO
/****** Object:  UserDefinedFunction [dbo].[fnToStructDuration]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnToStructDuration] 
(
	-- Add the parameters for the function here
	@totalSeconds int
)
RETURNS varchar(20) WITH RETURNS NULL ON NULL INPUT
AS
BEGIN

	-- Declare the return variable here
	DECLARE @Result varchar(20)


	DECLARE @days BIGINT, @hours BIGINT, @minutes BIGINT, @seconds BIGINT
	DECLARE @KEEP DATETIME

	SET @days = @totalSeconds / (24 * 60 * 60); -- division result is truncated to an integer

	Set @totalSeconds = (@totalSeconds - (@days * 24 * 60 * 60));
	SET @hours = @totalSeconds / (60 * 60); 
	
	SET @totalSeconds = (@totalSeconds - (@hours * 60 * 60));
	SET @minutes = @totalSeconds / 60;

	SET @totalSeconds = @totalSeconds - (@minutes * 60);
	SET @seconds = @totalSeconds;

	SET @Result = CONCAT(':', RIGHT('00' + CAST(@seconds as varchar(2)),2));
	SET @Result = CONCAT(':', RIGHT('00' + CAST(@minutes as varchar(2)),2),@Result); 
	SET @Result = CONCAT(':', RIGHT('00' + CAST(@hours as varchar(2)),2),@Result); 
	SET @Result = CONCAT(RIGHT('00' + CAST(@days as varchar(3)),2),@Result); 
	
	RETURN @Result;

--select [dbo].[fnToStructDuration](31539690); SELECT DATEDIFF(second,'2022-01-01 00:00:00', '2023-01-01 01:01:30');
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-01 01:01:30'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-01 00:2:1'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-03 01:01:30'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2023-01-01 01:01:30'));
--

END



GO
