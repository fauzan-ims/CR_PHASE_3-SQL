CREATE TABLE [dbo].[MASTER_CHARGES_AMOUNT] (
    [CODE]             NVARCHAR (50)   NOT NULL,
    [CHARGE_CODE]      NVARCHAR (50)   NOT NULL,
    [EFFECTIVE_DATE]   DATETIME        NOT NULL,
    [FACILITY_CODE]    NVARCHAR (50)   NOT NULL,
    [CURRENCY_CODE]    NVARCHAR (3)    NOT NULL,
    [CALCULATE_BY]     NVARCHAR (10)   NOT NULL,
    [CHARGES_RATE]     DECIMAL (9, 6)  CONSTRAINT [DF_MASTER_CHARGES_AMOUNT_FEE_RATE] DEFAULT ((0)) NOT NULL,
    [CHARGES_AMOUNT]   DECIMAL (18, 2) CONSTRAINT [DF_MASTER_CHARGES_AMOUNT_FEE_AMOUNT] DEFAULT ((0)) NOT NULL,
    [FN_DEFAULT_NAME]  NVARCHAR (250)  NULL,
    [IS_FN_OVERRIDE]   NVARCHAR (1)    NULL,
    [FN_OVERRIDE_NAME] NVARCHAR (250)  NULL,
    [CRE_DATE]         DATETIME        NOT NULL,
    [CRE_BY]           NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    [MOD_DATE]         DATETIME        NOT NULL,
    [MOD_BY]           NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_CHARGES_AMOUNT] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_CHARGES_AMOUNT_MASTER_CHARGES] FOREIGN KEY ([CHARGE_CODE]) REFERENCES [dbo].[MASTER_CHARGES] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_CHARGES_AMOUNT_Update_Audit]      
			ON [dbo].[MASTER_CHARGES_AMOUNT]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CHARGE_CODE]) THEN '[CHARGE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EFFECTIVE_DATE]) THEN '[EFFECTIVE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_CODE]) THEN '[FACILITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CALCULATE_BY]) THEN '[CALCULATE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CHARGES_RATE]) THEN '[CHARGES_RATE]-' ELSE '' END + 
CASE WHEN UPDATE([CHARGES_AMOUNT]) THEN '[CHARGES_AMOUNT]-' ELSE '' END + 
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
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES_AMOUNT]
([CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES_AMOUNT]
([CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_CHARGES_AMOUNT_Insert_Audit] 
			ON [dbo].[MASTER_CHARGES_AMOUNT]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES_AMOUNT]
([CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_CHARGES_AMOUNT_Delete_Audit]    
			ON [dbo].[MASTER_CHARGES_AMOUNT]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_CHARGES_AMOUNT]
([CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[CHARGE_CODE],[EFFECTIVE_DATE],[FACILITY_CODE],[CURRENCY_CODE],[CALCULATE_BY],[CHARGES_RATE],[CHARGES_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data charge amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data charge tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'CHARGE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal effective date atas data charge amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'EFFECTIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode facility atas data charge amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data charges amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan dari data charge amount tersebut - Amount, menginformasikan bahwa nilai charge tersebut sesuai dengan nilai charge yang telah diinput - PCT, menginformasikan bahwa data charge amount tersebut dalam bentuk persentase - Function, menginformasikan bahwa nilai charge tersebut dalam bentuk function', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'CALCULATE_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai rate persentase atas data charge amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'CHARGES_RATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai amount atas data charge amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'CHARGES_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function atas data charge amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'FN_DEFAULT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data function name atas data charge amount tersebut dapat dilakukan proses override?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'IS_FN_OVERRIDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function override atas data charges amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_CHARGES_AMOUNT', @level2type = N'COLUMN', @level2name = N'FN_OVERRIDE_NAME';

