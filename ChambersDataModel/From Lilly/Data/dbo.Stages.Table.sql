
SET IDENTITY_INSERT [dbo].[Stages] ON 

INSERT [dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint]) VALUES (9, 15767, N'PRODUCTION', 100, 200, 5, CAST(N'2022-10-01T00:00:00.000' AS DateTime), CAST(N'2022-12-01T00:00:00.000' AS DateTime), 600, 150)
INSERT [dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint]) VALUES (10, 18932, N'PRODUCTION', 100, 200, 5, CAST(N'2022-10-01T00:00:00.000' AS DateTime), NULL, 600, 150)
INSERT [dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint]) VALUES (11, 16667, N'PRODUCTION', 100, 200, 5, CAST(N'2023-01-01T00:00:00.000' AS DateTime), NULL, 600, 150)
INSERT [dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint]) VALUES (12, 14997, N'PRODUCTION', -25, -15, 30, CAST(N'2023-01-01T00:00:00.000' AS DateTime), NULL, 600, -20)
INSERT [dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint]) VALUES (13, 16627, N'PRODUCTION', -80, -60, 30, CAST(N'2023-01-01T00:00:00.000' AS DateTime), NULL, 1200, -70)
INSERT [dbo].[Stages] ([StageId], [TagId], [StageName], [MinThreshold], [MaxThreshold], [TimeStep], [ProductionDate], [DeprecatedDate], [ThresholdDuration], [SetPoint]) VALUES (14, 16681, N'PRODUCTION', -28, -18, 30, CAST(N'2023-01-01T00:00:00.000' AS DateTime), NULL, 1800, -23)
SET IDENTITY_INSERT [dbo].[Stages] OFF
