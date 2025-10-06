CREATE TABLE [dbo].[MASTER_DEVIATION] (
    [CODE]             NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]      NVARCHAR (250) NOT NULL,
    [FUNCTION_NAME]    NVARCHAR (250) NULL,
    [FACILITY_CODE]    NVARCHAR (50)  NOT NULL,
    [POSITION_CODE]    NVARCHAR (50)  NOT NULL,
    [POSITION_NAME]    NVARCHAR (250) NOT NULL,
    [TYPE]             NVARCHAR (15)  NOT NULL,
    [IS_FN_OVERRIDE]   NVARCHAR (1)   NULL,
    [FN_OVERRIDE_NAME] NVARCHAR (250) NULL,
    [IS_MANUAL]        NVARCHAR (1)   NOT NULL,
    [IS_ACTIVE]        NVARCHAR (1)   CONSTRAINT [DF_MASTER_DEVIATION_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]         DATETIME       NOT NULL,
    [CRE_BY]           NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    [MOD_DATE]         DATETIME       NOT NULL,
    [MOD_BY]           NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]   NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_DEVIATION] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_DEVIATION_Delete_Audit]    
			ON [dbo].[MASTER_DEVIATION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_DEVIATION]
([CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_DEVIATION_Update_Audit]      
			ON [dbo].[MASTER_DEVIATION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([FUNCTION_NAME]) THEN '[FUNCTION_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_CODE]) THEN '[FACILITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([POSITION_CODE]) THEN '[POSITION_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([POSITION_NAME]) THEN '[POSITION_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TYPE]) THEN '[TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_FN_OVERRIDE]) THEN '[IS_FN_OVERRIDE]-' ELSE '' END + 
CASE WHEN UPDATE([FN_OVERRIDE_NAME]) THEN '[FN_OVERRIDE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_MANUAL]) THEN '[IS_MANUAL]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DEVIATION]
([CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DEVIATION]
([CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_DEVIATION_Insert_Audit] 
			ON [dbo].[MASTER_DEVIATION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_DEVIATION]
([CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FUNCTION_NAME],[FACILITY_CODE],[POSITION_CODE],[POSITION_NAME],[TYPE],[IS_FN_OVERRIDE],[FN_OVERRIDE_NAME],[IS_MANUAL],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode deviation', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function atas data deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'FUNCTION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode facility atas data deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'FACILITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode posisi yang dapat menyetujui atas deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'POSITION_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Posisi jabatan yang dapat menyetujui atas deviation tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'POSITION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe dari data deviation tersebut - Application, menginformasikan bahwa deviation tersebut digunakan pada proses application - Plafond, menginformasikan bahwa data deviation tersebuty digunakan pada proses plafond - Drawdown, menginformasikan bahwa data deviation tersebut digunakan pada proses drawdown', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data function name atas data fee amount tersebut dapat dilakukan proses override', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'IS_FN_OVERRIDE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama function override atas data fee amount tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'FN_OVERRIDE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah data deviation tersebut dapat ditambahkan secara manual?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'IS_MANUAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data deviation tersebut, apakah data deviation tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DEVIATION', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

