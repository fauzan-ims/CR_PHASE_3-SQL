CREATE TABLE [dbo].[MASTER_MACHINERY_MODEL] (
    [CODE]                       NVARCHAR (50)  NOT NULL,
    [MACHINERY_MERK_CODE]        NVARCHAR (50)  NOT NULL,
    [MACHINERY_SUBCATEGORY_CODE] NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]                NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]                  NVARCHAR (1)   NOT NULL,
    [CRE_DATE]                   DATETIME       NOT NULL,
    [CRE_BY]                     NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]             NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                   DATETIME       NOT NULL,
    [MOD_BY]                     NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]             NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_MACHINERY_MODEL] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_MACHINERY_MODEL_MASTER_MACHINERY_MERK] FOREIGN KEY ([MACHINERY_MERK_CODE]) REFERENCES [dbo].[MASTER_MACHINERY_MERK] ([CODE]),
    CONSTRAINT [FK_MASTER_MACHINERY_MODEL_MASTER_MACHINERY_SUBCATEGORY] FOREIGN KEY ([MACHINERY_SUBCATEGORY_CODE]) REFERENCES [dbo].[MASTER_MACHINERY_SUBCATEGORY] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_MACHINERY_MODEL_Delete_Audit]    
			ON [dbo].[MASTER_MACHINERY_MODEL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_MACHINERY_MODEL]
([CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_MACHINERY_MODEL_Insert_Audit] 
			ON [dbo].[MASTER_MACHINERY_MODEL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_MACHINERY_MODEL]
([CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_MACHINERY_MODEL_Update_Audit]      
			ON [dbo].[MASTER_MACHINERY_MODEL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([MACHINERY_MERK_CODE]) THEN '[MACHINERY_MERK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([MACHINERY_SUBCATEGORY_CODE]) THEN '[MACHINERY_SUBCATEGORY_CODE]-' ELSE '' END + 
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
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_MACHINERY_MODEL]
([CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_MACHINERY_MODEL]
([CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[MACHINERY_MERK_CODE],[MACHINERY_SUBCATEGORY_CODE],[DESCRIPTION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master model machinery tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_MACHINERY_MODEL', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode merk atas data master model machinery tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_MACHINERY_MODEL', @level2type = N'COLUMN', @level2name = N'MACHINERY_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode sub kategori atas data master model machinery tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_MACHINERY_MODEL', @level2type = N'COLUMN', @level2name = N'MACHINERY_SUBCATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master model machinery tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_MACHINERY_MODEL', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data master model machinery tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_MACHINERY_MODEL', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

