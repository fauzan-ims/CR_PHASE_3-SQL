CREATE TABLE [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP] (
    [CODE]              NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]       NVARCHAR (250) NOT NULL,
    [IS_ACTIVE]         NVARCHAR (1)   NOT NULL,
    [CONTRACT_TYPE]     NVARCHAR (15)  NOT NULL,
    [DIM_COUNT]         INT            CONSTRAINT [DF_MASTER_DOCUMENT_CONTRACT_GROUP_DIM_COUNT] DEFAULT ((0)) NOT NULL,
    [DIM_1]             NVARCHAR (50)  NULL,
    [OPERATOR_1]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_1]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_1]    NVARCHAR (50)  NULL,
    [DIM_2]             NVARCHAR (50)  NULL,
    [OPERATOR_2]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_2]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_2]    NVARCHAR (50)  NULL,
    [DIM_3]             NVARCHAR (50)  NULL,
    [OPERATOR_3]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_3]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_3]    NVARCHAR (50)  NULL,
    [DIM_4]             NVARCHAR (50)  NULL,
    [OPERATOR_4]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_4]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_4]    NVARCHAR (50)  NULL,
    [DIM_5]             NVARCHAR (50)  NULL,
    [OPERATOR_5]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_5]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_5]    NVARCHAR (50)  NULL,
    [DIM_6]             NVARCHAR (50)  NULL,
    [OPERATOR_6]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_6]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_6]    NVARCHAR (50)  NULL,
    [DIM_7]             NVARCHAR (50)  NULL,
    [OPERATOR_7]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_7]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_7]    NVARCHAR (50)  NULL,
    [DIM_8]             NVARCHAR (50)  NULL,
    [OPERATOR_8]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_8]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_8]    NVARCHAR (50)  NULL,
    [DIM_9]             NVARCHAR (50)  NULL,
    [OPERATOR_9]        NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_9]  NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_9]    NVARCHAR (50)  NULL,
    [DIM_10]            NVARCHAR (50)  NULL,
    [OPERATOR_10]       NVARCHAR (50)  NULL,
    [DIM_VALUE_FROM_10] NVARCHAR (50)  NULL,
    [DIM_VALUE_TO_10]   NVARCHAR (50)  NULL,
    [CRE_DATE]          DATETIME       NOT NULL,
    [CRE_BY]            NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    [MOD_DATE]          DATETIME       NOT NULL,
    [MOD_BY]            NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS]    NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_MASTER_APPLICATION_CONTRACT_GROUP] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP_Delete_Audit]    
			ON [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT_GROUP]
([CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
    
			CREATE TRIGGER [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP_Insert_Audit] 
			ON [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT_GROUP]
([CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP_Update_Audit]      
			ON [dbo].[MASTER_DOCUMENT_CONTRACT_GROUP]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CONTRACT_TYPE]) THEN '[CONTRACT_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_COUNT]) THEN '[DIM_COUNT]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_1]) THEN '[DIM_1]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_1]) THEN '[OPERATOR_1]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_1]) THEN '[DIM_VALUE_FROM_1]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_1]) THEN '[DIM_VALUE_TO_1]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_2]) THEN '[DIM_2]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_2]) THEN '[OPERATOR_2]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_2]) THEN '[DIM_VALUE_FROM_2]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_2]) THEN '[DIM_VALUE_TO_2]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_3]) THEN '[DIM_3]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_3]) THEN '[OPERATOR_3]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_3]) THEN '[DIM_VALUE_FROM_3]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_3]) THEN '[DIM_VALUE_TO_3]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_4]) THEN '[DIM_4]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_4]) THEN '[OPERATOR_4]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_4]) THEN '[DIM_VALUE_FROM_4]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_4]) THEN '[DIM_VALUE_TO_4]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_5]) THEN '[DIM_5]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_5]) THEN '[OPERATOR_5]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_5]) THEN '[DIM_VALUE_FROM_5]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_5]) THEN '[DIM_VALUE_TO_5]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_6]) THEN '[DIM_6]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_6]) THEN '[OPERATOR_6]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_6]) THEN '[DIM_VALUE_FROM_6]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_6]) THEN '[DIM_VALUE_TO_6]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_7]) THEN '[DIM_7]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_7]) THEN '[OPERATOR_7]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_7]) THEN '[DIM_VALUE_FROM_7]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_7]) THEN '[DIM_VALUE_TO_7]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_8]) THEN '[DIM_8]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_8]) THEN '[OPERATOR_8]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_8]) THEN '[DIM_VALUE_FROM_8]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_8]) THEN '[DIM_VALUE_TO_8]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_9]) THEN '[DIM_9]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_9]) THEN '[OPERATOR_9]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_9]) THEN '[DIM_VALUE_FROM_9]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_9]) THEN '[DIM_VALUE_TO_9]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_10]) THEN '[DIM_10]-' ELSE '' END + 
