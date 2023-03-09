CREATE Function [dbo].[fnToDuration] 
	( @SDuration varchar(12) )
	RETURNS int WITH RETURNS NULL ON NULL INPUT
AS BEGIN
	DECLARE @Result int ;
	DECLARE @sdays varchar(12), @days int, @time varchar(8);
	-- Does input @SDuration contain a days ('d') delimitir? if not return NULL
	if (Charindex('d', @SDuration) = 0 ) RETURN NULL;
	Select  @sdays = Substring(@SDuration, 1,Charindex('d', @SDuration)-1);
	-- Reject days if it is not a numeric by returning NULL
	if (isNumeric(@sdays) = 0) RETURN NULL
	ELSE set @days = cast(@sdays as int);

	DECLARE @hh int, @mm int, @ss int;
	DECLARE @shh varchar(12), @smm varchar(12), @sss varchar(12);
	
	IF (LEN(@SDuration) <= LEN(@sdays)) RETURN NULL; --nothing else to parse
	-- get balance of @SDuration to parse as @time
	SELECT @time = Substring(@SDuration, Charindex('d', @SDuration)+1, LEN(@SDuration));

	--parse hours
	if (Charindex(':', @time) = 0 ) RETURN NULL;
	Select  @shh = Substring(@time, 1,Charindex(':', @time)-1);
	if (isNumeric(@shh) = 0) RETURN NULL
	else set @hh = cast(@shh as int);

	IF (LEN(@time) <= LEN(@shh)) RETURN NULL; --nothing else to parse
	-- get balance of @time to parse
	SELECT @time = Substring(@time, Charindex(':', @time)+1, LEN(@time));

		--parse minutes
	if (Charindex(':', @time) = 0 ) RETURN NULL;
	Select  @smm = Substring(@time, 1,Charindex(':', @time)-1);
	if (isNumeric(@smm) = 0) RETURN NULL
	else set @mm = cast(@smm as int);

	IF (LEN(@time) <= LEN(@smm)) RETURN NULL; --nothing else to parse
	-- get balance of @time to parse
	SELECT @time = Substring(@time, Charindex(':', @time)+1, LEN(@time));

	--parse seconds
	Select  @sss = @time;
	if (isNumeric(@sss) = 0) RETURN NULL
	else set @ss = cast(@sss as int);

	SET @Result = @ss + @mm * 60 + @hh * (60 * 60) + @days * (24 * 60 * 60);

	RETURN @Result;

--SELECT dbo.fnToDuration('000d00:01:30');-- result 90
--SELECT dbo.fnToDuration('000d01:00:00');-- result 3600
--SELECT dbo.fnToDuration('0d01:00:00');-- result 3600
--SELECT dbo.fnToDuration('0d100:00:00');-- result 360000
--SELECT dbo.fnToDuration('1d');-- result NULL
--SELECT dbo.fnToDuration('0d00:01:00');-- result 60
--SELECT dbo.fnToDuration('0d0:1:00');-- result 60

END
