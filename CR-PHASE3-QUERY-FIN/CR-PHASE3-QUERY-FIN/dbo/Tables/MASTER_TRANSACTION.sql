CREATE TABLE [dbo].[MASTER_TRANSACTION] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [TRANSACTION_NAME] NVARCHAR (250) NOT NULL,
    [MODULE_NAME]      NVARCHAR (250) NOT NULL,
    [GL_LINK_CODE]     NVARCHAR (50)  CONSTRAINT [DF_MASTER_TRANSACTION_IS_ACTIVE1] DEFAULT ((0)) NOT NULL,
    [IS_CALCULATED]    NVARCHAR (1)   CONSTRAINT [DF_MASTER_TRANSACTION_IS_ACTIVE1_1] DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]        NVARCHAR (1)   CONSTRAINT [DF_MASTER_TRANSACTION_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_TRANSACTION] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_TRANSACTION_JOURNAL_GL_LINK] FOREIGN KEY ([GL_LINK_CODE]) REFERENCES [dbo].[JOURNAL_GL_LINK] ([CODE])
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_TRANSACTION_Insert_Audit] 
			ON [dbo].[MASTER_TRANSACTION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_TRANSACTION_Delete_Audit]    
			ON [dbo].[MASTER_TRANSACTION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_TRANSACTION_Update_Audit]      
			ON [dbo].[MASTER_TRANSACTION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([TRANSACTION_NAME]) THEN '[TRANSACTION_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([MODULE_NAME]) THEN '[MODULE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([GL_LINK_CODE]) THEN '[GL_LINK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_CALCULATED]) THEN '[IS_CALCULATED]-' ELSE '' END + 
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
([CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_TRANSACTION]
([CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[TRANSACTION_NAME],[MODULE_NAME],[GL_LINK_CODE],[IS_CALCULATED],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data master transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama transaksi pada data master transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'TRANSACTION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama modul pada data master transaction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'MODULE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data master transaction tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'GL_LINK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data master transaction tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_CALCULATED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data master transaction tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TRANSACTION', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

