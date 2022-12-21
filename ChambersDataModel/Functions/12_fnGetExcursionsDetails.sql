CREATE FUNCTION [dbo].[fnGetExcursionsDetails] (
      @TagName varchar(255),
      @AfterDate DateTime,
      @BeforeDate DateTime = NULL,
         @MinHiCount int = Null,
      @MinLowCount int = NULL
)
RETURNS @ExcsCounts TABLE ( 
       [CycleId] int NOT NULL,
       [TagId] int NULL, [TagName] [varchar](255) NOT NULL,
       [TagExcNbr] [int] NOT NULL, [StepLogId] int null,
       [RampInDate] [datetime] NULL, [RampInValue] [float] NULL,
       [FirstExcDate] [datetime] NULL, [FirstExcValue] [float] NULL,
       [LastExcDate] [datetime] NULL,     [LastExcValue] [float] NULL,
       [RampOutDate] [datetime] NULL,     [RampOutValue] [float] NULL,
       [HiPointsCt] [int] NOT NULL, [LowPointsCt] [int] NOT NULL,
       [MinValue] [float] NULL, [MaxValue] [float] NULL
       )
AS
BEGIN
INSERT INTO @ExcsCounts
SELECT [CycleId], [TagId], [TagName], [TagExcNbr], [StepLogId]
              , [RampInDate], [RampInValue], [FirstExcDate], [FirstExcValue]
              , [LastExcDate], [LastExcValue], [RampOutDate], [RampOutValue]
              ,[HiPointsCt], [LowPointsCt], [MinValue], [MaxValue]
FROM [dbo].[ExcursionPoints] 
WHERE TagName = @TagName
AND ( @AfterDate  <= RampInDate   AND (@BeforeDate is NULL OR RampOutDate <= @BeforeDate) )
AND ( (HiPointsCt > @MinHiCount OR LowPointsCt > @MinLowCount OR (@MinHiCount IS NULL AND @MinLowCount IS NULL)) );  

RETURN


--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, NULL, NULL); -- returns 0-6
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-03', NULL, NULL, NULL); -- returns 3-6
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', '2022-11-03', NULL, NULL); -- returns 0-2
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, 1, NULL); -- returns  1
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, NULL, 1); -- return 4 & 6
--SELECT * FROM [dbo].[fnGetExcursionsDetails]('chamber_report_tag_1', '2022-11-01', NULL, 0, 0); -- returns 0-6

--TagName     TagExcNbr     RampInDate    RampInValue       FirstExcDate  FirstExcValue LastExcDate   LastExcValue       RampOutDate   RampOutValue  HiPointsCt    LowPointsCt       MinValue      MaxValue
--chamber_report_tag_1      0      2022-11-01 12:00:00.000       197.130004882813     2022-11-01 12:01:00.000       201.427093505859     2022-11-01 12:01:00.000       201.427093505859     2022-11-01 12:02:00.000       199.935562133789     1      0      100    200
--chamber_report_tag_1      1      2022-11-01 12:02:00.000       199.935562133789     2022-11-01 12:03:00.000       205.44514465332      2022-11-01 13:57:00.000       203.805145263672     2022-11-01 13:58:00.000       198.725555419922     115    0      100    200
--chamber_report_tag_1      2      2022-11-01 13:59:00.000       197.867095947266     2022-11-01 14:00:00.000       201.470001220703     2022-11-01 14:00:00.000       201.470001220703     2022-11-01 14:01:00.000       198.994522094727     1      0      100    200
--chamber_report_tag_1      3      2022-11-03 14:32:00.000       100.792404174805     2022-11-03 14:36:00.000       99.1934814453125     2022-11-03 14:36:00.000       99.1934814453125     2022-11-03 14:40:00.000       100.770278930664     0      1      100    200
--chamber_report_tag_1      4      2022-11-03 14:48:00.000       100.151321411133     2022-11-03 14:52:00.000       99.6357345581055     2022-11-04 01:12:00.000       99.7263259887695     2022-11-04 01:16:00.000       100.267868041992     0      156    100    200
--chamber_report_tag_1      5      2022-11-04 01:16:00.000       100.267868041992     2022-11-04 01:20:00.000       99.4152755737305     2022-11-04 01:20:00.000       99.4152755737305     2022-11-04 01:24:00.000       100.35848236084      0      1      100    200
--chamber_report_tag_1      6      2022-11-04 01:24:00.000       100.35848236084      2022-11-04 01:28:00.000       99.9224014282227     2022-11-04 01:32:00.000       99.641960144043      2022-11-04 01:36:00.000       100.432075500488     0      2      100    200

END