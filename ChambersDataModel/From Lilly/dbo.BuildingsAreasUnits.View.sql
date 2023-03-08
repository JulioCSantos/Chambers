EXEC sys.sp_dropextendedproperty @name=N'MS_DiagramPaneCount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BuildingsAreasUnits'
GO
EXEC sys.sp_dropextendedproperty @name=N'MS_DiagramPane1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BuildingsAreasUnits'
GO
/****** Object:  View [dbo].[BuildingsAreasUnits]    Script Date: 03/07/2023 00:12:30 ******/
DROP VIEW [dbo].[BuildingsAreasUnits]
GO
/****** Object:  View [dbo].[BuildingsAreasUnits]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BuildingsAreasUnits]
AS
SELECT        BD.lBuildingID, BD.sBuildingName AS Building, AD.lAreaID, AD.sAreaName AS Area, UD.lUnitID, UD.sUnitName AS Unit, TD.lTagID, TD.sTagName AS Tag, TD.sEGU, TD.sTagDesc
FROM            BB50PCS_TRAIN1.dbo.Building_Definitions AS BD INNER JOIN
                         BB50PCS_TRAIN1.dbo.Area_Definitions AS AD ON BD.lBuildingID = AD.lBuildingID INNER JOIN
                         BB50PCS_TRAIN1.dbo.Unit_Definitions AS UD ON AD.lAreaID = UD.lAreaID INNER JOIN
                         BB50PCS_TRAIN1.dbo.Tag_Definitions AS TD ON UD.lUnitID = TD.lUnitID
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "BD"
            Begin Extent = 
               Top = 17
               Left = 22
               Bottom = 172
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AD"
            Begin Extent = 
               Top = 25
               Left = 225
               Bottom = 155
               Right = 446
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UD"
            Begin Extent = 
               Top = 44
               Left = 482
               Bottom = 174
               Right = 660
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TD"
            Begin Extent = 
               Top = 58
               Left = 687
               Bottom = 188
               Right = 857
            End
            DisplayFlags = 280
            TopColumn = 2
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BuildingsAreasUnits'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'BuildingsAreasUnits'
GO
