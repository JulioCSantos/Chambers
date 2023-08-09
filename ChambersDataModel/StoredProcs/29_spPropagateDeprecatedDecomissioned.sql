
CREATE PROCEDURE [dbo].[spPropagateDeprecatedDecomissioned] (       
         @dStageDateId int
)
AS
BEGIN
PRINT '>>> spPropagateDeprecatedDecomissioned'

-- Get tag and dates (Deprecated and Decommissioned) for @stageDateId
DECLARE @tagId int, @deprecatedDate dateTime, @decommissionedDate DateTime
select @tagId = TagId, @deprecatedDate = DeprecatedDate, @decommissionedDate = DecommissionedDate 
from [dbo].[StagesLimitsAndDatesCore] where StageDateId = @dStageDateId;
       -- If no Tag details found abort (details are not configured).
       IF (@deprecatedDate is null and @decommissionedDate is null) BEGIN
              PRINT 'a StageDateId that points to a Deprecated or Decommissioned tag must be selected';
              RETURN -1;
       END;

-- Get all StageDates' rows after Deprecated/Decommissioned for tag
DECLARE  @stageDateId int, @startDate datetime
DECLARE @stagesDatesTbl as Table (StageDateId int, startDate datetime, RowNbr int, DeprecatedDate datetime, DecommissionedDate datetime)
INSERT INTO @stagesDatesTbl
SELECT StageDateId, StartDate, ROW_NUMBER() OVER(ORDER BY StageId ASC) AS RowNbr, DeprecatedDate,  DecommissionedDate
from [dbo].[StagesLimitsAndDatesCore]
where TagId = @tagId and StageDateId > @dStageDateId
order by StageId asc

DECLARE @StgDtCount int, @CurrStgDtIx int = 1;
SELECT @StgDtCount = COUNT(*) from @stagesDatesTbl
WHILE @CurrStgDtIx <= @StgDtCount BEGIN
	select @stageDateId = StageDateId, @startDate = StartDate
	from @stagesDatesTbl where RowNbr = @CurrStgDtIx;

	Declare @earliestDeprecatedDate datetime, @earlistDecommissionedDate datetime
	if (@startDate < @decommissionedDate) Begin
		update dbo.ExcursionPoints Set DecommissionedDate = @decommissionedDate
		where TagId = @tagId and (FirstExcDate > @decommissionedDate or LastExcDate > @decommissionedDate)
		IF (@earlistDecommissionedDate is null or @decommissionedDate < @earlistDecommissionedDate)
			SET @earlistDecommissionedDate = @decommissionedDate;
	end
	else if (@startDate < @deprecatedDate) Begin
		update dbo.ExcursionPoints Set DeprecatedDate = @deprecatedDate
		where TagId = @tagId and (FirstExcDate > @deprecatedDate or LastExcDate > @deprecatedDate)
		IF (@earliestDeprecatedDate is null or @deprecatedDate < @earliestDeprecatedDate)
			SET @earliestDeprecatedDate = @deprecatedDate;
	end

	-- get next Deprecated/Decommission date if any
	select @deprecatedDate = DeprecatedDate, @decommissionedDate = DecommissionedDate
	from @stagesDatesTbl where RowNbr = @CurrStgDtIx;

	SET @CurrStgDtIx = @CurrStgDtIx + 1;
END


	Select * from dbo.ExcursionPoints where TagId = @tagId and (FirstExcDate > @earliestDeprecatedDate or LastExcDate > @earliestDeprecatedDate)
	UNION ALL
	Select * from dbo.ExcursionPoints where TagId = @tagId and (FirstExcDate > @earlistDecommissionedDate or LastExcDate > @earlistDecommissionedDate)

--else select * from ExcursionPoints where 1 != 1
PRINT 'spPropagateDeprecatedDecomissioned <<<'

END