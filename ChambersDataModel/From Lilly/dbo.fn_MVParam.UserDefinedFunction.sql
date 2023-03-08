/****** Object:  UserDefinedFunction [dbo].[fn_MVParam]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [dbo].[fn_MVParam]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_MVParam]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_MVParam] (
	@RepParam nvarchar(MAX)
   ,@Delim char(1) = ','
)
RETURNS @Values TABLE ([param] nvarchar(100))AS
BEGIN
  DECLARE @chrind INT
  DECLARE @Piece nvarchar(36)
  SELECT @chrind = 1 

  WHILE @chrind > 0
    BEGIN
      SELECT @chrind = CHARINDEX(@Delim,@RepParam)
      IF @chrind  > 0
        SELECT @Piece = LEFT(@RepParam,@chrind - 1)
      ELSE
        SELECT @Piece = @RepParam
      INSERT @Values([param]) VALUES(CAST(@Piece AS [VARCHAR](100)))
      SELECT @RepParam = RIGHT(@RepParam, LEN(@RepParam) - @chrind)
      IF LEN(@RepParam) = 0 BREAK
	END
RETURN
END
GO
