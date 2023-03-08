/****** Object:  StoredProcedure [dbo].[SP_Historian_Get_Alarm_Log_By_Unit]    Script Date: 03/07/2023 00:12:30 ******/
DROP PROCEDURE [dbo].[SP_Historian_Get_Alarm_Log_By_Unit]
GO
/****** Object:  StoredProcedure [dbo].[SP_Historian_Get_Alarm_Log_By_Unit]    Script Date: 03/07/2023 00:12:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_Historian_Get_Alarm_Log_By_Unit]
	 @Unit AS [varchar](MAX)
	,@start_time AS [datetime2]
	,@end_time AS [datetime2]
AS
BEGIN
	SELECT	 [EventID]
			,[sBuildingName]
			,[sAreaName]
			,[sUnitName]
			,[sAlarmName]
			,[lSeverity]
			,[sDescription]
			,[Active]
			,[Acked]
			,[nProcessValue]
			,FORMAT([dEventTime], 'dd-MMM-yyyy HH:mm:ss') AS [dEventTime]
	FROM (
		SELECT   NULL AS [EventID]
				,[Building_Definitions].[sBuildingName]
				,[Area_Definitions].[sAreaName]
				,[Unit_Definitions].[sUnitName]
				,[Alarm_Definitions].[sAlarmName]
				,[Alarm_Definitions].[lSeverity]
				,[Alarm_Definitions].[sDescription]
				,CASE WHEN Alarm_Log.[nAlarmValue] = 1 THEN 1 ELSE 0 END AS [Active]
				,CASE WHEN Alarm_Log.[nAlarmValue] = 1 THEN 0 ELSE 1 END AS [Acked]
				,[Alarm_Log].[nProcessValue]
				,[Alarm_Log].[dEventTime]
				,CASE WHEN [Alarm_Log].[nAlarmValue] = 1 THEN 1 ELSE 3 END AS AlarmState
		FROM [BB50PCS_TRAIN1].[dbo].[Alarm_Definitions]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Alarm_Log] ON [Alarm_Definitions].[lAlarmID] = [Alarm_Log].[lAlarmID]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Unit_Definitions] ON [Alarm_Definitions].[lUnitID] = [Unit_Definitions].[lUnitID]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Area_Definitions] ON [Unit_Definitions].[lAreaID] = [Area_Definitions].[lAreaID]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Building_Definitions] ON [Area_Definitions].[lBuildingID] = [Building_Definitions].[lBuildingID]
		WHERE [Alarm_Log].[dEventTime] >= @start_time
		AND [Alarm_Log].[dEventTime] <= @end_time
		AND [Alarm_Definitions].[lUnitID] IN (
			SELECT [param]
			FROM [fn_MVParam](@Unit, ',')
		)
		UNION
		SELECT	 [AllEvent].[EventID]
				,[Building_Definitions].[sBuildingName]
				,[Area_Definitions].[sAreaName]
				,[Unit_Definitions].[sUnitName]
				,[Alarm_Definitions].[sAlarmName]
				,[Alarm_Definitions].[lSeverity]
				,[Alarm_Definitions].[sDescription]
				,[AllEvent].[Active]
				,[AllEvent].[Acked]
				,NULL
				,dbo.ConvertToLocalTime([AllEvent].[EventTimeStamp])
				,CASE 
					WHEN [AllEvent].[Active] = 1 AND [AllEvent].[Acked] = 1 THEN 2
					WHEN [AllEvent].[Active] = 1 AND [AllEvent].[Acked] = 0 THEN 1
					WHEN [AllEvent].[Active] = 0 AND [AllEvent].[Acked] = 1 THEN 3
					WHEN [AllEvent].[Active] = 0 AND [AllEvent].[Acked] = 0 THEN 4
					ELSE 0
				 END AS [AlarmState]
		FROM [BB50PCS_TRAIN1].[dbo].[Alarm_Definitions]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[AllEvent] ON [Alarm_Definitions].[sAlarmName] = [AllEvent].[SourceName]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Unit_Definitions] ON [Alarm_Definitions].[lUnitID] = [Unit_Definitions].[lUnitID]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Area_Definitions] ON [Unit_Definitions].[lAreaID] = [Area_Definitions].[lAreaID]
		INNER JOIN [BB50PCS_TRAIN1].[dbo].[Building_Definitions] ON [Area_Definitions].lBuildingID = [Building_Definitions].lBuildingID
		WHERE  dbo.ConvertToLocalTime([AllEvent].[EventTimeStamp]) >= @start_time
		AND dbo.ConvertToLocalTime([AllEvent].[EventTimeStamp]) <= @end_time
		AND [Alarm_Definitions].[lUnitID] IN (
			SELECT [param]
			FROM [fn_MVParam](@Unit, ',')
		)
		AND [AllEvent].[ChangeMask] != 8
		GROUP BY [AllEvent].[EventID]
				,[Building_Definitions].[sBuildingName]
				,[Area_Definitions].[sAreaName]
				,[Unit_Definitions].[sUnitName]
				,[Alarm_Definitions].[sAlarmName]
				,[Alarm_Definitions].[lSeverity]
				,[Alarm_Definitions].[sDescription]
				,[AllEvent].[Active]
				,[AllEvent].[Acked]
				,[EventTimeStamp]
				,[AllEvent].[Active]
				,[AllEvent].[Acked]
	) AS [inner_query]
	ORDER BY	 [sBuildingName] ASC
				,[sAreaName] ASC
				,[sUnitName] ASC
				,[dEventTime] ASC
				,[sAlarmName] ASC
END
GO
