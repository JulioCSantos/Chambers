﻿--exec spPivotExcursionPoints	'SpPivotExcursionPointsTests_LengthyHiExcursionTest', '2022-02-02', '2022-02-11'
--			, 100, 200, null, null, 120, 150 
--exec spPivotExcursionPoints 'SpPivotExcursionPointsTests_HiExcursionWithPrevTagExcNbrTest', '2022-01-01', '2022-03-31'
--			, 100, 200, null, null, 120, 150 
--EXEC spPivotExcursionPoints 'spPivotExcursionPointsTests_TimeOutTest', '2023-01-02', '2023-03-03', 100, null,null,0.0001