Create FUNCTION [dbo].[fnToStructDuration] 
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
	SET @Result = CONCAT('d', RIGHT('00' + CAST(@hours as varchar(2)),2),@Result); 
	SET @Result = CONCAT(RIGHT('000' + CAST(@days as varchar(3)),3),@Result); 
	RETURN @Result;


END

--select [dbo].[fnToStructDuration](31539690);
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2022-01-01 01:01:30'));
--select [dbo].[fnToStructDuration](DATEDIFF(second,'2022-01-01 00:00:00', '2023-01-01 01:01:30'));
--SELECT DATEDIFF(second,'2022-01-01 00:00:00', '2023-01-01 01:01:30');

