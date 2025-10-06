CREATE TABLE [dbo].[MASTER_ITEM_GROUP_GL] (
    [ID]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [COMPANY_CODE]       NVARCHAR (50)  NOT NULL,
    [ITEM_GROUP_CODE]    NVARCHAR (50)  NOT NULL,
    [CURRENCY_CODE]      NVARCHAR (10)  NOT NULL,
    [GL_ASSET_CODE]      NVARCHAR (50)  NOT NULL,
    [GL_ASSET_NAME]      NVARCHAR (250) NOT NULL,
    [GL_ASSET_RENT_CODE] NVARCHAR (50)  NOT NULL,
    [GL_ASSET_RENT_NAME] NVARCHAR (250) NOT NULL,
    [GL_EXPEND_CODE]     NVARCHAR (50)  NOT NULL,
    [GL_INPROGRESS_CODE] NVARCHAR (50)  NOT NULL,
    [CATEGORY]           NVARCHAR (250) NULL,
    [CRE_DATE]           DATETIME       NOT NULL,
    [CRE_BY]             NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)  NOT NULL,
    [MOD_DATE]           DATETIME       NOT NULL,
    [MOD_BY]             NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_ITEM_GROUP_GL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_ITEM_GROUP_GL_Insert_Audit] 
			ON [dbo].[MASTER_ITEM_GROUP_GL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP_GL]
([ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_ITEM_GROUP_GL_Delete_Audit]    
			ON [dbo].[MASTER_ITEM_GROUP_GL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP_GL]
([ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_ITEM_GROUP_GL_Update_Audit]      
			ON [dbo].[MASTER_ITEM_GROUP_GL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([COMPANY_CODE]) THEN '[COMPANY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ITEM_GROUP_CODE]) THEN '[ITEM_GROUP_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([GL_ASSET_CODE]) THEN '[GL_ASSET_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([GL_ASSET_NAME]) THEN '[GL_ASSET_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([GL_ASSET_RENT_CODE]) THEN '[GL_ASSET_RENT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([GL_ASSET_RENT_NAME]) THEN '[GL_ASSET_RENT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([GL_EXPEND_CODE]) THEN '[GL_EXPEND_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([GL_INPROGRESS_CODE]) THEN '[GL_INPROGRESS_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CATEGORY]) THEN '[CATEGORY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP_GL]
([ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP_GL]
([ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[COMPANY_CODE],[ITEM_GROUP_CODE],[CURRENCY_CODE],[GL_ASSET_CODE],[GL_ASSET_NAME],[GL_ASSET_RENT_CODE],[GL_ASSET_RENT_NAME],[GL_EXPEND_CODE],[GL_INPROGRESS_CODE],[CATEGORY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID DATA TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE GROUP ITEM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'ITEM_GROUP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CODE MATA UANG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE ASSET GENERAL LEDGER, DIAMBIL DARI MODULE IFINSYS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'GL_ASSET_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA ASSET GENERAL LEDGER, DIAMBIL DARI MODULE IFINSYS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'GL_ASSET_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE ASSET GENERAL LEDGER RENT, DIAMBIL DARI MODULE IFINSYS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'GL_ASSET_RENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA ASSET GENERAL LEDGER RENT, DIAMBIL DARI MODULE IFINSYS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'GL_ASSET_RENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'GL_EXPEND_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'GL_INPROGRESS_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP_GL', @level2type = N'COLUMN', @level2name = N'CATEGORY';

