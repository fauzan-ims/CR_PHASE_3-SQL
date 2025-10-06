CREATE TABLE [dbo].[SYS_REPORT] (
    [CODE]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NAME]           NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [TABLE_NAME]     NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SP_NAME]        NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [SCREEN_NAME]    NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [RPT_NAME]       NVARCHAR (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MODULE_CODE]    NVARCHAR (50)  NOT NULL,
    [REPORT_TYPE]    NVARCHAR (15)  NULL,
    [IS_ACTIVE]      NVARCHAR (1)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CONSTRAINT [PK_SYS_REPORT] PRIMARY KEY CLUSTERED ([CODE] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_SYS_REPORT_SYS_MODULE] FOREIGN KEY ([MODULE_CODE]) REFERENCES [dbo].[SYS_MODULE] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[SYS_REPORT_Insert_Audit] 
			ON [dbo].[SYS_REPORT]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_REPORT]
([CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_REPORT_Delete_Audit]    
			ON [dbo].[SYS_REPORT]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_REPORT]
([CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_REPORT_Update_Audit]      
			ON [dbo].[SYS_REPORT]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([NAME]) THEN '[NAME]-' ELSE '' END + 
CASE WHEN UPDATE([TABLE_NAME]) THEN '[TABLE_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([SP_NAME]) THEN '[SP_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([SCREEN_NAME]) THEN '[SCREEN_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([RPT_NAME]) THEN '[RPT_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([MODULE_CODE]) THEN '[MODULE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([REPORT_TYPE]) THEN '[REPORT_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_REPORT]
([CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_REPORT]
([CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[TABLE_NAME],[SP_NAME],[SCREEN_NAME],[RPT_NAME],[MODULE_CODE],[REPORT_TYPE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA TABLE REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'TABLE_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA SP REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'SP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA SCREEN REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'SCREEN_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NAMA FILE CRYSTAL REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'RPT_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NOT USED', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'MODULE_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'TIPE REPORT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'REPORT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'AKTIF (1) TIDAK AKTIF (0)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_REPORT', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

