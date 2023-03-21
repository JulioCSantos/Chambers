--exec spDriverExcursionsPointsForDate '2023-03-18', '2023-03-22', '15;
--EXEC [dbo].[spPivotExcursionPoints] 'spPivotExcursionPointsTests_HiExcursionWithPrevTagExcNbrTest', '2022-01-01','2022-03-31', 100, 200
EXEC spDriverExcursionsPointsForDate'2023-03-21', '2023-03-24', '15';
