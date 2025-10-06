CREATE TABLE [dbo].[MASTER_FACILITY] (
    [CODE]           NVARCHAR (50)  NOT NULL,
    [DESCRIPTION]    NVARCHAR (250) NOT NULL,
    [FACILITY_TYPE]  NVARCHAR (2)   NOT NULL,
    [DESKCOLL_MIN]   INT            CONSTRAINT [DF_MASTER_FACILITY_SP1_DAYS2] DEFAULT ((0)) NOT NULL,
    [DESKCOLL_MAX]   INT            CONSTRAINT [DF_MASTER_FACILITY_SP1_DAYS1] DEFAULT ((0)) NOT NULL,
    [SP1_DAYS]       INT            CONSTRAINT [DF_MASTER_FACILITY_SP1_DAYS] DEFAULT ((0)) NOT NULL,
    [SP2_DAYS]       INT            CONSTRAINT [DF_MASTER_FACILITY_SP2_DAYS] DEFAULT ((0)) NOT NULL,
    [SOMASI_DAYS]    INT            CONSTRAINT [DF_MASTER_FACILITY_SOMASI_DAYS] DEFAULT ((0)) NOT NULL,
    [AGING_DAYS1]    INT            CONSTRAINT [DF_MASTER_FACILITY_AGING_DAYS1] DEFAULT ((0)) NOT NULL,
    [AGING_DAYS2]    INT            CONSTRAINT [DF_MASTER_FACILITY_AGING_DAYS2] DEFAULT ((0)) NOT NULL,
    [AGING_DAYS3]    INT            CONSTRAINT [DF_MASTER_FACILITY_AGING_DAYS3] DEFAULT ((0)) NOT NULL,
    [AGING_DAYS4]    INT            CONSTRAINT [DF_MASTER_FACILITY_AGING_DAYS4] DEFAULT ((0)) NOT NULL,
    [IS_ACTIVE]      NVARCHAR (1)   NOT NULL,
    [CRE_DATE]       DATETIME       NOT NULL,
    [CRE_BY]         NVARCHAR (15)  NOT NULL,
    [CRE_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    [MOD_DATE]       DATETIME       NOT NULL,
    [MOD_BY]         NVARCHAR (15)  NOT NULL,
    [MOD_IP_ADDRESS] NVARCHAR (15)  NOT NULL,
    CONSTRAINT [PK_LOS_MASTER_FACILITY] PRIMARY KEY CLUSTERED ([CODE] ASC)
);


GO
    
			CREATE TRIGGER [dbo].[MASTER_FACILITY_Insert_Audit] 
			ON [dbo].[MASTER_FACILITY]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_MASTER_FACILITY]
([CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[MASTER_FACILITY_Update_Audit]      
			ON [dbo].[MASTER_FACILITY]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([CODE]) THEN '[CODE]-' ELSE '' END + 
CASE WHEN UPDATE([DESCRIPTION]) THEN '[DESCRIPTION]-' ELSE '' END + 
CASE WHEN UPDATE([FACILITY_TYPE]) THEN '[FACILITY_TYPE]-' ELSE '' END + 
CASE WHEN UPDATE([DESKCOLL_MIN]) THEN '[DESKCOLL_MIN]-' ELSE '' END + 
CASE WHEN UPDATE([DESKCOLL_MAX]) THEN '[DESKCOLL_MAX]-' ELSE '' END + 
CASE WHEN UPDATE([SP1_DAYS]) THEN '[SP1_DAYS]-' ELSE '' END + 
CASE WHEN UPDATE([SP2_DAYS]) THEN '[SP2_DAYS]-' ELSE '' END + 
CASE WHEN UPDATE([SOMASI_DAYS]) THEN '[SOMASI_DAYS]-' ELSE '' END + 
CASE WHEN UPDATE([AGING_DAYS1]) THEN '[AGING_DAYS1]-' ELSE '' END + 
CASE WHEN UPDATE([AGING_DAYS2]) THEN '[AGING_DAYS2]-' ELSE '' END + 
CASE WHEN UPDATE([AGING_DAYS3]) THEN '[AGING_DAYS3]-' ELSE '' END + 
CASE WHEN UPDATE([AGING_DAYS4]) THEN '[AGING_DAYS4]-' ELSE '' END + 
CASE WHEN UPDATE([IS_ACTIVE]) THEN '[IS_ACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_FACILITY]
([CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_MASTER_FACILITY]
([CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[MASTER_FACILITY_Delete_Audit]    
			ON [dbo].[MASTER_FACILITY]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_MASTER_FACILITY]
([CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [CODE],[DESCRIPTION],[FACILITY_TYPE],[DESKCOLL_MIN],[DESKCOLL_MAX],[SP1_DAYS],[SP2_DAYS],[SOMASI_DAYS],[AGING_DAYS1],[AGING_DAYS2],[AGING_DAYS3],[AGING_DAYS4],[IS_ACTIVE],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kode atas data master facility tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FACILITY', @level2type = N'COLUMN', @level2name = N'CODE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Deskripsi atas data master facility tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FACILITY', @level2type = N'COLUMN', @level2name = N'DESCRIPTION';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipe facility atas data master facility tersebut - Consumer Finance, menginformasikan bahwa facility tersebut merupakan pembiayaan berdasarkan kebutuhan konsumen dengan sistem pembayaran angsuran - Finance Lease, merupakan jenis pembiayaan dimana perusahaan pembiayaan biasanya merupakan pemilik sah dari aset selama jangka waktu sewa - Factoring, merupakan pembiayaan dengan melakukan pembelian terhadap piutang - Operating Lease, merupakan tipe pembiayaan dimana pihak lessee menyewa suatu jenis peralatan tertentu dengan tujuan untuk memperoleh manfaat atas barang tersebut dalam jangka waktu tertentu dan tidak ada keinginan atau kemungkinan untuk memiliki barang tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FACILITY', @level2type = N'COLUMN', @level2name = N'FACILITY_TYPE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status atas data master facility tersebut, apakah data tersebut berstatus aktif dan dapat digunakan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MASTER_FACILITY', @level2type = N'COLUMN', @level2name = N'IS_ACTIVE';

