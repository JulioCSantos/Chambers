CREATE PROCEDURE [dbo].[spSeedForTests] 
AS
BEGIN
	SET NOCOUNT ON;

	-----------------------------------------------
	-------- THIS IS NOT AN EMBEDDED RESOURCE - wont be found on test database
	-----------------------------------------------
	
	INSERT INTO [ChambersTests].[dbo].[Tags]
	select * from [ELChambers].[dbo].[Tags];

	SET IDENTITY_INSERT [ChambersTests].[dbo].[Stages] ON;
	INSERT INTO [ChambersTests].[dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint])
	select [StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint] 
		from [ELChambers].[dbo].[Stages]
	SET IDENTITY_INSERT [ChambersTests].[dbo].[Stages] OFF ;

	SET IDENTITY_INSERT [ChambersTests].[dbo].[StagesDates] ON;
	INSERT INTO [ChambersTests].[dbo].[StagesDates] ([StageDateId], [StageId], [StartDate], [EndDate], [DeprecatedDate])
	select [StageDateId], [StageId], [StartDate], [EndDate], [DeprecatedDate] 
		from [ELChambers].[dbo].StagesDates
	SET IDENTITY_INSERT [ChambersTests].[dbo].[StagesDates] OFF ;

END