--exec spDriverExcursionsPointsForDate '2023-03-18', '2023-03-22', '15;
EXEC [dbo].[spPivotExcursionPoints] 'spPivotExcursionPointsTests_HiExcursionWithPrevTagExcNbrTest', '2022-01-01','2022-03-31', 100, 200
--EXEC spDriverExcursionsPointsForDate'2023-03-19', '2023-03-23', '15';
