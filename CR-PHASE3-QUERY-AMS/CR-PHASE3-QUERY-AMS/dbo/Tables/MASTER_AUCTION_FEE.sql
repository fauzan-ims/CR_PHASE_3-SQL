CREATE TABLE [dbo].[MASTER_AUCTION_FEE] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [AUCTION_FEE_NAME] NVARCHAR (250) NOT NULL,
    [TRANSACTION_CODE] NVARCHAR (50)  NOT NULL,
    [IS_TAXABLE]       NVARCHAR (1)   NOT NULL,
    [IS_ACTIVE]        NVARCHAR (1)   CONSTRAINT [DF_MASTER_MAK_FEE_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_AUCTION_FEE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_FEE_Update_Audit]      
			ON [dbo].[MASTER_AUCTION_FEE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([AUCTION_FEE_NAME]) THEN '[AUCTION_FEE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TRANSACTION_CODE]) THEN '[TRANSACTION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_TAXABLE]) THEN '[IS_TAXABLE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_FEE]
([CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_FEE]
([CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_FEE_Insert_Audit] 
			ON [dbo].[MASTER_AUCTION_FEE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_FEE]
([CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_FEE_Delete_Audit]    
			ON [dbo].[MASTER_AUCTION_FEE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_FEE]
([CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[AUCTION_FEE_NAME],[TRANSACTION_CODE],[IS_TAXABLE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data master auction fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_FEE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama biaya fee pada data master auction fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_FEE', @level2type = N'COLUMN', @level2name = N'AUCTION_FEE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode general ledger pada data master auction fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_FEE', @level2type = N'COLUMN', @level2name = N'TRANSACTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah biaya fee tersebut akan dikenakan pajak?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_FEE', @level2type = N'COLUMN', @level2name = N'IS_TAXABLE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data master auction fee tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_FEE', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

