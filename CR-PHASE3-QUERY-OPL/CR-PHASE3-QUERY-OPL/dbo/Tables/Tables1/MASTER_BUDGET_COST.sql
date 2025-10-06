CREATE TABLE [dbo].[MASTER_BUDGET_COST] (
    [CODE]                   NVARCHAR (50)   NOT NULL,
    [DESCRIPTION]            NVARCHAR (250)  NOT NULL,
    [COST_TYPE]              NVARCHAR (10)   NOT NULL,
    [BILL_PERIODE]           NVARCHAR (10)   NOT NULL,
    [IS_ACTIVE]              NVARCHAR (1)    NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [CLASS_CODE]             NVARCHAR (50)   NULL,
    [CLASS_DESCRIPTION]      NVARCHAR (4000) NULL,
    [IS_SUBJECT_TO_PURCHASE] NVARCHAR (1)    NULL,
    [EXP_DATE]               DATETIME        NULL,
    [ITEM_CODE]              NVARCHAR (50)   NULL,
    [ITEM_DESCRIPTION]       NVARCHAR (250)  NULL,
    CONSTRAINT [PK_MASTER_BUDGET_COST] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_BUDGET_COST_Update_Audit]      
			ON [dbo].[MASTER_BUDGET_COST]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([COST_TYPE]) THEN '[COST_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([BILL_PERIODE]) THEN '[BILL_PERIODE]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_BUDGET_COST]
([CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_BUDGET_COST]
([CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_BUDGET_COST_Insert_Audit] 
			ON [dbo].[MASTER_BUDGET_COST]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_BUDGET_COST]
([CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_BUDGET_COST_Delete_Audit]    
			ON [dbo].[MASTER_BUDGET_COST]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_BUDGET_COST]
([CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[COST_TYPE],[BILL_PERIODE],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fixed, Variable', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BUDGET_COST', @level2type = N'COLUMN', @level2name = N'COST_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monthly, Yearly', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_BUDGET_COST', @level2type = N'COLUMN', @level2name = N'BILL_PERIODE';

