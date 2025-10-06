CREATE TABLE [dbo].[MASTER_WAREHOUSE] (
    [CODE]           NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [COMPANY_CODE]   NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_COMPANY_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_CODE]    NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_BRANCH_CODE] DEFAULT ('') NOT NULL,
    [BRANCH_NAME]    NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_BRANCH_NAME] DEFAULT ('') NOT NULL,
    [DESCRIPTION]    NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_DESCRIPTION] DEFAULT ('') NOT NULL,
    [CITY_CODE]      NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_CITY_CODE] DEFAULT ('') NOT NULL,
    [CITY_NAME]      NVARCHAR (250)  COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_CITY_NAME] DEFAULT ('') NOT NULL,
    [ADDRESS]        NVARCHAR (4000) COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_ADDRESS] DEFAULT ('') NOT NULL,
    [PIC]            NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_PIC] DEFAULT ('') NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)    COLLATE SQL_Latin1_General_CP1_CI_AS CONSTRAINT [DF_MASTER_WAREHOUSE_PIC1] DEFAULT ('') NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_MASTER_WAREHOUSE] PRIMARY KEY CLUSTERED ([CODE] ASC, [COMPANY_CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_WAREHOUSE_Insert_Audit] 
			ON [dbo].[MASTER_WAREHOUSE]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_WAREHOUSE]
([CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_WAREHOUSE_Delete_Audit]    
			ON [dbo].[MASTER_WAREHOUSE]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_WAREHOUSE]
([CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_WAREHOUSE_Update_Audit]      
			ON [dbo].[MASTER_WAREHOUSE]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([COMPANY_CODE]) THEN '[COMPANY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_CODE]) THEN '[BRANCH_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_NAME]) THEN '[BRANCH_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([CITY_CODE]) THEN '[CITY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CITY_NAME]) THEN '[CITY_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([ADDRESS]) THEN '[ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([PIC]) THEN '[PIC]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_WAREHOUSE]
([CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_WAREHOUSE]
([CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[COMPANY_CODE],[BRANCH_CODE],[BRANCH_NAME],[DESCRIPTION],[CITY_CODE],[CITY_NAME],[ADDRESS],[PIC],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE PERUSAHAAN (DSF)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'COMPANY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE CABANG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA CABANG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DESKRIPSI TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE KOTA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'CITY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA KOTA', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'CITY_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ALAMAT GUDANG', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'ADDRESS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PENANGGUNG JAWAB', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'PIC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AKTIF (1) TIDAK AKTIF (0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_WAREHOUSE', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

