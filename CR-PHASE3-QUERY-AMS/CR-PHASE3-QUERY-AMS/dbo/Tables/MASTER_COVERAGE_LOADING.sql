CREATE TABLE [dbo].[MASTER_COVERAGE_LOADING] (
    [CODE]           NVARCHAR (50)   NOT NULL,
    [LOADING_NAME]   NVARCHAR (250)  NOT NULL,
    [LOADING_TYPE]   NVARCHAR (10)   NOT NULL,
    [AGE_FROM]       INT             NOT NULL,
    [AGE_TO]         INT             NOT NULL,
    [RATE_TYPE]      NVARCHAR (10)   NOT NULL,
    [BUY_AMOUNT]     DECIMAL (18, 2) NOT NULL,
    [SELL_AMOUNT]    DECIMAL (18, 2) NOT NULL,
    [BUY_RATE_PCT]   DECIMAL (9, 6)  NOT NULL,
    [SALE_RATE_PCT]  DECIMAL (9, 6)  NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)    CONSTRAINT [DF_MASTER_COVERAGE_LOADING_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_INSURANCE_LOADING] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_COVERAGE_LOADING_Update_Audit]      
			ON [dbo].[MASTER_COVERAGE_LOADING]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([LOADING_NAME]) THEN '[LOADING_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([LOADING_TYPE]) THEN '[LOADING_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([AGE_FROM]) THEN '[AGE_FROM]-' ELSE '' END + 
CASE WHEN UPDATE([AGE_TO]) THEN '[AGE_TO]-' ELSE '' END + 
CASE WHEN UPDATE([RATE_TYPE]) THEN '[RATE_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([BUY_AMOUNT]) THEN '[BUY_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([SELL_AMOUNT]) THEN '[SELL_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([BUY_RATE_PCT]) THEN '[BUY_RATE_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([SALE_RATE_PCT]) THEN '[SALE_RATE_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE_LOADING]
([CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE_LOADING]
([CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_COVERAGE_LOADING_Insert_Audit] 
			ON [dbo].[MASTER_COVERAGE_LOADING]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE_LOADING]
([CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_COVERAGE_LOADING_Delete_Audit]    
			ON [dbo].[MASTER_COVERAGE_LOADING]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_COVERAGE_LOADING]
([CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[LOADING_NAME],[LOADING_TYPE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[BUY_AMOUNT],[SELL_AMOUNT],[BUY_RATE_PCT],[SALE_RATE_PCT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master coverage loading tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama atas data master coverage loading tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'LOADING_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe atas data master coverage loading tersebut - Age, menginformasikan bahwa loading tersebut dikenakan berdasarkan usia - Commercial, menginformasikan bahwa loading tersebut dikenakan jika unit tersebut dikomersilkan - Authorized Dealer, menginformasikan bahwa loading tersebut dikenakan jika unit tersebut hanya menggunakan bengkel resmi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'LOADING_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas usia minimal untuk loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'AGE_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas usia maksimal untuk loading asuransi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'AGE_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan biaya loading asuransi tersebut - Amount, menginformasikan loading tersebut dihitung berdasarkan nilai amount - PCT, menginformasikan bahwa loading tersebut dihitung berdasarkan nilai persentase', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'RATE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai beli asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai jual asuransi ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) beli asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'BUY_RATE_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) jual asuransi dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'SALE_RATE_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master coverage loading tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

