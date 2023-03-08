/****** Object:  UserDefinedFunction [dbo].[fn_SplitJoin]    Script Date: 03/07/2023 00:12:30 ******/
DROP FUNCTION [dbo].[fn_SplitJoin]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SplitJoin]    Script Date: 03/07/2023 00:12:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:          Julio
-- Create date: 
-- Description:     
-- =============================================
CREATE FUNCTION [dbo].[fn_SplitJoin] 
(
       -- Add the parameters for the function here
       @StringWithDelimiters varchar(MAX)
       , @Delimiter char(1) = ','
       , @Prefix varchar(MAX) = ''
       , @Sufix varchar(MAX) = ''
       , @NewDelimiter varchar(MAX) = NULL
)
RETURNS varchar(MAX)
AS
BEGIN
       -- Declare the return variable here
       DECLARE @Result varchar(MAX) = '';

       DECLARE @Temp varchar(MAX) = NULL;


       -- Add the T-SQL statements to compute the return value here
    
       if len(@StringWithDelimiters)<1 or @StringWithDelimiters is NULL  return NULL;     
   
    if (len(@NewDelimiter)<1 or @NewDelimiter is NULL) SET @NewDelimiter = @Delimiter;
       declare @idx int = 1;     
       declare @slice varchar(8000);

       while @idx!= 0     
       begin     
             set @idx = charindex(@Delimiter,@StringWithDelimiters)     
             if (@idx!=0) BEGIN 
                    set @slice =left(@StringWithDelimiters,@idx - 1); 
                    set @StringWithDelimiters = right(@StringWithDelimiters,len(@StringWithDelimiters) - @idx)
             END    
             ELSE BEGIN    
                    set @slice = @StringWithDelimiters;
                    set @StringWithDelimiters = '';
             END
             
             if(len(@slice)>0) SET @Result =  @Result +  @Prefix + @Slice + @Sufix ;

             --set @StringWithDelimiters = right(@StringWithDelimiters,len(@StringWithDelimiters) - @idx)     
             if (len(@StringWithDelimiters) = 0)  break; 
             ELSE SET @Result = @Result +  @NewDelimiter;    
       end 
       
       -- Return the result of the function
       RETURN @Result

END

--DECLARE @Actual varchar(1000), @Expected varchar(1000);

--select [dbo].[fn_SplitJoin]('P_4000_AI_9160_01,P_4000_AI_9160_02',',','','',' - ') 
----SET @Expected = 'P_4000_AI_9160_01 - P_4000_AI_9160_02'

--select dbo.fn_SplitJoin('P_4000_AI_9160_01,P_4000_AI_9160_02',',','''','''',', '); 
--SET @Expected = 'P_4000_AI_9160_01', 'P_4000_AI_9160_02';


--IF (@Actual != @Expected) Raiserror(@Actual, 16, 1)
--ELSE Print('Test passed');


GO
