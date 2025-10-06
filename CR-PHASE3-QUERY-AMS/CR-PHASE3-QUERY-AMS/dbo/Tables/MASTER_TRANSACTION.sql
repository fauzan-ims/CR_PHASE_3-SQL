CREATE TABLE [dbo].[MASTER_TRANSACTION] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [COMPANY_CODE]     NVARCHAR (50)  NOT NULL,
    [TRANSACTION_NAME] NVARCHAR (250) NOT NULL,
    [MODULE_CODE]      NVARCHAR (50)  NOT NULL,
    [MODULE_NAME]      NVARCHAR (250) NOT NULL,
    [API_URL]          NVARCHAR (250) NULL,
    [SP_NAME]          NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]        NVARCHAR (1)   CONSTRAINT [DF_MASTER_TRANSACTION_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_TRANSACTION] PRIMARY KEY CLUSTERED ([CODE] ASC, [COMPANY_CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_TRANSACTION_Delete_Audit]    
			ON [dbo].[MASTER_TRANSACTION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_TRANSACTION_Update_Audit]      
			ON [dbo].[MASTER_TRANSACTION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COMPANY_CODE]) THEN '[COMPANY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([TRANSACTION_NAME]) THEN '[TRANSACTION_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([MODULE_CODE]) THEN '[MODULE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([MODULE_NAME]) THEN '[MODULE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([API_URL]) THEN '[API_URL]-' ELSE '' END + 
CASE WHEN UPDATE([SP_NAME]) THEN '[SP_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_TRANSACTION_Insert_Audit] 
			ON [dbo].[MASTER_TRANSACTION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[TRANSACTION_NAME],[MODULE_CODE],[MODULE_NAME],[API_URL],[SP_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE MODULE (''IFINAMS'', ''IFINOPL'')', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'MODULE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA MODULE (''ASSET MANAGEMENT'', ''OPERATING LEASE'')', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'MODULE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'API_URL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA STORE PROCEDURE', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'SP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AKTIF (1), TIDAK AKTIF(0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

