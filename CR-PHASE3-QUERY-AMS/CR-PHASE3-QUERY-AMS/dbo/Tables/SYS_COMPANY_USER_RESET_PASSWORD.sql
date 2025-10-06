CREATE TABLE [dbo].[SYS_COMPANY_USER_RESET_PASSWORD] (
    [CODE]           NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [REQUEST_DATE]   DATETIME        NOT NULL,
    [USER_CODE]      NVARCHAR (50)   NULL,
    [PASSWORD_TYPE]  NVARCHAR (10)   NOT NULL,
    [NEW_PASSWORD]   NVARCHAR (20)   NOT NULL,
    [REMARKS]        NVARCHAR (4000) NOT NULL,
    [STATUS]         NVARCHAR (10)   NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SYS_COMPANY_USER_RESET_PASSWORD] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_RESET_PASSWORD_Delete_Audit]    
			ON [dbo].[SYS_COMPANY_USER_RESET_PASSWORD]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_RESET_PASSWORD]
([CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_RESET_PASSWORD_Insert_Audit] 
			ON [dbo].[SYS_COMPANY_USER_RESET_PASSWORD]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_RESET_PASSWORD]
([CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_RESET_PASSWORD_Update_Audit]      
			ON [dbo].[SYS_COMPANY_USER_RESET_PASSWORD]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([REQUEST_DATE]) THEN '[REQUEST_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([USER_CODE]) THEN '[USER_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_TYPE]) THEN '[PASSWORD_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([NEW_PASSWORD]) THEN '[NEW_PASSWORD]-' ELSE '' END + 
CASE WHEN UPDATE([REMARKS]) THEN '[REMARKS]-' ELSE '' END + 
CASE WHEN UPDATE([STATUS]) THEN '[STATUS]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_RESET_PASSWORD]
([CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_RESET_PASSWORD]
([CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[REQUEST_DATE],[USER_CODE],[PASSWORD_TYPE],[NEW_PASSWORD],[REMARKS],[STATUS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode data reset password', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal request dilakukan proses reset password', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'REQUEST_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode user yang dilakukan proses reset password', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'USER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe password yang akan dilakukan proses reset, Login, menginformasikan bahwa password yang akan dilakukan proses reset adalah password untuk proses login,  Approval, menginformasikan bahwa password yang akan dilakukan proses reset adalah password untuk proses approval', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'PASSWORD_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password yang baru setelah dilakukan proses reset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'NEW_PASSWORD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catatan pada proses reset password tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'REMARKS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari proses reset password tersebut - Hold, menginformasikan bahwa data reset password yang telah dilakukan oleh user belum di proses - Post, menginformasikan bahwa proses reser password yang telah dilakukan oleh user telah dilakukan proses posting', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_RESET_PASSWORD', @level2type = N'COLUMN', @level2name = N'STATUS';

