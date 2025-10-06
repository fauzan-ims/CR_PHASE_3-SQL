CREATE TABLE [dbo].[MASTER_FEE_AMOUNT] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [FEE_CODE]         NVARCHAR (50)   NOT NULL,
    [EFFECTIVE_DATE]   DATETIME        NOT NULL,
    [FACILITY_CODE]    NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]    NVARCHAR (15)   NOT NULL,
    [CALCULATE_BY]     NVARCHAR (10)   NOT NULL,
    [CALCULATE_BASE]   NVARCHAR (11)   NOT NULL,
    [CALCULATE_FROM]   NVARCHAR (20)   NOT NULL,
    [FEE_RATE]         DECIMAL (9, 6)  CONSTRAINT [DF_MASTER_FEE_AMOUNT_FEE_RATE] DEFAULT ((0)) NULL,
    [FEE_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_MASTER_FEE_AMOUNT_FEE_AMOUNT] DEFAULT ((0)) NULL,
    [FN_DEFAULT_NAME]  NVARCHAR (250)  NULL,
    [IS_FN_OVERRIDE]   NVARCHAR (1)    NULL,
    [FN_OVERRIDE_NAME] NVARCHAR (250)  NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_FEE_AMOUNT] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_FEE_AMOUNT_MASTER_FEE] FOREIGN KEY ([FEE_CODE]) REFERENCES [dbo].[MASTER_FEE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_FEE_AMOUNT_Delete_Audit]    
			ON [dbo].[MASTER_FEE_AMOUNT]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE_AMOUNT]
([CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_FEE_AMOUNT_Insert_Audit] 
			ON [dbo].[MASTER_FEE_AMOUNT]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE_AMOUNT]
([CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_FEE_AMOUNT_Update_Audit]      
			ON [dbo].[MASTER_FEE_AMOUNT]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([FEE_CODE]) THEN '[FEE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EFFECTIVE_DATE]) THEN '[EFFECTIVE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_CODE]) THEN '[FACILITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CALCULATE_BY]) THEN '[CALCULATE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CALCULATE_BASE]) THEN '[CALCULATE_BASE]-' ELSE '' END + 
CASE WHEN UPDATE([CALCULATE_FROM]) THEN '[CALCULATE_FROM]-' ELSE '' END + 
CASE WHEN UPDATE([FEE_RATE]) THEN '[FEE_RATE]-' ELSE '' END + 
CASE WHEN UPDATE([FEE_AMOUNT]) THEN '[FEE_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([FN_DEFAULT_NAME]) THEN '[FN_DEFAULT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_FN_OVERRIDE]) THEN '[IS_FN_OVERRIDE]-' ELSE '' END + 
CASE WHEN UPDATE([FN_OVERRIDE_NAME]) THEN '[FN_OVERRIDE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE_AMOUNT]
([CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_FEE_AMOUNT]
([CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[FEE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CALCULATE_BASE],[CALCULATE_FROM],[FEE_RATE],[FEE_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'FEE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal effective date atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'EFFECTIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode facility atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan dari data fee amount tersebut - Amount, menginformasikan bahwa nilai charge tersebut sesuai dengan nilai charge yang telah diinput - PCT, menginformasikan bahwa data charge amount tersebut dalam bentuk persentase - Function, menginformasikan bahwa nilai charge tersebut dalam bentuk function', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'CALCULATE_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Base perhitungan biaya fee pada data master fee amount tersebut - APPLICATION, menginformasikan bahwa biaya fee tersebut dihitung berdasarkan nilai pembiayaan - ASSET, menginformasikan bahwa biaya fee tersebut dihitung berdasarkan nilai asset', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'CALCULATE_BASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan atas biaya fee tersebut - Amount, menginformasikan bahwa biaya fee tersebut dihitung berdasarkan harga asset - Financing, menginformasikan bahwa biaya fee tersebut dihitung berdasarkan nilai pembiayaan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'CALCULATE_FROM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate persentase atas biaya fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'FEE_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai atas biaya fee tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'FEE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function default atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'FN_DEFAULT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data function name atas data fee amount tersebut dapat dilakukan proses override', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'IS_FN_OVERRIDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function override atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FEE_AMOUNT', @level2type = N'COLUMN', @level2name = N'FN_OVERRIDE_NAME';

