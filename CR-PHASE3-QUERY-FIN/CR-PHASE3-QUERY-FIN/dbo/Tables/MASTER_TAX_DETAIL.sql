CREATE TABLE [dbo].[MASTER_TAX_DETAIL] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [TAX_CODE]               NVARCHAR (50)   NOT NULL,
    [EFFECTIVE_DATE]         DATETIME        NOT NULL,
    [FROM_VALUE_AMOUNT]      DECIMAL (18, 2) NOT NULL,
    [TO_VALUE_AMOUNT]        DECIMAL (18, 2) NOT NULL,
    [WITH_TAX_NUMBER_PCT]    DECIMAL (9, 6)  NOT NULL,
    [WITHOUT_TAX_NUMBER_PCT] DECIMAL (9, 6)  NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_MASTER_TAX_DETAIL] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_TAX_DETAIL_MASTER_TAX] FOREIGN KEY ([TAX_CODE]) REFERENCES [dbo].[MASTER_TAX] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_TAX_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_TAX_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([TAX_CODE]) THEN '[TAX_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EFFECTIVE_DATE]) THEN '[EFFECTIVE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([FROM_VALUE_AMOUNT]) THEN '[FROM_VALUE_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([TO_VALUE_AMOUNT]) THEN '[TO_VALUE_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([WITH_TAX_NUMBER_PCT]) THEN '[WITH_TAX_NUMBER_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([WITHOUT_TAX_NUMBER_PCT]) THEN '[WITHOUT_TAX_NUMBER_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_TAX_DETAIL]
([ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_TAX_DETAIL]
([ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_TAX_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_TAX_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_TAX_DETAIL]
([ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_TAX_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_TAX_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_TAX_DETAIL]
([ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[TAX_CODE],[EFFECTIVE_DATE],[FROM_VALUE_AMOUNT],[TO_VALUE_AMOUNT],[WITH_TAX_NUMBER_PCT],[WITHOUT_TAX_NUMBER_PCT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auto generate', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode tax pada data master tax detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'TAX_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tangal mulai berlakunya tax pada data master tax detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'EFFECTIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah nilai yang akan dikenakan tax pada data master tax detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'FROM_VALUE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas nilai yang akan dikenakan tax pada data master tax detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'TO_VALUE_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate nilai pajak jika memiliki NPWP pada data master tax detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'WITH_TAX_NUMBER_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persentase rate nilai pajak jika tidak memiliki NPWP pada data master tax detail tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_TAX_DETAIL', @level2type = N'COLUMN', @level2name = N'WITHOUT_TAX_NUMBER_PCT';

