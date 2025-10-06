CREATE TABLE [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD] (
    [RUNNING_NUMBER]   INT           NOT NULL,
    [USER_CODE]        NVARCHAR (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    [PASSWORD_TYPE]    NVARCHAR (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [DATE_CHANGE_PASS] DATETIME      NOT NULL,
    [OLDPASS]          NVARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NEWPASS]          NVARCHAR (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]         DATETIME      NOT NULL,
    [CRE_BY]           NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]         DATETIME      NOT NULL,
    [MOD_BY]           NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
);


GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD_Update_Audit]      
			ON [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([RUNNING_NUMBER]) THEN '[RUNNING_NUMBER]-' ELSE '' END + 
CASE WHEN UPDATE([USER_CODE]) THEN '[USER_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_TYPE]) THEN '[PASSWORD_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([DATE_CHANGE_PASS]) THEN '[DATE_CHANGE_PASS]-' ELSE '' END + 
CASE WHEN UPDATE([OLDPASS]) THEN '[OLDPASS]-' ELSE '' END + 
CASE WHEN UPDATE([NEWPASS]) THEN '[NEWPASS]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_HISTORY_PASSWORD]
([RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_HISTORY_PASSWORD]
([RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD_Insert_Audit] 
			ON [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_HISTORY_PASSWORD]
([RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD_Delete_Audit]    
			ON [dbo].[SYS_COMPANY_USER_HISTORY_PASSWORD]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_COMPANY_USER_HISTORY_PASSWORD]
([RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [RUNNING_NUMBER],[USER_CODE],[PASSWORD_TYPE],[DATE_CHANGE_PASS],[OLDPASS],[NEWPASS],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Running number dari data history password atas data user tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_HISTORY_PASSWORD', @level2type = N'COLUMN', @level2name = N'RUNNING_NUMBER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_HISTORY_PASSWORD', @level2type = N'COLUMN', @level2name = N'USER_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe password yang ada pada data history password tersebut, Login, menginformasikan bahwa data password tersebut merupakan password login, Approval, menginformasikan bahwa data password tersebut merupakan password untuk melakukan proses approval', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_HISTORY_PASSWORD', @level2type = N'COLUMN', @level2name = N'PASSWORD_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukan proses perubahan password user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_HISTORY_PASSWORD', @level2type = N'COLUMN', @level2name = N'DATE_CHANGE_PASS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password user sebelum dilakukan proses perubahan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_HISTORY_PASSWORD', @level2type = N'COLUMN', @level2name = N'OLDPASS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Password user setelah dilakukan proses perubahan ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_COMPANY_USER_HISTORY_PASSWORD', @level2type = N'COLUMN', @level2name = N'NEWPASS';

