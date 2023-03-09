CREATE Function [dbo].[fnGetBAUExcursions](
	@AfterDate DateTime
	, @BeforeDate DateTime
	, @TagIdsList varchar(max)
	, @MinDurationInSecs int 
	, @ActiveOnly int 
)
RETURNS @ExcursionsTbl TABLE (
  Building varchar(50)
, lAreaID int
, lUnitID int
, Area varchar(50) NULL
, Unit varchar(20)
, TagId int NULL
, TagName varchar(255)
, TagExcNbr int
, StepLogId int NULL
, RampInDate datetime NULL
, RampInValue float NULL
, FirstExcDate datetime NULL
, FirstExcValue float NULL
, LastExcDate datetime NULL
, LastExcValue float NULL
, RampOutDate datetime NULL
, RampOutValue float NULL
, HiPointsCt int
, LowPointsCt int
, MinThreshold float NULL
, MaxThreshold float NULL
, MinValue float NULL
, MaxValue float NULL
, AvergValue float NULL
, StdDevValue float NULL
, Duration int NULL
, ThresholdDuration int NULL
, SetPoint float NULL
, sTagDesc varchar(100)
, sEGU varchar(20)
, StageDeprecatedDate datetime NULL
, StageDateDeprecatedDate datetime NULL
, ProductionDate datetime NULL
, ExcType varchar(3)
, StructDuration varchar(20) NULL
, CalcDuration varchar(16) NULL
, StructMinDuration varchar(16) NULL
, OverlapStartDate DateTime NULL
, OverlapEndDate DateTime NULL
, SetPointEGU varchar(255)
)
AS BEGIN

INSERT INTO @ExcursionsTbl
SELECT * 
, [dbo].[fnToStructDuration](COALESCE(@MinDurationInSecs, ThresholdDuration))  as CalcDuration 
, [dbo].[fnToStructDuration](COALESCE(@MinDurationInSecs, ThresholdDuration))  as StructMinDuration
, (SELECT StartDate  FROM [dbo].[fnGetOverlappingDates](@AfterDate, @BeforeDate, FirstExcDate, LastExcDate)) as OverlapStartDate
, (SELECT EndDate  FROM [dbo].[fnGetOverlappingDates](@AfterDate, @BeforeDate, FirstExcDate, LastExcDate)) as OverlapEndDate
, Concat(SetPoint, ' ',sEGU) as SetPointEGU

FROM BAUExcursions
WHERE  
(SELECT StartDate  FROM [dbo].[fnGetOverlappingDates](@AfterDate, @BeforeDate, FirstExcDate, LastExcDate)) IS NOT NULL
AND Duration >= COALESCE(@MinDurationInSecs, ThresholdDuration)
AND (@TagIdsList is null OR TagId in (SELECT value FROM STRING_SPLIT( @TagIdsList, ',')))
AND (@ActiveOnly IS NULL OR (SELECT StartDate  FROM [dbo].[fnGetOverlappingDates]
(FirstExcDate, LastExcDate, ProductionDate, StageDeprecatedDate)) IS NOT NULL);
 
RETURN;

--SELECT * FROM fnGetBAUExcursions('2023-02-01','2023-02-28','14997',10*60, 1);
--SELECT * FROM fnGetBAUExcursions('2023-01-01','2023-02-28','14997, 15767, 16627, 16667',NULL, NULL);
--SELECT * FROM fnGetBAUExcursions('2023-01-01','2023-02-28',NULL,10*60, NULL);
--SELECT * FROM fnGetBAUExcursions('2023-02-01','2023-03-01',NULL, NULL, NULL);
--SELECT * FROM fnGetBAUExcursions('2023-01-01','2023-02-28',NULL, 0, 1);
--SELECT * from  dbo.fnGetOverlappingDates('2023-02-01', '2023-02-28', NULL, NULL) as v;
--SELECT *  FROM [dbo].[fnGetOverlappingDates]('2023-02-01','2023-02-28', '2023-01-01', '2023-03-01')
END