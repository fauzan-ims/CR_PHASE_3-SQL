CREATE TABLE [dbo].[SYS_ROLE_GROUP] (
    [COMPANY_CODE]     NVARCHAR (50) NOT NULL,
    [CODE]             NVARCHAR (50) NOT NULL,
    [NAME]             NVARCHAR (50) NOT NULL,
    [APPLICATION_CODE] NVARCHAR (2)  NOT NULL,
    [CRE_DATE]         DATETIME      NOT NULL,
    [CRE_BY]           NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15) NOT NULL,
    [MOD_DATE]         DATETIME      NOT NULL,
    [MOD_BY]           NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_SYS_ROLE_GROUP] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_ROLE_GROUP_Insert_Audit] 
			ON [dbo].[SYS_ROLE_GROUP]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_ROLE_GROUP]
([COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_ROLE_GROUP_Delete_Audit]    
			ON [dbo].[SYS_ROLE_GROUP]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_ROLE_GROUP]
([COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_ROLE_GROUP_Update_Audit]      
			ON [dbo].[SYS_ROLE_GROUP]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([COMPANY_CODE]) THEN '[COMPANY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([NAME]) THEN '[NAME]-' ELSE '' END + 
CASE WHEN UPDATE([APPLICATION_CODE]) THEN '[APPLICATION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_ROLE_GROUP]
([COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_ROLE_GROUP]
([COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [COMPANY_CODE],[CODE],[NAME],[APPLICATION_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode grup role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_ROLE_GROUP', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama grup role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_ROLE_GROUP', @level2type = N'COLUMN', @level2name = N'NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode aplikasi atas grup role tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_ROLE_GROUP', @level2type = N'COLUMN', @level2name = N'APPLICATION_CODE';

