CREATE TABLE [dbo].[MASTER_INSURANCE_RATE_NON_LIFE] (
    [CODE]                     NVARCHAR (50) NOT NULL,
    [INSURANCE_CODE]           NVARCHAR (50) NOT NULL,
    [COLLATERAL_TYPE_CODE]     NVARCHAR (50) NOT NULL,
    [COLLATERAL_CATEGORY_CODE] NVARCHAR (50) NOT NULL,
    [COVERAGE_CODE]            NVARCHAR (50) NOT NULL,
    [DAY_IN_YEAR]              NVARCHAR (10) NOT NULL,
    [REGION_CODE]              NVARCHAR (50) NULL,
    [OCCUPATION_CODE]          NVARCHAR (50) NULL,
    [IS_ACTIVE]                NVARCHAR (1)  NOT NULL,
    [CRE_DATE]                 DATETIME      NOT NULL,
    [CRE_BY]                   NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15) NOT NULL,
    [MOD_DATE]                 DATETIME      NOT NULL,
    [MOD_BY]                   NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_MASTER_INSURANCE_RATE_NON_LIFE] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_INSURANCE_RATE_NON_LIFE_MASTER_INSURANCE] FOREIGN KEY ([INSURANCE_CODE]) REFERENCES [dbo].[MASTER_INSURANCE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_MASTER_INSURANCE_RATE_NON_LIFE_MASTER_INSURANCE_RATE_NON_LIFE] FOREIGN KEY ([COLLATERAL_CATEGORY_CODE]) REFERENCES [dbo].[MASTER_COLLATERAL_CATEGORY] ([CODE]),
    CONSTRAINT [FK_MASTER_INSURANCE_RATE_NON_LIFE_MASTER_OCCUPATION] FOREIGN KEY ([OCCUPATION_CODE]) REFERENCES [dbo].[MASTER_OCCUPATION] ([CODE]),
    CONSTRAINT [FK_MASTER_INSURANCE_RATE_NON_LIFE_MASTER_REGION] FOREIGN KEY ([REGION_CODE]) REFERENCES [dbo].[MASTER_REGION] ([CODE])
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_Update_Audit]      
			ON [dbo].[MASTER_INSURANCE_RATE_NON_LIFE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_CODE]) THEN '[INSURANCE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COLLATERAL_TYPE_CODE]) THEN '[COLLATERAL_TYPE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COLLATERAL_CATEGORY_CODE]) THEN '[COLLATERAL_CATEGORY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COVERAGE_CODE]) THEN '[COVERAGE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DAY_IN_YEAR]) THEN '[DAY_IN_YEAR]-' ELSE '' END + 
CASE WHEN UPDATE([REGION_CODE]) THEN '[REGION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([OCCUPATION_CODE]) THEN '[OCCUPATION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE]
([CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE]
([CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_Delete_Audit]    
			ON [dbo].[MASTER_INSURANCE_RATE_NON_LIFE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE]
([CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_Insert_Audit] 
			ON [dbo].[MASTER_INSURANCE_RATE_NON_LIFE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE]
([CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[INSURANCE_CODE],[COLLATERAL_TYPE_CODE],[COLLATERAL_CATEGORY_CODE],[COVERAGE_CODE],[DAY_IN_YEAR],[REGION_CODE],[OCCUPATION_CODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master insurance rate non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode maskapai asuransi atas data master insurance rate non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'INSURANCE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tipe collateral atas data master collateral rate non life tersebut - PRTY, menginformasikan bahwa collatreal tersebut bertipe property - VHCL, menginformasikan bahwa collatreal tersebut bertipe vehicle - MCHN, menginformasikan bahwa collatreal tersebut bertipe machinery - HE, menginformasikan bahwa collatreal tersebut bertipe heavy equipment', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'COLLATERAL_TYPE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode kategori collateral atas data master insurance rate non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'COLLATERAL_CATEGORY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage atas data master insurance rate non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari dalam 1 tahun yang digunakan dalam perhitungan rate asuransi non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'DAY_IN_YEAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode region atas data master insurance rate non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'REGION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode okupasi atas data master insurance rate non life tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'OCCUPATION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master insurance rate non life tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

