CREATE TABLE [dbo].[MASTER_VEHICLE_PRICELIST] (
    [CODE]                     NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]              NVARCHAR (250) NOT NULL,
    [VEHICLE_CATEGORY_CODE]    NVARCHAR (50)  NOT NULL,
    [VEHICLE_SUBCATEGORY_CODE] NVARCHAR (50)  NOT NULL,
    [VEHICLE_MERK_CODE]        NVARCHAR (50)  NOT NULL,
    [VEHICLE_MODEL_CODE]       NVARCHAR (50)  NOT NULL,
    [VEHICLE_TYPE_CODE]        NVARCHAR (50)  NOT NULL,
    [VEHICLE_UNIT_CODE]        NVARCHAR (50)  NOT NULL,
    [ASSET_YEAR]               NVARCHAR (4)   NOT NULL,
    [CONDITION]                NVARCHAR (10)  NOT NULL,
    [IS_ACTIVE]                NVARCHAR (1)   NOT NULL,
    [CRE_DATE]                 DATETIME       NOT NULL,
    [CRE_BY]                   NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                 DATETIME       NOT NULL,
    [MOD_BY]                   NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_VEHICLE_PRICELIST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_Insert_Audit] 
			ON [dbo].[MASTER_VEHICLE_PRICELIST]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST]
([CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_Delete_Audit]    
			ON [dbo].[MASTER_VEHICLE_PRICELIST]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST]
([CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_Update_Audit]      
			ON [dbo].[MASTER_VEHICLE_PRICELIST]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_CATEGORY_CODE]) THEN '[VEHICLE_CATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_SUBCATEGORY_CODE]) THEN '[VEHICLE_SUBCATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_MERK_CODE]) THEN '[VEHICLE_MERK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_MODEL_CODE]) THEN '[VEHICLE_MODEL_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_TYPE_CODE]) THEN '[VEHICLE_TYPE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_UNIT_CODE]) THEN '[VEHICLE_UNIT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([ASSET_YEAR]) THEN '[ASSET_YEAR]-' ELSE '' END + 
CASE WHEN UPDATE([CONDITION]) THEN '[CONDITION]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST]
([CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST]
([CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[ASSET_YEAR],[CONDITION],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'VEHICLE_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode sub kategori atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'VEHICLE_SUBCATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode merk atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'VEHICLE_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode model atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'VEHICLE_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tipe atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'VEHICLE_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode unit atas data master pricelist vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'VEHICLE_UNIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tahun pembuatan atas asset tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'ASSET_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kondisi atas asset tersebut, - New, menginformasikan bahwa asset tersebut merupakan unit baru - Used, menginformasikan bahwa asset tersebut merupakan unit bekas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'CONDITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master pricelist vehicle tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

