CREATE TABLE [dbo].[SYS_EOD_TASK_LIST] (
    [CODE]           NVARCHAR (50)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [NAME]           NVARCHAR (500) NOT NULL,
    [SP_NAME]        NVARCHAR (500) NOT NULL,
    [ORDER_NO]       INT            NOT NULL,
    [IS_DONE]        NVARCHAR (1)   DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)   NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_SYS_EOD_TASK_LIST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_EOD_TASK_LIST_Insert_Audit] 
			ON [dbo].[SYS_EOD_TASK_LIST]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST]
([CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_EOD_TASK_LIST_Delete_Audit]    
			ON [dbo].[SYS_EOD_TASK_LIST]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST]
([CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_EOD_TASK_LIST_Update_Audit]      
			ON [dbo].[SYS_EOD_TASK_LIST]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([NAME]) THEN '[NAME]-' ELSE '' END + 
CASE WHEN UPDATE([SP_NAME]) THEN '[SP_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([ORDER_NO]) THEN '[ORDER_NO]-' ELSE '' END + 
CASE WHEN UPDATE([IS_DONE]) THEN '[IS_DONE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST]
([CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST]
([CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[NAME],[SP_NAME],[ORDER_NO],[IS_DONE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tasklist EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama Tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama SP atas tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'SP_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nomor urut dari tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'ORDER_NO';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data Status pengerjaan dari tasklist EOD tersebut, apakah data tasklist EOD tersebut sudah selesai dikerjakan atau belum?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'IS_DONE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari tasklist EOD tersebut, apakah data tasklist EOD tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

