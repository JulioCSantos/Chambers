DECLARE @TagId int, @TagName varchar(255);
SELECT TOP 1 @TagId = TD.lTagID,  @TagName = TD.sTagName
from [BB50PCS_TRAIN1].dbo.Tag_Definitions  as TD
JOIN [BB50PCS_TRAIN1].dbo.Unit_Definitions as UD
ON TD.lUnitID = UD.lUnitID
WHERE TD.sTagName = 'ME.P_6000_TI_FRZ25_09';

INSERT INTO [dbo].[Tags] (TagId, TagName)
VALUES (@TagId, @TagName);

--SELECT @TagId = SCOPE_IDENTITY();
DECLARE @StageID int;
INSERT INTO [dbo].[Stages] ([TagId], [StageName],[MinThreshold],[MaxThreshold],[TimeStep],[ThresholdDuration],[SetPoint])
VALUES (@TagId, 'PRODUCTION', -28, -18, 30, 10, -23)
SELECT @StageID = @@Identity;

DECLARE @StageDateID int; 
INSERT INTO [dbo].[StagesDates] ([StageId] ,[StartDate])
SELECT @StageID, '2023-02-10'
SELECT @StageDateID = @@Identity;

INSERT INTO [dbo].[PointsPaces] ([StageDateId], [NextStepStartDate], [StepSizeDays])
     VALUES (@StageDateID, '2023-02-10', 2)

SELECT * from Tags;
SELECT * FROM Stages;
SELECT * FROM StagesDates;
select * FROM [PointsPaces];
--DELETE FROM [PointsPaces];
--DELETE FROM StagesDates;
--DELETE FROM Stages;
--DELETE FROM Tags;
