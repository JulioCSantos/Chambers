/****** Object:  StoredProcedure [BB50PCS\jsantos].[spGetExcursionsCounts]    Script Date: 03/07/2023 00:12:30 ******/
DROP PROCEDURE [BB50PCS\jsantos].[spGetExcursionsCounts]
GO
/****** Object:  StoredProcedure [BB50PCS\jsantos].[spGetExcursionsCounts]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BB50PCS\jsantos].[spGetExcursionsCounts]
       @MinHiCount int = 0,
       @MinLowCount int = 0,
       @OuterStartDate DateTime = NULL,
       @OuterEndDate DateTime = NULL
AS
BEGIN
DECLARE @LowestDate datetime = '1900-01-01', @HighestDate datetime = '1900-01-01';
select TagName
, Count(Case when exc.HiPointsCt > 0 then 1 else null end) as HiExcsCount
, Count(Case when exc.LowPointsCt > 0 then 1 else null end) as LowExcsCount 
from [dbo].[ExcursionPoints] as exc
where ((exc.HiPointsCt > @MinHiCount) Or (exc.LowPointsCt > @MinLowCount))
AND (@OuterStartDate IS NULL OR @OuterStartDate <= exc.RampInDate)
AND (@OuterEndDate IS NULL OR exc.RampOutDate <= @OuterEndDate )
GROUP BY TagName;
END
-- RampInDate RampOutDate       HiPointsCt    LowPointsCt
-- 2022-11-01 12:00:00.000 2022-11-01 12:02:00.000   1      0
-- 2022-11-01 12:02:00.000 2022-11-01 13:58:00.000   115    0
-- 2022-11-01 13:59:00.000 2022-11-01 14:01:00.000   1      0
-- 2022-11-03 14:32:00.000 2022-11-03 14:40:00.000   0      1
-- 2022-11-03 14:48:00.000 2022-11-04 01:16:00.000   0      156
-- 2022-11-04 01:16:00.000 2022-11-04 01:24:00.000   0      1
-- 2022-11-04 01:24:00.000 2022-11-04 01:36:00.000   0      2

--EXEC [dbo].[spGetExcursionCounts]; RETURN: chamber_report_tag_1      3       4
--EXEC [dbo].[spGetExcursionCounts] 0, 1; RETURN: chamber_report_tag_1 3       2
--EXEC [dbo].[spGetExcursionCounts] 0, 0, '2022-11-02'; RETURN: chamber_report_tag_1 0      4
--EXEC [dbo].[spGetExcursionCounts] 0, 0, '2022-11-04'; RETURN: chamber_report_tag_1 0      2
--EXEC [dbo].[spGetExcursionCounts] 0, 0, '2022-11-05'; RETURN: no rows
--EXEC [dbo].[spGetExcursionCounts] 0, 0, NULL, '2022-11-04'; RETURN: chamber_report_tag_1 3      1

GO
