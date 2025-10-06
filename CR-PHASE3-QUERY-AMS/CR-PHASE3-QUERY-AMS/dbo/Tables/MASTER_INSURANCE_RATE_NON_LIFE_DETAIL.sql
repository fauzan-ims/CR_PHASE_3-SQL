CREATE TABLE [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL] (
    [ID]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [RATE_NON_LIFE_CODE] NVARCHAR (50)   NOT NULL,
    [SUM_INSURED_FROM]   DECIMAL (18, 2) NOT NULL,
    [SUM_INSURED_TO]     DECIMAL (18, 2) NOT NULL,
    [IS_COMMERCIAL]      NVARCHAR (1)    CONSTRAINT [DF_MASTER_INSURANCE_RATE_NON_LIFE_DETAIL_IS_COMMERCIAL] DEFAULT ((0)) NOT NULL,
    [IS_AUTHORIZED]      NVARCHAR (1)    CONSTRAINT [DF_MASTER_INSURANCE_RATE_NON_LIFE_DETAIL_IS_AUTHORIZED] DEFAULT ((0)) NOT NULL,
    [CALCULATE_BY]       NVARCHAR (10)   NOT NULL,
    [BUY_RATE]           DECIMAL (9, 6)  NOT NULL,
    [SELL_RATE]          DECIMAL (9, 6)  NOT NULL,
    [BUY_AMOUNT]         DECIMAL (18, 2) NOT NULL,
    [SELL_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [DISCOUNT_PCT]       DECIMAL (9, 6)  NOT NULL,
    [CRE_DATE]           DATETIME        NOT NULL,
    [CRE_BY]             NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    [MOD_DATE]           DATETIME        NOT NULL,
    [MOD_BY]             NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_SYS_INSURANCE_RATE_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]
([ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([RATE_NON_LIFE_CODE]) THEN '[RATE_NON_LIFE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([SUM_INSURED_FROM]) THEN '[SUM_INSURED_FROM]-' ELSE '' END + 
CASE WHEN UPDATE([SUM_INSURED_TO]) THEN '[SUM_INSURED_TO]-' ELSE '' END + 
CASE WHEN UPDATE([IS_COMMERCIAL]) THEN '[IS_COMMERCIAL]-' ELSE '' END + 
CASE WHEN UPDATE([IS_AUTHORIZED]) THEN '[IS_AUTHORIZED]-' ELSE '' END + 
CASE WHEN UPDATE([CALCULATE_BY]) THEN '[CALCULATE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([BUY_RATE]) THEN '[BUY_RATE]-' ELSE '' END + 
CASE WHEN UPDATE([SELL_RATE]) THEN '[SELL_RATE]-' ELSE '' END + 
CASE WHEN UPDATE([BUY_AMOUNT]) THEN '[BUY_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([SELL_AMOUNT]) THEN '[SELL_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([DISCOUNT_PCT]) THEN '[DISCOUNT_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]
([ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]
([ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_INSURANCE_RATE_NON_LIFE_DETAIL]
([ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[RATE_NON_LIFE_CODE],[SUM_INSURED_FROM],[SUM_INSURED_TO],[IS_COMMERCIAL],[IS_AUTHORIZED],[CALCULATE_BY],[BUY_RATE],[SELL_RATE],[BUY_AMOUNT],[SELL_AMOUNT],[DISCOUNT_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode rate non life atas data master insurance rate non life detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'RATE_NON_LIFE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah nilai yang dicover oleh maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas nilai yang dicover oleh maskapai asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'SUM_INSURED_TO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah rate asuransi tersebut untuk unit yang bertipe commercial?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_COMMERCIAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah rate asuransi tersebut untuk unit yang diservice di bengkel resmi?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_AUTHORIZED';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan dari data master insurance rate non life detail tersebut - PCT, menginformasikan bahwa perhitungan rate asuransi tersebut dihitung berdasarkan persentase - Amount, menginformasikan bahwa perhitungan rate asuransi tersebut dihitung berdasarkan nilai amount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'CALCULATE_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) beli asuransi dari maskapai', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'BUY_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) jual asuransi ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'SELL_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai (amount) beli asuransi dari maskapai', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'BUY_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai (amount) jual asuransi ke client', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'SELL_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate (persentase) diskon atas data master insurance rate non life detail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_INSURANCE_RATE_NON_LIFE_DETAIL', @level2type = N'COLUMN', @level2name = N'DISCOUNT_PCT';

