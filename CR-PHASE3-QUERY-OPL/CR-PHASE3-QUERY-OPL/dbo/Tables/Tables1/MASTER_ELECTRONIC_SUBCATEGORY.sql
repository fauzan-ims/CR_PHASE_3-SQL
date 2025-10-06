CREATE TABLE [dbo].[MASTER_ELECTRONIC_SUBCATEGORY] (
    [CODE]                     NVARCHAR (50)  NOT NULL,
    [ELECTRONIC_CATEGORY_CODE] NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]              NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]                NVARCHAR (1)   CONSTRAINT [DF_MASTER_ELECTRONIC_SUBCATEGORY_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME       NOT NULL,
    [CRE_BY]                   NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                 DATETIME       NOT NULL,
    [MOD_BY]                   NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_ELECTRONIC_SUBCATEGORY] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_ELECTRONIC_SUBCATEGORY_MASTER_ELECTRONIC_CATEGORY] FOREIGN KEY ([ELECTRONIC_CATEGORY_CODE]) REFERENCES [dbo].[MASTER_ELECTRONIC_CATEGORY] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_ELECTRONIC_SUBCATEGORY_Delete_Audit]    
			ON [dbo].[MASTER_ELECTRONIC_SUBCATEGORY]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_ELECTRONIC_SUBCATEGORY]
([CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_ELECTRONIC_SUBCATEGORY_Insert_Audit] 
			ON [dbo].[MASTER_ELECTRONIC_SUBCATEGORY]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_ELECTRONIC_SUBCATEGORY]
([CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_ELECTRONIC_SUBCATEGORY_Update_Audit]      
			ON [dbo].[MASTER_ELECTRONIC_SUBCATEGORY]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ELECTRONIC_CATEGORY_CODE]) THEN '[ELECTRONIC_CATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ELECTRONIC_SUBCATEGORY]
([CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_ELECTRONIC_SUBCATEGORY]
([CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[ELECTRONIC_CATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master sub kategori elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ELECTRONIC_SUBCATEGORY', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori atas data master sub kategori elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ELECTRONIC_SUBCATEGORY', @level2type = N'COLUMN', @level2name = N'ELECTRONIC_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master sub kategori elektronik tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ELECTRONIC_SUBCATEGORY', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data master sub kategori elektronik tersebut, apakah berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_ELECTRONIC_SUBCATEGORY', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

