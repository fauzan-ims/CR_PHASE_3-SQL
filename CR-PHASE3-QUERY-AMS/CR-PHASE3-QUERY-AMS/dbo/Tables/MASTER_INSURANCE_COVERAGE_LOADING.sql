CREATE TABLE [dbo].[MASTER_INSURANCE_COVERAGE_LOADING] (
    [ID]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [INSURANCE_COVERAGE_CODE] NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [LOADING_CODE]            NVARCHAR (50)   NOT NULL,
    [AGE_FROM]                INT             NULL,
    [AGE_TO]                  INT             NULL,
    [RATE_TYPE]               NVARCHAR (10)   NULL,
    [RATE_PCT]                DECIMAL (9, 6)  NULL,
    [RATE_AMOUNT]             DECIMAL (18, 2) NULL,
    [LOADING_TYPE]            NVARCHAR (10)   NULL,
    [BUY_RATE_PCT]            DECIMAL (9, 6)  NULL,
    [BUY_RATE_AMOUNT]         DECIMAL (18, 2) NULL,
    [IS_ACTIVE]               NVARCHAR (1)    CONSTRAINT [DF_MASTER_INSURANCE_COVERAGE_LOADING_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                DATETIME        NOT NULL,
    [CRE_BY]                  NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    [MOD_DATE]                DATETIME        NOT NULL,
    [MOD_BY]                  NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]          NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_INSURANCE_COVERAGE_LOADING] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_INSURANCE_COVERAGE_LOADING_MASTER_COVERAGE_LOADING] FOREIGN KEY ([LOADING_CODE]) REFERENCES [dbo].[MASTER_COVERAGE_LOADING] ([CODE]),
    CONSTRAINT [FK_MASTER_INSURANCE_COVERAGE_LOADING_MASTER_INSURANCE_COVERAGE] FOREIGN KEY ([INSURANCE_COVERAGE_CODE]) REFERENCES [dbo].[MASTER_INSURANCE_COVERAGE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_COVERAGE_LOADING_Update_Audit]      
			ON [dbo].[MASTER_INSURANCE_COVERAGE_LOADING]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([INSURANCE_COVERAGE_CODE]) THEN '[INSURANCE_COVERAGE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([LOADING_CODE]) THEN '[LOADING_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([AGE_FROM]) THEN '[AGE_FROM]-' ELSE '' END + 
CASE WHEN UPDATE([AGE_TO]) THEN '[AGE_TO]-' ELSE '' END + 
CASE WHEN UPDATE([RATE_TYPE]) THEN '[RATE_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([RATE_PCT]) THEN '[RATE_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([RATE_AMOUNT]) THEN '[RATE_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([LOADING_TYPE]) THEN '[LOADING_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([BUY_RATE_PCT]) THEN '[BUY_RATE_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([BUY_RATE_AMOUNT]) THEN '[BUY_RATE_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_COVERAGE_LOADING]
([ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_COVERAGE_LOADING]
([ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_COVERAGE_LOADING_Insert_Audit] 
			ON [dbo].[MASTER_INSURANCE_COVERAGE_LOADING]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_COVERAGE_LOADING]
([ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_COVERAGE_LOADING_Delete_Audit]    
			ON [dbo].[MASTER_INSURANCE_COVERAGE_LOADING]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_COVERAGE_LOADING]
([ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[INSURANCE_COVERAGE_CODE],[LOADING_CODE],[AGE_FROM],[AGE_TO],[RATE_TYPE],[RATE_PCT],[RATE_AMOUNT],[LOADING_TYPE],[BUY_RATE_PCT],[BUY_RATE_AMOUNT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode coverage asuransi atas data master insurance coverage loading tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'INSURANCE_COVERAGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode loading atas data master insurance coverage loading tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'LOADING_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas usia minimal untuk dikenakan loading tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'AGE_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas usia maksimal untuk dikenakan loading tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'AGE_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan atas data master insurance coverage loading tersebut - Amount, menginformasikan bahwa perhitungan biaya loading asuransi tersebut berdasarkan nilai amount - PCT, menginformasikan bahwa perhitungan biaya loading asuransi tersebut berdasarkan nilai rate persentase ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'RATE_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) jual loading asuransi tersebut ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'RATE_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai (amount) jual loading asuransi tersebut ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'RATE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe atas data master insurance coverage loading tersebut - Age, menginformasikan bahwa loading tersebut dikenakan berdasarkan usia - Commercial, menginformasikan bahwa loading tersebut dikenakan jika unit tersebut dikomersilkan - Authorized Dealer, menginformasikan bahwa loading tersebut dikenakan jika unit tersebut hanya menggunakan bengkel resmi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'LOADING_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) beli loading asuransi tersebut dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'BUY_RATE_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai (amount) beli loading asuransi tersebut dari maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'BUY_RATE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data master insurance coverage loading tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_COVERAGE_LOADING', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

