/****** Object:  StoredProcedure [dbo].[SP_Historian_Get_Annotations_By_Unit]    Script Date: 03/07/2023 00:12:30 ******/
DROP PROCEDURE [dbo].[SP_Historian_Get_Annotations_By_Unit]
GO
/****** Object:  StoredProcedure [dbo].[SP_Historian_Get_Annotations_By_Unit]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Historian_Get_Annotations_By_Unit]
	 @Unit AS [varchar](MAX)
	,@start_time AS [datetime2]
	,@end_time AS [datetime2]
AS
BEGIN
	DECLARE @unit_table TABLE(
		 unit_id [int]
		,suite [varchar](250)
	);

	INSERT INTO @unit_table (unit_id, suite)
	SELECT   [Unit_Definitions].[lUnitID]
			,[Area_Definitions].[suite_search_designation]
	FROM [BB50PCS_TRAIN1].[dbo].[Unit_Definitions]
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Area_Definitions] ON [Unit_Definitions].[lAreaID] = [Area_Definitions].[lAreaID]
	WHERE lUnitID IN (
		SELECT [param]
		FROM [fn_MVParam](@Unit, ',')
	);

	SELECT   FORMAT(an.dAnnotationTime, 'dd-MMM-yyyy hh:mm:ss tt') AS [dAnnotationTime]
			,FORMAT(an.dEntryTime, 'dd-MMM-yyyy hh:mm:ss tt') AS [dEntryTime]
			,an.performed_by_display_name
			,an.sLotNbr 
			,an.sRunNbr
			,an.sComment
			,an.isDelayed
			,ant.sAnnotationTypeDesc
			,ant.sDisplayColor
			,bd.sBuildingName
			,ad.sAreaName
			,ud.sUnitName
	FROM [BB50PCS_TRAIN1].[dbo].[Annotations] AS an
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[verification_statuses] ON an.verification_status_id = verification_statuses.id
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[AnnotationType] AS ant ON an.lAnnotationTypeID = ant.lAnnotationTypeID
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Unit_Definitions] as ud ON an.lUnitID = ud.lUnitID
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Area_Definitions] as ad ON ud.lAreaID = ad.lAreaID
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Building_Definitions] as bd ON ad.lBuildingID = bd.lBuildingID
	WHERE ud.lUnitID IN (
		SELECT unit_id
		FROM @unit_table
		WHERE suite = 'suite_1'
	)
	AND an.dAnnotationTime BETWEEN @start_time AND @end_time
	AND verification_statuses.key_name = 'approved'
	UNION
	SELECT   FORMAT(an.dAnnotationTime, 'dd-MMM-yyyy hh:mm:ss tt') AS [dAnnotationTime]
			,FORMAT(an.dEntryTime, 'dd-MMM-yyyy hh:mm:ss tt') AS [dEntryTime]
			,an.performed_by_display_name
			,an.sLotNbr 
			,an.sRunNbr
			,an.sComment
			,an.isDelayed
			,ant.sAnnotationTypeDesc
			,ant.sDisplayColor
			,bd.sBuildingName
			,ad.sAreaName
			,ud.sUnitName
	FROM [BB50PCS_TRAIN2].[dbo].[Annotations] AS an
	INNER JOIN [BB50PCS_TRAIN2].[dbo].[verification_statuses] ON an.verification_status_id = verification_statuses.id
	INNER JOIN [BB50PCS_TRAIN2].[dbo].[AnnotationType] AS ant ON an.lAnnotationTypeID = ant.lAnnotationTypeID
	INNER JOIN [BB50PCS_TRAIN2].[dbo].[Unit_Definitions] as ud ON an.lUnitID = ud.lUnitID
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Unit_Definitions] as s1ud ON ud.lUnitID = s1ud.import_id
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Area_Definitions] as ad ON s1ud.lAreaID = ad.lAreaID
	INNER JOIN [BB50PCS_TRAIN1].[dbo].[Building_Definitions] as bd ON ad.lBuildingID = bd.lBuildingID
	WHERE ud.lUnitID IN (
		SELECT [Unit_Definitions].[import_id]
		FROM @unit_table AS [unit_table]
		INNER JOIN BB50PCS_TRAIN1.dbo.Unit_Definitions ON [unit_table].unit_id = Unit_Definitions.lUnitID
		WHERE suite = 'suite_2'
	)
	AND an.dAnnotationTime BETWEEN @start_time AND @end_time
	AND verification_statuses.key_name = 'approved'
	ORDER BY bd.sBuildingName, ad.sAreaName, ud.sUnitName, [dAnnotationTime] asc
END
GO
