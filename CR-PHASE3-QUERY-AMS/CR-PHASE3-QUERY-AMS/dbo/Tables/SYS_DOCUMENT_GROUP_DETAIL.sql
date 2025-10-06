CREATE TABLE [dbo].[SYS_DOCUMENT_GROUP_DETAIL] (
    [ID]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [DOCUMENT_GROUP_CODE] NVARCHAR (50) NOT NULL,
    [DOCUMENT_CODE]       NVARCHAR (50) NOT NULL,
    [CRE_DATE]            DATETIME      NOT NULL,
    [CRE_BY]              NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    [MOD_DATE]            DATETIME      NOT NULL,
    [MOD_BY]              NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]      NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_SYS_DOCUMENT_GROUP_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[SYS_DOCUMENT_GROUP_DETAIL_Insert_Audit] 
			ON [dbo].[SYS_DOCUMENT_GROUP_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_DOCUMENT_GROUP_DETAIL]
([ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_DOCUMENT_GROUP_DETAIL_Update_Audit]      
			ON [dbo].[SYS_DOCUMENT_GROUP_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([DOCUMENT_GROUP_CODE]) THEN '[DOCUMENT_GROUP_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DOCUMENT_CODE]) THEN '[DOCUMENT_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_DOCUMENT_GROUP_DETAIL]
([ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_DOCUMENT_GROUP_DETAIL]
([ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_DOCUMENT_GROUP_DETAIL_Delete_Audit]    
			ON [dbo].[SYS_DOCUMENT_GROUP_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_DOCUMENT_GROUP_DETAIL]
([ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[DOCUMENT_GROUP_CODE],[DOCUMENT_CODE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID TRANSAKSI', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DOCUMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE DOCUMENT GROUP', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DOCUMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_GROUP_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'KODE GENERAL DOCUMENT (dbo.SYS_GENERAL_DOCUMENT.Code)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_DOCUMENT_GROUP_DETAIL', @level2type = N'COLUMN', @level2name = N'DOCUMENT_CODE';

