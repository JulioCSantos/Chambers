/****** Object:  UserDefinedFunction [dbo].[fnMultiValueParamToTable]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [dbo].[fnMultiValueParamToTable]
GO
/****** Object:  UserDefinedFunction [dbo].[fnMultiValueParamToTable]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnMultiValueParamToTable] (
	@RepParam nvarchar(MAX)
   ,@Delim char(1) = ','
)
RETURNS @Values TABLE ([Value] nvarchar(max))AS
BEGIN
	IF (LEN(@RepParam) <> 0 AND @Delim Is NOT NULL) 
		INSERT INTO @Values
		SELECT * FROM STRING_SPLIT(@RepParam,@Delim);
 
RETURN
END
--Select * From Tags WHERE TagId in (Select * from [fnMultiValueParamToTable]('14997,15767',','));
--Select * from [fnMultiValueParamToTable]('r1,r2',',');

--Select * from [fnMultiValueParamToTable]('r1',',');
--Select count(*) from [fnMultiValueParamToTable]('',',');
--Select * from [fnMultiValueParamToTable](NULL,',');
GO
