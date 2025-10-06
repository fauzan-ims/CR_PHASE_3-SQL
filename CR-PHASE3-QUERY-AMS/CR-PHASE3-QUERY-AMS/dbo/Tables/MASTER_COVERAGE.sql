CREATE TABLE [dbo].[MASTER_COVERAGE] (
    [CODE]                NVARCHAR (50)  NOT NULL,
    [COVERAGE_NAME]       NVARCHAR (250) NOT NULL,
    [COVERAGE_SHORT_NAME] NVARCHAR (250) NOT NULL,
    [IS_MAIN_COVERAGE]    NVARCHAR (1)   NOT NULL,
    [INSURANCE_TYPE]      NVARCHAR (10)  NOT NULL,
    [CURRENCY_CODE]       NVARCHAR (3)   NOT NULL,
    [IS_ACTIVE]           NVARCHAR (1)   CONSTRAINT [DF_MASTER_COVERAGE_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]            DATETIME       NOT NULL,
    [CRE_BY]              NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15)  NOT NULL,
    [MOD_DATE]            DATETIME       NOT NULL,
    [MOD_BY]              NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_COVERAGE] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_COVERAGE_Delete_Audit]    
			ON [dbo].[MASTER_COVERAGE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE]
([CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_COVERAGE_Update_Audit]      
			ON [dbo].[MASTER_COVERAGE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COVERAGE_NAME]) THEN '[COVERAGE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([COVERAGE_SHORT_NAME]) THEN '[COVERAGE_SHORT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_MAIN_COVERAGE]) THEN '[IS_MAIN_COVERAGE]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_TYPE]) THEN '[INSURANCE_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE]
([CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE]
([CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_COVERAGE_Insert_Audit] 
			ON [dbo].[MASTER_COVERAGE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE]
([CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COVERAGE_NAME],[COVERAGE_SHORT_NAME],[IS_MAIN_COVERAGE],[INSURANCE_TYPE],[CURRENCY_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master coverage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama atas data master coverage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'COVERAGE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama Pendek atau singkatan atas data master coverage tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'COVERAGE_SHORT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data coverage tersebut merupakan data main coverage?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'IS_MAIN_COVERAGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe atas data master coverage tersebut - Life, menginformasikan bahwa asuransi tersebut merupakan asuransi jiwa - Non Life, menginformasikan bahwa asuransi tersebut merupakan asuransi non life', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'INSURANCE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe atas data master coverage tersebut - Life, menginformasikan bahwa asuransi tersebut merupakan asuransi jiwa - Non Life, menginformasikan bahwa asuransi tersebut merupakan asuransi non life', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master coverage tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

