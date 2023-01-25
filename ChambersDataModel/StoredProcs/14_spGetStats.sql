
CREATE PROCEDURE dbo.spGetStats
	@TagName varchar(255) NULL, 
	@TagExcNbr int NULL 
AS
SELECT TagName, TagExcNbr, TagId, Min(Value) as MinValue, max(Value) as MaxValue, Avg(Value) as AverageValue, STDEV(value) as StdDeviation
From 
(
select EP.TagId, EP.TagName, EP.TagExcNbr, EP.FirstExcDate, Stat.tag, Stat.time, Stat.value 
, ES.TagName as EsTagName, ES.TagExcNbr as EsTagExcNbr
from [dbo].[ExcursionPoints] as EP
LEFT JOIN dbo.ExcursionStats as ES
On EP.TagName = ES.TagName AND EP.TagExcNbr = ES.TagExcNbr
LEFT JOIN 
 [ELChambers].[dbo].Interpolated as Stat
ON Stat.tag = EP.TagName and Stat.time >= EP.FirstExcDate And Stat.Time <= EP.LastExcDate
WHERE 
(
@TagName IS NULL OR (
	EP.TagName = @TagName AND (@TagExcNbr IS NULL OR EP.TagExcNbr = @TagExcNbr)
	)
)  
AND 
ES.TagName IS null  AND ES.TagExcNbr IS NULL
) as stats
Group by TagName, TagExcNbr, TagId

--insert into[dbo].[ExcursionStats]
--EXECUTE dbo.spGetStats chamber_report_tag_1, NULL