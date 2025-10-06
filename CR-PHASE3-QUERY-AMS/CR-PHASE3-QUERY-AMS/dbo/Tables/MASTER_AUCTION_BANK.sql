CREATE TABLE [dbo].[MASTER_AUCTION_BANK] (
    [ID]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [AUCTION_CODE]      NVARCHAR (50)  NOT NULL,
    [CURRENCY_CODE]     NVARCHAR (3)   NOT NULL,
    [BANK_CODE]         NVARCHAR (50)  NOT NULL,
    [BANK_NAME]         NVARCHAR (250) NOT NULL,
    [BANK_BRANCH]       NVARCHAR (250) NOT NULL,
    [BANK_ACCOUNT_NO]   NVARCHAR (50)  NOT NULL,
    [BANK_ACCOUNT_NAME] NVARCHAR (250) NOT NULL,
    [IS_DEFAULT]        NVARCHAR (1)   NOT NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_AUCTION_BANK] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_AUCTION_BANK_MASTER_AUCTION] FOREIGN KEY ([AUCTION_CODE]) REFERENCES [dbo].[MASTER_AUCTION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_BANK_Insert_Audit] 
			ON [dbo].[MASTER_AUCTION_BANK]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_BANK]
([ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_BANK_Update_Audit]      
			ON [dbo].[MASTER_AUCTION_BANK]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([AUCTION_CODE]) THEN '[AUCTION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BANK_CODE]) THEN '[BANK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BANK_NAME]) THEN '[BANK_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([BANK_BRANCH]) THEN '[BANK_BRANCH]-' ELSE '' END + 
CASE WHEN UPDATE([BANK_ACCOUNT_NO]) THEN '[BANK_ACCOUNT_NO]-' ELSE '' END + 
CASE WHEN UPDATE([BANK_ACCOUNT_NAME]) THEN '[BANK_ACCOUNT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_DEFAULT]) THEN '[IS_DEFAULT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_BANK]
([ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_BANK]
([ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_BANK_Delete_Audit]    
			ON [dbo].[MASTER_AUCTION_BANK]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_BANK]
([ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[CURRENCY_CODE],[BANK_CODE],[BANK_NAME],[BANK_BRANCH],[BANK_ACCOUNT_NO],[BANK_ACCOUNT_NAME],[IS_DEFAULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N' Kode balai lelang pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'AUCTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode bank pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'BANK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama bank pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'BANK_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang bank pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'BANK_BRANCH';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor rekening bank pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'BANK_ACCOUNT_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama rekening bank pada data bank auction tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'BANK_ACCOUNT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah rekekning bank tersebut merupakan rekening default?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_BANK', @level2type = N'COLUMN', @level2name = N'IS_DEFAULT';

