CREATE TABLE [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO] (
    [CLIENT_CODE]         NVARCHAR (50) NOT NULL,
    [BRANCH_CODE]         NVARCHAR (50) NOT NULL,
    [RUNNING_CLIENT_CODE] NVARCHAR (10) NOT NULL,
    [RUNNING_CLIENT_NO]   NVARCHAR (10) NOT NULL,
    [CRE_DATE]            DATETIME      NOT NULL,
    [CRE_BY]              NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    [MOD_DATE]            DATETIME      NOT NULL,
    [MOD_BY]              NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15) NOT NULL
);


GO
    
			CREATE TRIGGER [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO_Insert_Audit] 
			ON [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_CLIENT_RUNNING_AGREEMENT_NO]
([CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO_Update_Audit]      
			ON [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CLIENT_CODE]) THEN '[CLIENT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_CODE]) THEN '[BRANCH_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([RUNNING_CLIENT_CODE]) THEN '[RUNNING_CLIENT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([RUNNING_CLIENT_NO]) THEN '[RUNNING_CLIENT_NO]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_CLIENT_RUNNING_AGREEMENT_NO]
([CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_CLIENT_RUNNING_AGREEMENT_NO]
([CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO_Delete_Audit]    
			ON [dbo].[SYS_CLIENT_RUNNING_AGREEMENT_NO]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_CLIENT_RUNNING_AGREEMENT_NO]
([CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CLIENT_CODE],[BRANCH_CODE],[RUNNING_CLIENT_CODE],[RUNNING_CLIENT_NO],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_CLIENT_RUNNING_AGREEMENT_NO', @level2type = N'COLUMN', @level2name = N'CLIENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_CLIENT_RUNNING_AGREEMENT_NO', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode running number atas client tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_CLIENT_RUNNING_AGREEMENT_NO', @level2type = N'COLUMN', @level2name = N'RUNNING_CLIENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Running number atas data client tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_CLIENT_RUNNING_AGREEMENT_NO', @level2type = N'COLUMN', @level2name = N'RUNNING_CLIENT_NO';

