CREATE TABLE [dbo].[SYS_EOD_TASK_LIST_LOG] (
    [ID]             INT             IDENTITY (1, 1) NOT NULL,
    [EOD_CODE]       NVARCHAR (50)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    [EOD_DATE]       DATETIME        NOT NULL,
    [START_TIME]     DATETIME        NOT NULL,
    [END_TIME]       DATETIME        NOT NULL,
    [STATUS]         NVARCHAR (10)   NOT NULL,
    [REASON]         NVARCHAR (4000) NOT NULL,
    [CRE_DATE]       DATETIME        NOT NULL,
    [CRE_BY]         NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    [MOD_DATE]       DATETIME        NOT NULL,
    [MOD_BY]         NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)   NOT NULL,
    CONSTRAINT [FK_SYS_EOD_TASK_LIST_LOG_SYS_EOD_TASK_LIST] FOREIGN KEY ([EOD_CODE]) REFERENCES [dbo].[SYS_EOD_TASK_LIST] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[SYS_EOD_TASK_LIST_LOG_Delete_Audit]    
			ON [dbo].[SYS_EOD_TASK_LIST_LOG]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST_LOG]
([ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(int,[ID]) as [ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[SYS_EOD_TASK_LIST_LOG_Insert_Audit] 
			ON [dbo].[SYS_EOD_TASK_LIST_LOG]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST_LOG]
([ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(int,[ID]) as [ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_EOD_TASK_LIST_LOG_Update_Audit]      
			ON [dbo].[SYS_EOD_TASK_LIST_LOG]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([EOD_CODE]) THEN '[EOD_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EOD_DATE]) THEN '[EOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([START_TIME]) THEN '[START_TIME]-' ELSE '' END + 
CASE WHEN UPDATE([END_TIME]) THEN '[END_TIME]-' ELSE '' END + 
CASE WHEN UPDATE([STATUS]) THEN '[STATUS]-' ELSE '' END + 
CASE WHEN UPDATE([REASON]) THEN '[REASON]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST_LOG]
([ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(int,[ID]) as [ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_EOD_TASK_LIST_LOG]
([ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(int,[ID]) as [ID],[EOD_CODE],[EOD_DATE],[START_TIME],[END_TIME],[STATUS],[REASON],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto Generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'EOD_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dilakukannya EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'EOD_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu dimulainya proses EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'START_TIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu berakhirnya proses EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'END_TIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data EOD tasklist tersebut, apakah data EOD tersebut ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'STATUS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Reason atas log tasklist EOD tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_EOD_TASK_LIST_LOG', @level2type = N'COLUMN', @level2name = N'REASON';

