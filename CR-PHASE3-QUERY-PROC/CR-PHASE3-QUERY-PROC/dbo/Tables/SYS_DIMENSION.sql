CREATE TABLE [dbo].[SYS_DIMENSION] (
    [CODE]           NVARCHAR (50)  CONSTRAINT [DF_SYS_DIMENSION_CODE] DEFAULT (N'') NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [TYPE]           NVARCHAR (10)  CONSTRAINT [DF_SYS_DIMENSION_TYPE] DEFAULT (N'T') NOT NULL,
    [TABLE_NAME]     NVARCHAR (50)  NULL,
    [COLUMN_NAME]    NVARCHAR (50)  NULL,
    [PRIMARY_COLUMN] NVARCHAR (50)  CONSTRAINT [DF_SYS_DIMENSION_PRIMARY_COLUMN] DEFAULT (N'') NULL,
    [FUNCTION_NAME]  NVARCHAR (250) CONSTRAINT [DF_SYS_DIMENSION_FUNCTION_NAME] DEFAULT (N'') NULL,
    [IS_ACTIVE]      NVARCHAR (1)   NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_DIMENSION] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_DIMENSION_Delete_Audit]    
			ON [dbo].[SYS_DIMENSION]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION]
([CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_DIMENSION_Update_Audit]      
			ON [dbo].[SYS_DIMENSION]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([TYPE]) THEN '[TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([TABLE_NAME]) THEN '[TABLE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([COLUMN_NAME]) THEN '[COLUMN_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([PRIMARY_COLUMN]) THEN '[PRIMARY_COLUMN]-' ELSE '' END + 
CASE WHEN UPDATE([FUNCTION_NAME]) THEN '[FUNCTION_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION]
([CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION]
([CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_DIMENSION_Insert_Audit] 
			ON [dbo].[SYS_DIMENSION]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_DIMENSION]
([CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[TYPE],[TABLE_NAME],[COLUMN_NAME],[PRIMARY_COLUMN],[FUNCTION_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DESKRIPSI TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TIPE DARI MANA DATA NYA (''TABLE'', ''FUNCTION'')', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA TABEL', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'TABLE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA KOLOM', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'COLUMN_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PRIMARY KEY TABLE TERSEBUT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'PRIMARY_COLUMN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA FUNGSI YANG DIGUNAKAN UNTUK MENDAPATKAN DIMENSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'FUNCTION_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AKTIF(1), TIDAK AKTIF(0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DIMENSION', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

