
CREATE PROCEDURE dbo.spGetStats
	@TagName varchar(255) NULL, 
	@TagExcNbr int NULL 
AS
BEGIN
DECLARE @EPTagName varchar(255), @EPTagExcNbr int, @EPTagId int,  @EPFirstExcDate DateTime, @EPLastExcDate DateTime

DECLARE EPsCsr CURSOR FOR
	SELECT EP.TagName, EP.TagExcNbr, EP.TagId, EP.FirstExcDate, EP.LastExcDate FROM [dbo].[ExcursionPoints] as EP
	LEFT JOIN dbo.ExcursionStats as ES
	On EP.TagName = ES.TagName AND EP.TagExcNbr = ES.TagExcNbr
	WHERE @TagName IS NULL OR (EP.TagName = @TagName AND (@TagExcNbr IS NULL OR EP.TagExcNbr = @TagExcNbr))
	AND ES.TagName IS null  AND ES.TagExcNbr IS NULL

	OPEN EPsCsr;
	FETCH NEXT FROM EPsCsr INTO @EPTagName, @EPTagExcNbr, @EPTagId, @EPFirstExcDate, @EPLastExcDate;
	WHILE @@FETCH_STATUS = 0 BEGIN
		SELECT @EPTagName as TagName, @EPTagExcNbr as TagExcNbr, @EPTagId as TagId, 
				Min(Value) as MinValue, max(Value) as MaxValue, Avg(Value) as AverageValue, STDEV(value) as StdDeviation
			FROM [ELChambers].[dbo].Interpolated as Stat
			WHERE Stat.tag = @EPTagName  and Stat.time >= @EPFirstExcDate And Stat.Time <= @EPLastExcDate
		FETCH NEXT FROM EPsCsr INTO @EPTagName, @EPTagExcNbr, @EPTagId, @EPFirstExcDate, @EPLastExcDate;
	END;
	CLOSE EPsCsr;
	DEALLOCATE EPsCsr;

--insert into[dbo].[ExcursionStats]
--EXECUTE dbo.spGetStats chamber_report_tag_1, NULL
END