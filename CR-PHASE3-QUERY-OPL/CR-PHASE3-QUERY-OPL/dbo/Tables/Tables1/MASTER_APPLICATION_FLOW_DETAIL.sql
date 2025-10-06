CREATE TABLE [dbo].[MASTER_APPLICATION_FLOW_DETAIL] (
    [ID]                    BIGINT        IDENTITY (1, 1) NOT NULL,
    [APPLICATION_FLOW_CODE] NVARCHAR (50) NOT NULL,
    [WORKFLOW_CODE]         NVARCHAR (50) NOT NULL,
    [IS_APPROVAL]           NVARCHAR (1)  CONSTRAINT [DF_MASTER_APPLICATION_FLOW_DETAIL_IS_APPROVAL] DEFAULT ((0)) NOT NULL,
    [IS_SIGN]               NVARCHAR (1)  CONSTRAINT [DF_MASTER_APPLICATION_FLOW_DETAIL_IS_APPROVAL1] DEFAULT ((0)) NOT NULL,
    [ORDER_KEY]             INT           NOT NULL,
    [CRE_DATE]              DATETIME      NOT NULL,
    [CRE_BY]                NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    [MOD_DATE]              DATETIME      NOT NULL,
    [MOD_BY]                NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]        NVARCHAR (15) NOT NULL,
    CONSTRAINT [PK_MASTER_FLOW_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_APPLICATION_FLOW_DETAIL_MASTER_APPLICATION_FLOW] FOREIGN KEY ([APPLICATION_FLOW_CODE]) REFERENCES [dbo].[MASTER_APPLICATION_FLOW] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT [FK_MASTER_APPLICATION_FLOW_DETAIL_MASTER_WORKFLOW] FOREIGN KEY ([WORKFLOW_CODE]) REFERENCES [dbo].[MASTER_WORKFLOW] ([CODE])
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_APPLICATION_FLOW_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_APPLICATION_FLOW_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([APPLICATION_FLOW_CODE]) THEN '[APPLICATION_FLOW_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([WORKFLOW_CODE]) THEN '[WORKFLOW_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_APPROVAL]) THEN '[IS_APPROVAL]-' ELSE '' END + 
CASE WHEN UPDATE([IS_SIGN]) THEN '[IS_SIGN]-' ELSE '' END + 
CASE WHEN UPDATE([ORDER_KEY]) THEN '[ORDER_KEY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_APPLICATION_FLOW_DETAIL]
([ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_APPLICATION_FLOW_DETAIL]
([ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_APPLICATION_FLOW_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_APPLICATION_FLOW_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_APPLICATION_FLOW_DETAIL]
([ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_APPLICATION_FLOW_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_APPLICATION_FLOW_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_APPLICATION_FLOW_DETAIL]
([ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[APPLICATION_FLOW_CODE],[WORKFLOW_CODE],[IS_APPROVAL],[IS_SIGN],[ORDER_KEY],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPLICATION_FLOW_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode application flow', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPLICATION_FLOW_DETAIL', @level2type = N'COLUMN', @level2name = N'APPLICATION_FLOW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode workflow', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPLICATION_FLOW_DETAIL', @level2type = N'COLUMN', @level2name = N'WORKFLOW_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode workflow', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPLICATION_FLOW_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_APPROVAL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode workflow', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPLICATION_FLOW_DETAIL', @level2type = N'COLUMN', @level2name = N'IS_SIGN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Urutan untuk workflow yang telah didaftarkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_APPLICATION_FLOW_DETAIL', @level2type = N'COLUMN', @level2name = N'ORDER_KEY';

