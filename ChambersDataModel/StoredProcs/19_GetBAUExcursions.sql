CREATE PROCEDURE [dbo].[GetBAUExcursions] 
	-- Add the parameters for the stored procedure here
	@TagsList varchar(max),  @AfterDate DateTime = NULL, @BeforeDate DateTime = null, @DurationThreshold int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF (@AfterDate IS null) SET @AfterDate = DATEFROMPARTS(YEAR(GetDate()),1,1);
	IF (@BeforeDate IS null) SET @BeforeDate = DATEADD(day,-1,GetDate());
	
	SELECT * from [dbo].[BAUExcursions] as BE
	WHERE BE.TagId in (SELECT * FROM STRING_SPLIT(@TagsList,','))
	AND BE.FirstExcDate >= @AfterDate AND BE.FirstExcDate < @BeforeDate
	AND (
		(@DurationThreshold is NULL AND BE.Duration > BE.ThresholdDuration)
		OR
		(@DurationThreshold is NOT NULL AND BE.Duration > @DurationThreshold)
	)

	--MUST USE TagIds instead of TagNames
	--EXEC GetBAUExcursions '15767'
	--EXEC GetBAUExcursions '15767,16667'
	--EXEC GetBAUExcursions '15767,16667', NULL, NULL, 0
	--EXEC GetBAUExcursions '15767,16667', NULL, NULL, 10000
	--SELECT DISTINCT * FROM (  VALUES (1), (1), (1), (2), (5), (1), (6)) as list(val);
END