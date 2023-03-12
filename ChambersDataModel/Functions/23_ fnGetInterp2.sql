CREATE FUNCTION [dbo].[fnGetInterp2] 
(	
	-- Add the parameters for the function here
	@TagName varchar(255), 
	@StartDate datetime,
	@EndDate datetime,
	@TimeStep time(0)
)
RETURNS @Interop TABLE (tag varchar(255), time datetime2(7), value float NULL
, svalue nvarchar(4000) NULL, status int NULL, timestep time(0))
AS
BEGIN

		INSERT INTO @Interop
		SELECT c.tag, c.time, c.value, NULL as svalue, null as status, @TimeStep as timestep from dbo.CompressedPoints as c
		WHERE tag = @TagName 
		AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		AND value is not NULL
		
		--INSERT INTO @Interop
		--SELECT * from PI.piarchive..piinterp
		--WHERE tag = @TagName 
		--AND time >= FORMAT(@StartDate,'yyyy-MM-dd HH:mm:ss') AND time <= FORMAT(@EndDate,'yyyy-MM-dd HH:mm:ss') 
		--AND value is not NULL
		--AND timestep = @TimeStep;


		--AND timestep = cast(CONCAT('00:00:', @TimeStepInSeconds) as time(0))
		--ORDER BY tag, time asc; THIS DOESN"T WORK.

		--UNIT TESTS
		--SELECT * from [dbo].[fnGetInterp2]('chamber_report_tag_1', '2022-10-31', '2022-11-30','00:00:30')

--INSERT INTO @Interop
--SELECT * FROM OPENQUERY(PI, '
--    SELECT *
--    FROM piarchive..piinterp
--    WHERE tag = ''P_4000_AI_9160_01''
--    AND time BETWEEN ''2022-04-11'' AND ''2022-04-12''
--	AND value is not null
--    AND TimeStep=''10s''
--')


RETURN ; 

END