CREATE PROCEDURE [dbo].[spPropagateDeprecatedDecomissioned] (       
         @dStageDateId int
)
AS
BEGIN
PRINT '>>> spPropagateDeprecatedDecomissioned'
DECLARE @tagId int, @deprecatedDate dateTime, @decommissionedDate DateTime
select @tagId = TagId, @deprecatedDate = DeprecatedDate, @decommissionedDate = DecommissionedDate 
from [dbo].[StagesLimitsAndDatesCore] where StageDateId = @dStageDateId;
       -- If no Tag details found abort (details are not configured).
       IF (@deprecatedDate is null and @decommissionedDate is null) BEGIN
              PRINT 'a StageDateId that points to a Deprecated or Decommissioned tag must be selected';
              --RETURN -1;
       END;
DECLARE  @stageDateId int, @startDate datetime
select top 1 @stageDateId = StageDateId, @startDate = StartDate
from [dbo].[StagesLimitsAndDatesCore] 
where TagId = @tagId and StageDateId > @dStageDateId
order by StageDateId asc
if (@startDate < @deprecatedDate) Begin
	Select * from dbo.ExcursionPoints where TagId = @tagId and (FirstExcDate > @deprecatedDate or LastExcDate > @deprecatedDate)
end
PRINT 'spPropagateDeprecatedDecomissioned <<<'

END