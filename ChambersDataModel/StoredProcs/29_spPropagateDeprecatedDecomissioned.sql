CREATE PROCEDURE [dbo].[spPropagateDeprecatedDecomissioned] (       
         @StageDateId int
)
AS
BEGIN
PRINT '>>> spPropagateDeprecatedDecomissioned'
DECLARE @MaximumDate datetime = CAST(GETDATE() AS DATE) ; --zero hour of today's date

DECLARE @TagId int, @TagName varchar(255), @returnValue int = 0, @ThresholdDuration int, @SetPoint float;
SELECT TOP 1 @TagId = TagId, @TagName = sldc.TagName, @ThresholdDuration = sldc.ThresholdDuration, @SetPoint = sldc.SetPoint
FROM StagesLimitsAndDatesCore as sldc
WHERE sldc.StageDateId = @StageDateId and (sldc.DeprecatedDate is not null or sldc.DecommissionedDate is not null)
IF (@TagName IS NULL) BEGIN
       PRINT CONCAT('Deprecated/Decommissions StageDateId not found:', @StageDateId);
       RAISERROR ('StageDateId not found',1,1);
       SET @returnValue = -1;
       GOTO ReturnResult;
END


	PRINT CONCAT('	INPUT: @StageDateId:',@StageDateId);

       -- Finished processed (saved) Excursions in date range
       DECLARE @ExcPointsOutput as TABLE ( ExcPriority int, CycleId int, StageDateId int, TagId int
            , TagName varchar(255), TagExcNbr int
            , RampInDate DateTime, RampInValue float
            , FirstExcDate DateTime, FirstExcValue float
            , LastExcDate DateTime, LastExcValue float
            , RampOutDate DateTime, RampOutValue float
            , HiPointsCt int, LowPointsCt int  
            , LowThreashold float, HiThreashold float
            , MinValue float, MaxValue float
            , AvergValue float, StdDevValue float
            , ThresholdDuration int, SetPoint float);

ReturnResult:
       SELECT 
         [CycleId], [StageDateId], [TagId], [TagName], [TagExcNbr]
         , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
         , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
         , [HiPointsCt], [LowPointsCt],MinValue,  MaxValue
         , [MinValue], [MaxValue], [AvergValue], [StdDevValue]
         , [ThresholdDuration], [SetPoint]
       FROM @ExcPointsOutput 


        PRINT 'spPropagateDeprecatedDecomissioned ends <<<'
        RETURN @returnValue;

END