CREATE TABLE [dbo].[MASTER_REFUND] (
    [CODE]              NVARCHAR (50)   NOT NULL,
    [DESCRIPTION]       NVARCHAR (250)  NOT NULL,
    [CURRENCY_CODE]     NVARCHAR (3)    NOT NULL,
    [REFUND_TYPE]       NVARCHAR (10)   CONSTRAINT [DF_LOS_MASTER_REFUND_REFUND_TYPE] DEFAULT (N'F') NOT NULL,
    [FACILITY_CODE]     NVARCHAR (50)   NOT NULL,
    [FEE_CODE]          NVARCHAR (50)   NULL,
    [CALCULATE_BY]      NVARCHAR (10)   NOT NULL,
    [REFUND_AMOUNT]     DECIMAL (18, 2) CONSTRAINT [DF_MASTER_REFUND_REFUND_AMOUNT] DEFAULT ((0)) NULL,
    [REFUND_PCT]        DECIMAL (9, 6)  CONSTRAINT [DF_MASTER_REFUND_REFUND_PCT] DEFAULT ((0)) NULL,
    [MAX_REFUND_AMOUNT] DECIMAL (18, 2) NULL,
    [FN_DEFAULT_NAME]   NVARCHAR (250)  NULL,
    [IS_FN_OVERRIDE]    NVARCHAR (1)    NULL,
    [FN_OVERRIDE_NAME]  NVARCHAR (250)  NULL,
    [IS_PSAK]           NVARCHAR (1)    CONSTRAINT [DF_MASTER_REFUND_IS_PSAK] DEFAULT ((0)) NULL,
    [IS_ACTIVE]         NVARCHAR (1)    NULL,
    [CRE_DATE]          DATETIME        NOT NULL,
    [CRE_BY]            NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)   NOT NULL,
    [MOD_DATE]          DATETIME        NOT NULL,
    [MOD_BY]            NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_REFUND] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_REFUND_MASTER_FACILITY] FOREIGN KEY ([FACILITY_CODE]) REFERENCES [dbo].[MASTER_FACILITY] ([CODE]),
    CONSTRAINT [FK_MASTER_REFUND_MASTER_FEE] FOREIGN KEY ([FEE_CODE]) REFERENCES [dbo].[MASTER_FEE] ([CODE])
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_REFUND_Insert_Audit] 
			ON [dbo].[MASTER_REFUND]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_REFUND]
([CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_REFUND_Delete_Audit]    
			ON [dbo].[MASTER_REFUND]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_REFUND]
([CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_REFUND_Update_Audit]      
			ON [dbo].[MASTER_REFUND]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([REFUND_TYPE]) THEN '[REFUND_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_CODE]) THEN '[FACILITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([FEE_CODE]) THEN '[FEE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CALCULATE_BY]) THEN '[CALCULATE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([REFUND_AMOUNT]) THEN '[REFUND_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([REFUND_PCT]) THEN '[REFUND_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([MAX_REFUND_AMOUNT]) THEN '[MAX_REFUND_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([FN_DEFAULT_NAME]) THEN '[FN_DEFAULT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_FN_OVERRIDE]) THEN '[IS_FN_OVERRIDE]-' ELSE '' END + 
CASE WHEN UPDATE([FN_OVERRIDE_NAME]) THEN '[FN_OVERRIDE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_PSAK]) THEN '[IS_PSAK]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_REFUND]
([CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_REFUND]
([CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[CURRENCY_CODE],[REFUND_TYPE],[FACILITY_CODE],[FEE_CODE],[CALCULATE_BY],[REFUND_AMOUNT],[REFUND_PCT],[MAX_REFUND_AMOUNT],[FN_DEFAULT_NAME],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_PSAK],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe refund atas data master refund tersebut - Fee, menginformasikan bahwa data refund tersebut merupakan refund atas biaya fee -Interest, menginformasikan bahwa refund tersebut merupakan refund dari bunga pembiayaan - Insurance, menginformasikan bahwa biaya tersebut merupakan refund dsari biaya asuransi', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'REFUND_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode facility atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode biaya fee atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'FEE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe perhitungan dari data master refund tersebut - Amount, menginformasikan bahwa nilai refund tersebut sesuai dengan nilai refund yang telah diinput - PCT, menginformasikan bahwa data refund tersebut dalam bentuk persentase - Function, menginformasikan bahwa nilai refund tersebut dalam bentuk function', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'CALCULATE_BY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai amount atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'REFUND_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai persentase refund atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'REFUND_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai amount maksimal atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'MAX_REFUND_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function default atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'FN_DEFAULT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data function atas data master refund tersebut dapat dilakukan proses override?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'IS_FN_OVERRIDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function override atas data master refund tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'FN_OVERRIDE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah perhitungan data master refund tersebut perhitungannya berdasarkan PSAK?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'IS_PSAK';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master refund tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_REFUND', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

