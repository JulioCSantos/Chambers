/****** Object:  User [BB50PCS\AEG_SQL_Admins]    Script Date: 03/07/2023 00:12:30 ******/
DROP USER [BB50PCS\AEG_SQL_Admins]
GO
/****** Object:  User [BB50PCS\AEG_SQL_Admins]    Script Date: 03/07/2023 00:12:30 ******/
CREATE USER [BB50PCS\AEG_SQL_Admins] FOR LOGIN [BB50PCS\AEG_SQL_Admins]
GO
ALTER ROLE [db_owner] ADD MEMBER [BB50PCS\AEG_SQL_Admins]
GO
