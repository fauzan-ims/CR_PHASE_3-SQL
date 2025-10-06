CREATE TABLE [dbo].[MASTER_APPROVAL] (
    [CODE]                        NVARCHAR (50)  NOT NULL,
    [APPROVAL_NAME]               NVARCHAR (250) NOT NULL,
    [REFF_APPROVAL_CATEGORY_CODE] NVARCHAR (50)  NOT NULL,
    [REFF_APPROVAL_CATEGORY_NAME] NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]                   NVARCHAR (1)   CONSTRAINT [DF_MASTER_APPROVAL_CATEGORY_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                    DATETIME       NOT NULL,
    [CRE_BY]                      NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]              NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                    DATETIME       NOT NULL,
    [MOD_BY]                      NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]              NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_APPROVAL_CATEGORY] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_APPROVAL_Delete_Audit]    
			ON [dbo].[MASTER_APPROVAL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_APPROVAL]
([CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_APPROVAL_Update_Audit]      
			ON [dbo].[MASTER_APPROVAL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([APPROVAL_NAME]) THEN '[APPROVAL_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([REFF_APPROVAL_CATEGORY_CODE]) THEN '[REFF_APPROVAL_CATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([REFF_APPROVAL_CATEGORY_NAME]) THEN '[REFF_APPROVAL_CATEGORY_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_APPROVAL]
([CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_APPROVAL]
([CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_APPROVAL_Insert_Audit] 
			ON [dbo].[MASTER_APPROVAL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_APPROVAL]
([CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[APPROVAL_NAME],[REFF_APPROVAL_CATEGORY_CODE],[REFF_APPROVAL_CATEGORY_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master approval category tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPROVAL', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama kategori approval atas data master approval category tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPROVAL', @level2type = N'COLUMN', @level2name = N'APPROVAL_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master approval category tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPROVAL', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

