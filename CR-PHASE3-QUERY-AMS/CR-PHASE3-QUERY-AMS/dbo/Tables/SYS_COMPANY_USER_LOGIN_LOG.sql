CREATE TABLE [dbo].[SYS_COMPANY_USER_LOGIN_LOG] (
    [ID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [USER_CODE]      NVARCHAR (50) NULL,
    [LOGIN_DATE]     DATETIME      NOT NULL,
    [FLAG_CODE]      NVARCHAR (20) NOT NULL,
    [SESSION_ID]     NVARCHAR (50) NOT NULL,
    [CRE_DATE]       DATETIME      NOT NULL,
    [CRE_BY]         NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    [MOD_DATE]       DATETIME      NOT NULL,
    [MOD_BY]         NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_SYS_COMPANY_USER_LOGIN_LOG] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_LOGIN_LOG_Insert_Audit] 
			ON [dbo].[SYS_COMPANY_USER_LOGIN_LOG]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_LOGIN_LOG]
([ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_LOGIN_LOG_Delete_Audit]    
			ON [dbo].[SYS_COMPANY_USER_LOGIN_LOG]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_LOGIN_LOG]
([ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_LOGIN_LOG_Update_Audit]      
			ON [dbo].[SYS_COMPANY_USER_LOGIN_LOG]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([USER_CODE]) THEN '[USER_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([LOGIN_DATE]) THEN '[LOGIN_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([FLAG_CODE]) THEN '[FLAG_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([SESSION_ID]) THEN '[SESSION_ID]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_LOGIN_LOG]
([ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_LOGIN_LOG]
([ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[USER_CODE],[LOGIN_DATE],[FLAG_CODE],[SESSION_ID],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_LOGIN_LOG', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_LOGIN_LOG', @level2type = N'COLUMN', @level2name = N'USER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya proses login oleh user tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_LOGIN_LOG', @level2type = N'COLUMN', @level2name = N'LOGIN_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiipe transaksi pada proses login log atas user tersebut - Login Success, menginformasikan bahwa user tersebut berhasil melakukan proses login - Login Failed, menginformasikan bahwa user tersebut telah gagal melakukan proses login - Logout, menginformasikan bahwa user tersebut telah melakukan proses logout dari sistem - Reset Password, menginformasikan bahwa user tersebut telah melakukan proses reset password, - Forgot Password, menginformasikan bahwa user tersebut telah melakukan proses forgot password', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_LOGIN_LOG', @level2type = N'COLUMN', @level2name = N'FLAG_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Session ID atas data history login log dari data user tersebut ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_LOGIN_LOG', @level2type = N'COLUMN', @level2name = N'SESSION_ID';

