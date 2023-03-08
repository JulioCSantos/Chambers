/****** Object:  UserDefinedFunction [BB50PCS\jsantos].[fnGetColumnDefitions]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [BB50PCS\jsantos].[fnGetColumnDefitions]
GO
/****** Object:  UserDefinedFunction [BB50PCS\jsantos].[fnGetColumnDefitions]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--SELECT OBJECT_Name(c.object_id), *  FROM Sys.all_columns as c 
--where OBJECT_Name(c.object_id) = 'fnGetInterp2';
CREATE Function [BB50PCS\jsantos].[fnGetColumnDefitions] (
@TblSchema as varchar(255), @TblName as varchar(255)
)
RETURNS @ColDefTbl TABLE (ColDef varchar(255))
AS BEGIN
	INSERT INTO @ColDefTbl
	SELECT CONCAT(', ',COLUMN_NAME, ' ', Data_Type
	,IIF(Character_Maximum_Length is null,'',CONCAT('(',Character_Maximum_Length,')'))
	,IIF(IS_Nullable = 'YES', ' NULL','')
	) as ColDef
	--, * 
	FROM INFORMATION_SCHEMA.COLUMNS 
	where TABLE_SCHEMA = @TblSchema AND TABLE_NAME = @TblName
	ORDER BY ORDINAL_POSITION;

	RETURN;
END
--SELECT * FROM [fnGetColumnDefitions]('dbo', 'BAUExcursions') 
GO
