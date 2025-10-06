CREATE TABLE [dbo].[MASTER_COLLECTOR] (
    [CODE]                      NVARCHAR (50)  NOT NULL,
    [COLLECTOR_NAME]            NVARCHAR (250) NOT NULL,
    [SUPERVISOR_COLLECTOR_CODE] NVARCHAR (50)  NULL,
    [COLLECTOR_EMP_CODE]        NVARCHAR (50)  NOT NULL,
    [COLLECTOR_EMP_NAME]        NVARCHAR (250) NOT NULL,
    [MAX_LOAD_AGREEMENT]        INT            CONSTRAINT [DF_MASTER_COLLECTOR_MAX_LOAD_AGREEMENT] DEFAULT ((0)) NOT NULL,
    [MAX_LOAD_DAILY_AGREEMENT]  INT            CONSTRAINT [DF_MASTER_COLLECTOR_MAX_LOAD_SKT] DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]                 NVARCHAR (1)   NOT NULL,
    [CRE_DATE]                  DATETIME       NOT NULL,
    [CRE_BY]                    NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]            NVARCHAR (15)  NOT NULL,
    [MOD_DATE]                  DATETIME       NOT NULL,
    [MOD_BY]                    NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]            NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_COLLECTOR] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_COLLECTOR_Update_Audit]      
			ON [dbo].[MASTER_COLLECTOR]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COLLECTOR_NAME]) THEN '[COLLECTOR_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([SUPERVISOR_COLLECTOR_CODE]) THEN '[SUPERVISOR_COLLECTOR_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COLLECTOR_EMP_CODE]) THEN '[COLLECTOR_EMP_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COLLECTOR_EMP_NAME]) THEN '[COLLECTOR_EMP_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([MAX_LOAD_AGREEMENT]) THEN '[MAX_LOAD_AGREEMENT]-' ELSE '' END + 
CASE WHEN UPDATE([MAX_LOAD_DAILY_AGREEMENT]) THEN '[MAX_LOAD_DAILY_AGREEMENT]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTOR]
([CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTOR]
([CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_COLLECTOR_Insert_Audit] 
			ON [dbo].[MASTER_COLLECTOR]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTOR]
([CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_COLLECTOR_Delete_Audit]    
			ON [dbo].[MASTER_COLLECTOR]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_COLLECTOR]
([CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COLLECTOR_NAME],[SUPERVISOR_COLLECTOR_CODE],[COLLECTOR_EMP_CODE],[COLLECTOR_EMP_NAME],[MAX_LOAD_AGREEMENT],[MAX_LOAD_DAILY_AGREEMENT],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data collector tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama kolektor atas data collector tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'COLLECTOR_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode supervisi atas data collector tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'SUPERVISOR_COLLECTOR_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode karyawan atas data collector tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'COLLECTOR_EMP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode karyawan atas data collector tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'COLLECTOR_EMP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Load maksimal kontrak pembiayaan yang dapat diberikan kepada kolektor tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'MAX_LOAD_AGREEMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Load maksimal SKT yang dapat diberikan kepada kolektor tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'MAX_LOAD_DAILY_AGREEMENT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status pada data collector tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_COLLECTOR', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

