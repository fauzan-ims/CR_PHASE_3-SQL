CREATE TABLE [dbo].[MASTER_DESKCOLL_RESULT_DETAIL] (
    [CODE]               NVARCHAR (50)  NOT NULL,
    [RESULT_CODE]        NVARCHAR (50)  NOT NULL,
    [RESULT_DETAIL_NAME] NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]          NVARCHAR (1)   CONSTRAINT [DF_MASTER_DESKCOLL_RESULT_DETAIL_IS_ACTIVE] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]           DATETIME       NOT NULL,
    [CRE_BY]             NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]     NVARCHAR (15)  NOT NULL,
    [MOD_DATE]           DATETIME       NOT NULL,
    [MOD_BY]             NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]     NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_DESKCOLL_RESULT_DETAIL] PRIMARY KEY CLUSTERED ([CODE] ASC),
    CONSTRAINT [FK_MASTER_DESKCOLL_RESULT_DETAIL_MASTER_DESKCOLL_RESULT] FOREIGN KEY ([RESULT_CODE]) REFERENCES [dbo].[MASTER_DESKCOLL_RESULT] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_DESKCOLL_RESULT_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_DESKCOLL_RESULT_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_DESKCOLL_RESULT_DETAIL]
([CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_DESKCOLL_RESULT_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_DESKCOLL_RESULT_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([RESULT_CODE]) THEN '[RESULT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([RESULT_DETAIL_NAME]) THEN '[RESULT_DETAIL_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DESKCOLL_RESULT_DETAIL]
([CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DESKCOLL_RESULT_DETAIL]
([CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_DESKCOLL_RESULT_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_DESKCOLL_RESULT_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_DESKCOLL_RESULT_DETAIL]
([CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[RESULT_CODE],[RESULT_DETAIL_NAME],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data detail dari hasil deskcoll tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DESKCOLL_RESULT_DETAIL', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode result pada data detail hasil deskcoll tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DESKCOLL_RESULT_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama dari data detail result deskcoll tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DESKCOLL_RESULT_DETAIL', @level2type = N'COLUMN', @level2name = N'RESULT_DETAIL_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data detail dari hasil deskcoll tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DESKCOLL_RESULT_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

