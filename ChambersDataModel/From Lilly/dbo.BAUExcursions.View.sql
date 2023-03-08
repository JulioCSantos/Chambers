EXEC sys.sp_dropextendedproperty @name=N'MS_DiagramPaneCount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BAUExcursions'
GO
EXEC sys.sp_dropextendedproperty @name=N'MS_DiagramPane1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BAUExcursions'
GO
/****** Object:  View [dbo].[BAUExcursions]    Script Date: 03/07/2023 00:12:30 ******/
DROP VIEW [dbo].[BAUExcursions]
GO
/****** Object:  View [dbo].[BAUExcursions]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[BAUExcursions]
AS
SELECT        BAU.Building, BAU.lAreaID, BAU.lUnitID, BAU.Area, BAU.Unit, EP.TagId, EP.TagName, EP.TagExcNbr, EP.StepLogId, EP.RampInDate, EP.RampInValue, EP.FirstExcDate, EP.FirstExcValue, EP.LastExcDate, 
                         EP.LastExcValue, EP.RampOutDate, EP.RampOutValue, EP.HiPointsCt, EP.LowPointsCt, EP.MinThreshold, EP.MaxThreshold, EP.MinValue, EP.MaxValue, EP.AvergValue, EP.StdDevValue, EP.Duration, 
                         EP.ThresholdDuration, EP.SetPoint, BAU.sTagDesc, BAU.sEGU
						 , STDC.StageDeprecatedDate, STDC.StageDateDeprecatedDate, STDC.ProductionDate
						 , IIF(EP.HiPointsCt > 0,'HI','LOW') AS ExcType
						 , [dbo].[fnToStructDuration](Duration)  as StructDuration
FROM            dbo.BuildingsAreasUnits AS BAU 
				INNER JOIN dbo.ExcursionPoints AS EP ON BAU.lTagID = EP.TagId 
				INNER JOIN dbo.StagesLimitsAndDatesCore as STDC ON STDC.TagId = EP.TagId
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[21] 2[9] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "BAU"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 170
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "EP"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 161
               Right = 434
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BAUExcursions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BAUExcursions'
GO
