CREATE TABLE [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD] (
    [UPLOAD_BY]                NVARCHAR (15)   NOT NULL,
    [VEHICLE_CATEGORY_CODE]    NVARCHAR (50)   NOT NULL,
    [VEHICLE_SUBCATEGORY_CODE] NVARCHAR (50)   NOT NULL,
    [VEHICLE_MERK_CODE]        NVARCHAR (50)   NOT NULL,
    [VEHICLE_MODEL_CODE]       NVARCHAR (50)   NOT NULL,
    [VEHICLE_TYPE_CODE]        NVARCHAR (50)   NOT NULL,
    [VEHICLE_UNIT_CODE]        NVARCHAR (50)   NOT NULL,
    [DESCRIPTION]              NVARCHAR (250)  NOT NULL,
    [ASSET_YEAR]               NVARCHAR (4)    NOT NULL,
    [CONDITION]                NVARCHAR (10)   NOT NULL,
    [BRANCH_CODE]              NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]              NVARCHAR (250)  NOT NULL,
    [CURRENCY_CODE]            NVARCHAR (3)    NOT NULL,
    [EFFECTIVE_DATE]           DATETIME        NOT NULL,
    [ASSET_VALUE]              DECIMAL (18, 2) NOT NULL,
    [DP_PCT]                   DECIMAL (9, 6)  NOT NULL,
    [DP_AMOUNT]                DECIMAL (18, 2) NOT NULL,
    [FINANCING_AMOUNT]         DECIMAL (18, 2) CONSTRAINT [DF_MASTER_VEHICLE_PRICELIST_UPLOAD_FINANCING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [UPLOAD_ID]                NVARCHAR (50)   NOT NULL,
    [UPLOAD_RESULT]            NVARCHAR (4000) NOT NULL,
    [CRE_DATE]                 DATETIME        NOT NULL,
    [CRE_BY]                   NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                 DATETIME        NOT NULL,
    [MOD_BY]                   NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15)   NOT NULL
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD_Insert_Audit] 
			ON [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_UPLOAD]
([UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD_Delete_Audit]    
			ON [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_UPLOAD]
([UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD_Update_Audit]      
			ON [dbo].[MASTER_VEHICLE_PRICELIST_UPLOAD]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([UPLOAD_BY]) THEN '[UPLOAD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_CATEGORY_CODE]) THEN '[VEHICLE_CATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_SUBCATEGORY_CODE]) THEN '[VEHICLE_SUBCATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_MERK_CODE]) THEN '[VEHICLE_MERK_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_MODEL_CODE]) THEN '[VEHICLE_MODEL_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_TYPE_CODE]) THEN '[VEHICLE_TYPE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_UNIT_CODE]) THEN '[VEHICLE_UNIT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([ASSET_YEAR]) THEN '[ASSET_YEAR]-' ELSE '' END + 
CASE WHEN UPDATE([CONDITION]) THEN '[CONDITION]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_CODE]) THEN '[BRANCH_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_NAME]) THEN '[BRANCH_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EFFECTIVE_DATE]) THEN '[EFFECTIVE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([ASSET_VALUE]) THEN '[ASSET_VALUE]-' ELSE '' END + 
CASE WHEN UPDATE([DP_PCT]) THEN '[DP_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([DP_AMOUNT]) THEN '[DP_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([FINANCING_AMOUNT]) THEN '[FINANCING_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([UPLOAD_ID]) THEN '[UPLOAD_ID]-' ELSE '' END + 
CASE WHEN UPDATE([UPLOAD_RESULT]) THEN '[UPLOAD_RESULT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_UPLOAD]
([UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_UPLOAD]
([UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [UPLOAD_BY],[VEHICLE_CATEGORY_CODE],[VEHICLE_SUBCATEGORY_CODE],[VEHICLE_MERK_CODE],[VEHICLE_MODEL_CODE],[VEHICLE_TYPE_CODE],[VEHICLE_UNIT_CODE],[DESCRIPTION],[ASSET_YEAR],[CONDITION],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[UPLOAD_ID],[UPLOAD_RESULT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User yang melakukan proses upload data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'UPLOAD_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'VEHICLE_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode sub kategori atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'VEHICLE_SUBCATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode merk atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'VEHICLE_MERK_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode model atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'VEHICLE_MODEL_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tipe atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'VEHICLE_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode unit atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'VEHICLE_UNIT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tahun pembuatan unit atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'ASSET_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Konsisi atas data master vehicle pricelist upload tersebut - New, menginformasikan bahwa asset tersebut merupakan unit baru - Used, menginformasikan bahwa asset tersebut merupakan unit bekas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'CONDITION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal mulai berlakunya data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'EFFECTIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai asset atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'ASSET_VALUE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai percentage uang muka atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'DP_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai amount atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'DP_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pembiayaan atas data master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'FINANCING_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'User ID pada proses upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'UPLOAD_ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hasil dari proses upload master vehicle pricelist upload tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_UPLOAD', @level2type = N'COLUMN', @level2name = N'UPLOAD_RESULT';

