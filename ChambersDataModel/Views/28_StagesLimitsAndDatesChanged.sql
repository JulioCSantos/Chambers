CREATE VIEW [dbo].[StagesLimitsAndDatesChanged] AS
with SLD as (
Select * from [dbo].[StagesLimitsAndDatesCore] as s1 Where s1.DeprecatedDate is not null or s1.DecommissionedDate is not null
)
, SLD1 as (SELECT * From StagesLimitsAndDatesCore as s2 
where ( s2.TagId in (Select TagId From SLD))
)
SELECT * FROM SLD1
UNION
Select * from SLD
--select * from dbo.StagesLimitsAndDatesChanged 
--order by TagId asc, StageDateId asc