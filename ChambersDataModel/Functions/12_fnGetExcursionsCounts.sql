CREATE FUNCTION [dbo].[fnGetExcursionsCounts] (
      @TagNamesList varchar(max),
      @MinHiCount int = Null,
      @MinLowCount int = NULL,
      @AfterDate DateTime = NULL,
      @BeforeDate DateTime = NULL)
RETURNS @ExcsCounts TABLE (TagName varchar(255), HiExcsCount int, LowExcsCount int)
AS
BEGIN
--DECLARE @LowestDate datetime = '1900-01-01', @HighestDate datetime = '1900-01-01';
      IF (@MinHiCount IS NULL OR @MinHiCount < 0) SET @MinHiCount = 0;
      IF (@MinLowCount IS NULL OR @MinLowCount < 0) SET @MinLowCount = 0;

      INSERT INTO @ExcsCounts
      SELECT TagName, Count(Case when exc.HiPointsCt > 0 then 1 else null end) as HiExcsCount
             , Count(Case when exc.LowPointsCt > 0 then 1 else null end) as LowExcsCount 
      from [dbo].[ExcursionPoints] as exc
      where 
      (@TagNamesList IS NULL OR TagName in (SELECT value FROM STRING_SPLIT( @TagNamesList, ',')))
      AND ((exc.HiPointsCt > @MinHiCount) Or (exc.LowPointsCt > @MinLowCount))
      AND (@AfterDate IS NULL OR @AfterDate <= exc.RampOutDate)
      AND (@BeforeDate IS NULL OR exc.RampInDate <= @BeforeDate )
      GROUP BY TagName;

      DECLARE @rowsCnt int;
      SELECT @rowsCnt = COUNT(*) FROM @ExcsCounts;

      RETURN;
END
-- RampInDate      RampOutDate      HiPointsCt   LowPointsCt
-- 2022-11-01 12:00:00.000      2022-11-01 12:02:00.000      1     0
-- 2022-11-01 12:02:00.000      2022-11-01 13:58:00.000      115   0
-- 2022-11-01 13:59:00.000      2022-11-01 14:01:00.000      1     0
-- 2022-11-03 14:32:00.000      2022-11-03 14:40:00.000      0     1
-- 2022-11-03 14:48:00.000      2022-11-04 01:16:00.000      0     156
-- 2022-11-04 01:16:00.000      2022-11-04 01:24:00.000      0     1
-- 2022-11-04 01:24:00.000      2022-11-04 01:36:00.000      0     2

-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, null, null); 
-- RETURN: chamber_report_tag_1      3     4
-- SELECT * from [dbo].[fnGetExcursionsCounts]('chamber_report_tag_1', 0, 1, null, null); 
-- RETURN: chamber_report_tag_1      3     2
-- SELECT * from [dbo].[fnGetExcursionsCounts]('chamber_report_tag_1', 0, 0, '2022-11-02', null); 
-- RETURN: chamber_report_tag_1      0     4
-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, '2022-11-04', null); 
-- RETURN: chamber_report_tag_1      0     3
-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, '2022-11-05', null); 
-- RETURN: no rows
-- SELECT * from [dbo].[fnGetExcursionsCounts](NULL, NULL, NULL, NULL, '2022-11-04'); 
-- RETURN: chamber_report_tag_1      3     2
-- SELECT * from [dbo].[fnGetExcursionsCounts]('chamber_report_tag_1, chamber_report_tag_2', 0, 1, null, null)
-- RETURN: chamber_report_tag_1      3     2


