CREATE TABLE [dbo].[MASTER_ITEM_GROUP] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [COMPANY_CODE]     NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]      NVARCHAR (250) NOT NULL,
    [GROUP_LEVEL]      INT            NOT NULL,
    [PARENT_CODE]      NVARCHAR (50)  NOT NULL,
    [TRANSACTION_TYPE] NVARCHAR (20)  NULL,
    [IS_ACTIVE]        NVARCHAR (1)   NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_ITEM_GROUP_1] PRIMARY KEY CLUSTERED ([CODE] ASC, [COMPANY_CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_ITEM_GROUP_Insert_Audit] 
			ON [dbo].[MASTER_ITEM_GROUP]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP]
([CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_ITEM_GROUP_Delete_Audit]    
			ON [dbo].[MASTER_ITEM_GROUP]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP]
([CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_ITEM_GROUP_Update_Audit]      
			ON [dbo].[MASTER_ITEM_GROUP]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COMPANY_CODE]) THEN '[COMPANY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([GROUP_LEVEL]) THEN '[GROUP_LEVEL]-' ELSE '' END + 
CASE WHEN UPDATE([PARENT_CODE]) THEN '[PARENT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([TRANSACTION_TYPE]) THEN '[TRANSACTION_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP]
([CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ITEM_GROUP]
([CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[DESCRIPTION],[GROUP_LEVEL],[PARENT_CODE],[TRANSACTION_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DESKRIPSI TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LEVEL GROUP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'GROUP_LEVEL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PARENT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'PARENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'TRANSACTION_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AKTIF (1) TIDAK AKTIF (0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ITEM_GROUP', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