CASE WHEN UPDATE([OPERATOR_10]) THEN '[OPERATOR_10]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_FROM_10]) THEN '[DIM_VALUE_FROM_10]-' ELSE '' END + 
CASE WHEN UPDATE([DIM_VALUE_TO_10]) THEN '[DIM_VALUE_TO_10]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT_GROUP]
([CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_DOCUMENT_CONTRACT_GROUP]
([CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[IS_ACTIVE],[CONTRACT_TYPE],[DIM_COUNT],[DIM_1],[OPERATOR_1],[DIM_VALUE_FROM_1],[DIM_VALUE_TO_1],[DIM_2],[OPERATOR_2],[DIM_VALUE_FROM_2],[DIM_VALUE_TO_2],[DIM_3],[OPERATOR_3],[DIM_VALUE_FROM_3],[DIM_VALUE_TO_3],[DIM_4],[OPERATOR_4],[DIM_VALUE_FROM_4],[DIM_VALUE_TO_4],[DIM_5],[OPERATOR_5],[DIM_VALUE_FROM_5],[DIM_VALUE_TO_5],[DIM_6],[OPERATOR_6],[DIM_VALUE_FROM_6],[DIM_VALUE_TO_6],[DIM_7],[OPERATOR_7],[DIM_VALUE_FROM_7],[DIM_VALUE_TO_7],[DIM_8],[OPERATOR_8],[DIM_VALUE_FROM_8],[DIM_VALUE_TO_8],[DIM_9],[OPERATOR_9],[DIM_VALUE_FROM_9],[DIM_VALUE_TO_9],[DIM_10],[OPERATOR_10],[DIM_VALUE_FROM_10],[DIM_VALUE_TO_10],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status dari data group document contract tersebut, apakah berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe contract pada data group document contract tersebut - Plafond, menginformasikan bahwa group document contract tersebut digunakan pada proses plafond - Application, menginformasikan bahwa group document contract tersebut digunakan pada proses aplikasi pembiayaan - Drawdown, menginformasikan bahwa group document contract tersebut digunakan pada proses drawdown', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'CONTRACT_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Count dimensi atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_COUNT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 1 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 1 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 1 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 1 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 1 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 1 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_1';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 2 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 2 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 2 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 2 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 2 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 2 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 2', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_2';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 3 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 3 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 3 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 3 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 3 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 3 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_3';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 4 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 4 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 4 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 4 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 4 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 4 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 4', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_4';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 5 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 5 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 5 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 5 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 5 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 5 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 5', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 5', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_5';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 6 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 6 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 6 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 6 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 6 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 6 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 6', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 6', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_6';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 7 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 7 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 7 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 7 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 7 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 7 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 7', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_7';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 8 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 8 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 8 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 8 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 8 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 8 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 8', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 8', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_8';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 9 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 9 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 9 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 9 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 9 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 9 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 9', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 9', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_9';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensi 10 atas data group document contract tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Operator yang berlaku pada dimensi 10 data group document contract tersebut - Equal, menginformasikan bahwa dimensi 10 valuenya harus sesuai dengan value yang telah diinput - More Than, menginformasikan bahwa dimensi 10 valuenya harus lebih besar dari value yang telah diinput - Less Than, menginformasikan bahwa dimensi 10 valuenya harus lebih kecil dari value yang telah diinput - Between, menginformasikan bahwa dimensi 10 valuenya harus diantara value yang telah diinput', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'OPERATOR_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas bawah dari value dimension 10', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_FROM_10';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Batas atas dari value dimension 10', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_DOCUMENT_CONTRACT_GROUP', @level2type = N'COLUMN', @level2name = N'DIM_VALUE_TO_10';

