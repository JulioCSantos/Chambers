/****** Object:  User [Train1User]    Script Date: 03/07/2023 00:12:30 ******/
DROP USER [Train1User]
GO
/****** Object:  User [Train1User]    Script Date: 03/07/2023 00:12:30 ******/
CREATE USER [Train1User] FOR LOGIN [Train1User] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [Train1User]
GO
