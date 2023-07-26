--exec spDriverExcursionsPointsForDate '2023-03-18', '2023-03-22', '15;
--EXEC [dbo].[spPivotExcursionPoints] 'spPivotExcursionPointsTests_HiExcursionWithPrevTagExcNbrTest', '2022-01-01','2022-03-31', 100, 200
--EXEC spPivotExcursionPoints 15, '2022-02-02', '2022-02-06', NULL, 200, NULL, NULL
--EXEC spDriverExcursionsPointsForDate '2022-09-06', '2022-09-13', '15'
EXEC spDriverExcursionsPointsForDate '7/14/2023', '7/31/2023', '15';
--EXEC spPivotExcursionPoints 15, '2023-02-24', '2023-02-28', 100, 200, null;


