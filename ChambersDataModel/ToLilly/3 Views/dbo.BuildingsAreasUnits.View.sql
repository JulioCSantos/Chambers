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

