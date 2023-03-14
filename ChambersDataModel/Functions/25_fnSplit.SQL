CREATE FUNCTION dbo.fnSplit
(
    @Line nvarchar(MAX),
    @SplitOn nvarchar(5) = ','
)
RETURNS @RtnValue table
(
    Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY CLUSTERED,
    Data nvarchar(100) NOT NULL
)
AS
BEGIN
    IF @Line IS NULL RETURN;

    DECLARE @split_on_len INT = LEN(@SplitOn);
    DECLARE @start_at INT = 1;
    DECLARE @end_at INT;
    DECLARE @data_len INT;

    WHILE 1=1
    BEGIN
        SET @end_at = CHARINDEX(@SplitOn,@Line,@start_at);
        SET @data_len = CASE @end_at WHEN 0 THEN LEN(@Line) ELSE @end_at-@start_at END;
        INSERT INTO @RtnValue (data) VALUES( SUBSTRING(@Line,@start_at,@data_len) );
        IF @end_at = 0 BREAK;
        SET @start_at = @end_at + @split_on_len;
    END;

    RETURN;

	--SELECT Cast(data as int) * 10 from dbo.fnSplit('11,12,13',',')

END;