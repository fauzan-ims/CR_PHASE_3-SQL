CREATE TABLE [dbo].[MASTER_AUCTION_DOCUMENT] (
    [ID]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [AUCTION_CODE]   NVARCHAR (50)  NOT NULL,
    [DOCUMENT_CODE]  NVARCHAR (50)  NOT NULL,
    [DOCUMENT_NAME]  NVARCHAR (250) NOT NULL,
    [FILE_NAME]      NVARCHAR (250) NULL,
    [PATHS]          NVARCHAR (250) NULL,
    [IS_REQUIRED]    NVARCHAR (1)   NOT NULL,
    [IS_LATEST]      NVARCHAR (1)   NOT NULL,
    [EXPIRED_DATE]   DATETIME       NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_AUCTION_DOCUMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_AUCTION_DOCUMENT_MASTER_AUCTION] FOREIGN KEY ([AUCTION_CODE]) REFERENCES [dbo].[MASTER_AUCTION] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_DOCUMENT_Update_Audit]      
			ON [dbo].[MASTER_AUCTION_DOCUMENT]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([AUCTION_CODE]) THEN '[AUCTION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DOCUMENT_CODE]) THEN '[DOCUMENT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DOCUMENT_NAME]) THEN '[DOCUMENT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([FILE_NAME]) THEN '[FILE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([PATHS]) THEN '[PATHS]-' ELSE '' END + 
CASE WHEN UPDATE([IS_REQUIRED]) THEN '[IS_REQUIRED]-' ELSE '' END + 
CASE WHEN UPDATE([IS_LATEST]) THEN '[IS_LATEST]-' ELSE '' END + 
CASE WHEN UPDATE([EXPIRED_DATE]) THEN '[EXPIRED_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_DOCUMENT]
([ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_DOCUMENT]
([ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_DOCUMENT_Delete_Audit]    
			ON [dbo].[MASTER_AUCTION_DOCUMENT]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_DOCUMENT]
([ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_AUCTION_DOCUMENT_Insert_Audit] 
			ON [dbo].[MASTER_AUCTION_DOCUMENT]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_AUCTION_DOCUMENT]
([ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[AUCTION_CODE],[DOCUMENT_CODE],[DOCUMENT_NAME],[FILE_NAME],[PATHS],[IS_REQUIRED],[IS_LATEST],[EXPIRED_DATE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode balai lelang pada data dokumen balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'AUCTION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode dokumen pada data dokumen balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dokumen pada data dokumen balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'DOCUMENT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama file yang diupload pada data dokumen balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'FILE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama folder file yang diupload pada data dokumen balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'PATHS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah dokumen tersebut bersifat mandatory?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'IS_REQUIRED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah dokumen tersebut merupakan dokumen terakhir?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'IS_LATEST';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal kadaluwarsa pada data dokumen balai lelang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_AUCTION_DOCUMENT', @level2type = N'COLUMN', @level2name = N'EXPIRED_DATE';

