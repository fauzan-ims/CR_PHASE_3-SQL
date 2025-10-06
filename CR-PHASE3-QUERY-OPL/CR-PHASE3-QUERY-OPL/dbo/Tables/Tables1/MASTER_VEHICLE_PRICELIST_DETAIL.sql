CREATE TABLE [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [VEHICLE_PRICELIST_CODE] NVARCHAR (50)   NOT NULL,
    [BRANCH_CODE]            NVARCHAR (50)   NOT NULL,
    [BRANCH_NAME]            NVARCHAR (250)  NOT NULL,
    [CURRENCY_CODE]          NVARCHAR (3)    NOT NULL,
    [EFFECTIVE_DATE]         DATETIME        NOT NULL,
    [ASSET_VALUE]            DECIMAL (18, 2) NOT NULL,
    [DP_PCT]                 DECIMAL (9, 6)  NOT NULL,
    [DP_AMOUNT]              DECIMAL (18, 2) NOT NULL,
    [FINANCING_AMOUNT]       DECIMAL (18, 2) CONSTRAINT [DF_MASTER_VEHICLE_PRICELIST_DETAIL_FINANCING_AMOUNT] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]               DATETIME        NOT NULL,
    [CRE_BY]                 NVARCHAR (15)   NOT NULL,
    [CRE_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    [MOD_DATE]               DATETIME        NOT NULL,
    [MOD_BY]                 NVARCHAR (15)   NOT NULL,
    [MOD_IP_ADDRESS]         NVARCHAR (15)   NOT NULL,
    CONSTRAINT [PK_LOS_MASTER_ASSET_PRICELIST_PAYMENT] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_MASTER_VEHICLE_PRICELIST_DETAIL_MASTER_VEHICLE_PRICELIST] FOREIGN KEY ([VEHICLE_PRICELIST_CODE]) REFERENCES [dbo].[MASTER_VEHICLE_PRICELIST] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL_Delete_Audit]    
			ON [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_DETAIL]
([ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL_Insert_Audit] 
			ON [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_DETAIL]
([ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL_Update_Audit]      
			ON [dbo].[MASTER_VEHICLE_PRICELIST_DETAIL]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([ID]) THEN '[ID]-' ELSE '' END + 
CASE WHEN UPDATE([VEHICLE_PRICELIST_CODE]) THEN '[VEHICLE_PRICELIST_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_CODE]) THEN '[BRANCH_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([BRANCH_NAME]) THEN '[BRANCH_NAME]-' ELSE '' END + 
CASE WHEN UPDATE([CURRENCY_CODE]) THEN '[CURRENCY_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([EFFECTIVE_DATE]) THEN '[EFFECTIVE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([ASSET_VALUE]) THEN '[ASSET_VALUE]-' ELSE '' END + 
CASE WHEN UPDATE([DP_PCT]) THEN '[DP_PCT]-' ELSE '' END + 
CASE WHEN UPDATE([DP_AMOUNT]) THEN '[DP_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([FINANCING_AMOUNT]) THEN '[FINANCING_AMOUNT]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_DETAIL]
([ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_VEHICLE_PRICELIST_DETAIL]
([ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT CONVERT(bigint,[ID]) as [ID],[VEHICLE_PRICELIST_CODE],[BRANCH_CODE],[BRANCH_NAME],[CURRENCY_CODE],[EFFECTIVE_DATE],[ASSET_VALUE],[DP_PCT],[DP_AMOUNT],[FINANCING_AMOUNT],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode pricelist pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'VEHICLE_PRICELIST_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode cabang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'BRANCH_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nama cabang', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'BRANCH_NAME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jenis mata uang yang digunakan pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'CURRENCY_CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal mulai berlakunya data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'EFFECTIVE_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai asset pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'ASSET_VALUE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai persentase uang muka pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'DP_PCT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai DP amount pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'DP_AMOUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nilai pembiayaan pada data master detail pricelist atas vehicle tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_VEHICLE_PRICELIST_DETAIL', @level2type = N'COLUMN', @level2name = N'FINANCING_AMOUNT';

