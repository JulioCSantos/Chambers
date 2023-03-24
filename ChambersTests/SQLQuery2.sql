--exec spDriverExcursionsPointsForDate '2023-03-18', '2023-03-22', '15;
--EXEC [dbo].[spPivotExcursionPoints] 'spPivotExcursionPointsTests_HiExcursionWithPrevTagExcNbrTest', '2022-01-01','2022-03-31', 100, 200
--EXEC spDriverExcursionsPointsForDate'2023-01-03', '2023-01-31', '10';
EXEC spDriverExcursionsPointsForDate '2023-02-22', '2023-03-04', '15'
--EXEC spPivotExcursionPoints 15, '2022-02-02', '2022-02-06', NULL, 200, NULL, NULL