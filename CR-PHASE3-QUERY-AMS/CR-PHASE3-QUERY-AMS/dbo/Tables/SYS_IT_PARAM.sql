CREATE TABLE [dbo].[SYS_IT_PARAM] (
    [SYSTEM_DATE]              DATETIME      NOT NULL,
    [DB_MAIL_PROFILE]          NVARCHAR (50) NOT NULL,
    [USER_AUTO_INACTIVE]       INT           NOT NULL,
    [PASSWORD_MAX_REPEAT_TIME] INT           NOT NULL,
    [PASSWORD_MAX_LOGIN_TRY]   INT           NOT NULL,
    [PASSWORD_NEXT_CHANGE]     INT           NOT NULL,
    [PASSWORD_MIN_CHAR]        INT           NOT NULL,
    [PASSWORD_MAX_CHAR]        INT           NOT NULL,
    [PASSWORD_REGEX]           NVARCHAR (1)  NOT NULL,
    [PASSWORD_USE_UPPERCASE]   NVARCHAR (1)  NOT NULL,
    [PASSWORD_USE_LOWERCASE]   NVARCHAR (1)  NOT NULL,
    [PASSWORD_CONTAIN_NUMBER]  NVARCHAR (1)  NOT NULL,
    [IS_EOD_RUNNING]           NVARCHAR (1)  NOT NULL,
    [EOD_MANUAL_FLAG]          NVARCHAR (1)  NOT NULL,
    [SUBSCRIPTION_TYPE_CODE]   NVARCHAR (50) CONSTRAINT [DF_SYS_IT_PARAM_SUBSCRIPTION_TYPE_CODE] DEFAULT ('') NOT NULL,
    [MAX_USER]                 INT           CONSTRAINT [DF_SYS_IT_PARAM_MAX_USER] DEFAULT ((0)) NOT NULL,
    [CRE_DATE]                 DATETIME      NOT NULL,
    [CRE_BY]                   NVARCHAR (15) NOT NULL,
    [CRE_IP_ADDRESS]           NVARCHAR (15) NOT NULL,
    [MOD_DATE]                 DATETIME      NOT NULL,
    [MOD_BY]                   NVARCHAR (15) NOT NULL,
    [MOD_IP_ADDRESS]           NVARCHAR (15) NOT NULL
);


GO
    
			CREATE TRIGGER [dbo].[SYS_IT_PARAM_Insert_Audit] 
			ON [dbo].[SYS_IT_PARAM]    
			FOR INSERT    
			AS    
			
 INSERT INTO [dbo].[Z_AUDIT_SYS_IT_PARAM]
([SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Insert',SUSER_SNAME(),getdate(),''  FROM INSERTED 
GO
    
			CREATE TRIGGER [dbo].[SYS_IT_PARAM_Update_Audit]      
			ON [dbo].[SYS_IT_PARAM]    
			FOR UPDATE    
			AS 
   
			 
			    DECLARE @UpdatedCols varchar(max) 
			 
			   SELECT @UpdatedCols =  CASE WHEN UPDATE([SYSTEM_DATE]) THEN '[SYSTEM_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([DB_MAIL_PROFILE]) THEN '[DB_MAIL_PROFILE]-' ELSE '' END + 
CASE WHEN UPDATE([USER_AUTO_INACTIVE]) THEN '[USER_AUTO_INACTIVE]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_MAX_REPEAT_TIME]) THEN '[PASSWORD_MAX_REPEAT_TIME]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_MAX_LOGIN_TRY]) THEN '[PASSWORD_MAX_LOGIN_TRY]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_NEXT_CHANGE]) THEN '[PASSWORD_NEXT_CHANGE]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_MIN_CHAR]) THEN '[PASSWORD_MIN_CHAR]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_MAX_CHAR]) THEN '[PASSWORD_MAX_CHAR]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_REGEX]) THEN '[PASSWORD_REGEX]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_USE_UPPERCASE]) THEN '[PASSWORD_USE_UPPERCASE]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_USE_LOWERCASE]) THEN '[PASSWORD_USE_LOWERCASE]-' ELSE '' END + 
CASE WHEN UPDATE([PASSWORD_CONTAIN_NUMBER]) THEN '[PASSWORD_CONTAIN_NUMBER]-' ELSE '' END + 
CASE WHEN UPDATE([IS_EOD_RUNNING]) THEN '[IS_EOD_RUNNING]-' ELSE '' END + 
CASE WHEN UPDATE([EOD_MANUAL_FLAG]) THEN '[EOD_MANUAL_FLAG]-' ELSE '' END + 
CASE WHEN UPDATE([SUBSCRIPTION_TYPE_CODE]) THEN '[SUBSCRIPTION_TYPE_CODE]-' ELSE '' END + 
CASE WHEN UPDATE([MAX_USER]) THEN '[MAX_USER]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_DATE]) THEN '[CRE_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_BY]) THEN '[CRE_BY]-' ELSE '' END + 
CASE WHEN UPDATE([CRE_IP_ADDRESS]) THEN '[CRE_IP_ADDRESS]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_DATE]) THEN '[MOD_DATE]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_BY]) THEN '[MOD_BY]-' ELSE '' END + 
CASE WHEN UPDATE([MOD_IP_ADDRESS]) THEN '[MOD_IP_ADDRESS]-' ELSE '' END  
			    
			   IF LTRIM(RTRIM(@UpdatedCols)) <> '' 
			   BEGIN 
			          INSERT INTO [dbo].[Z_AUDIT_SYS_IT_PARAM]
([SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'New','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM INSERTED     
			    
			          INSERT INTO [dbo].[Z_AUDIT_SYS_IT_PARAM]
([SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Update',SUSER_SNAME(),getdate(),@UpdatedCols  FROM DELETED  
			   END
GO
    
			CREATE TRIGGER [dbo].[SYS_IT_PARAM_Delete_Audit]    
			ON [dbo].[SYS_IT_PARAM]    
			FOR DELETE    
			AS   
  INSERT INTO [dbo].[Z_AUDIT_SYS_IT_PARAM]
([SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],AuditDataState,AuditDMLAction,AuditUser,AuditDateTime,UpdateColumns)
SELECT [SYSTEM_DATE],[DB_MAIL_PROFILE],[USER_AUTO_INACTIVE],[PASSWORD_MAX_REPEAT_TIME],[PASSWORD_MAX_LOGIN_TRY],[PASSWORD_NEXT_CHANGE],[PASSWORD_MIN_CHAR],[PASSWORD_MAX_CHAR],[PASSWORD_REGEX],[PASSWORD_USE_UPPERCASE],[PASSWORD_USE_LOWERCASE],[PASSWORD_CONTAIN_NUMBER],[IS_EOD_RUNNING],[EOD_MANUAL_FLAG],[SUBSCRIPTION_TYPE_CODE],[MAX_USER],[CRE_DATE],[CRE_BY],[CRE_IP_ADDRESS],[MOD_DATE],[MOD_BY],[MOD_IP_ADDRESS],'Old','Delete',SUSER_SNAME(),getdate(),''  FROM DELETED
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tanggal dari sistem tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'SYSTEM_DATE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Settingan server email pada aplikasi tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'DB_MAIL_PROFILE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah hari yang dibutuhkan untuk membuat user otomatis menjadi tidak aktif', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'USER_AUTO_INACTIVE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu yang dibutuhkan (dalam bulan) untuk diperbolehkan menggunakan password yang sama', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MAX_REPEAT_TIME';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah (berapa kali) percobaan gagal login yang diperbolehkan', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MAX_LOGIN_TRY';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Waktu (dalam bulan) perubahan password login berikutnya', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_NEXT_CHANGE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah karakter minimal atas password tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MIN_CHAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Jumlah karakter maksimal atas password tersebut', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_MAX_CHAR';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung special karakter?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_REGEX';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung huruf kapital?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_USE_UPPERCASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung huruf kecil?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_USE_LOWERCASE';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah password diharuskan mengandung angka?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'PASSWORD_CONTAIN_NUMBER';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apakah EOD sedang berjalan pada sistem?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'IS_EOD_RUNNING';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag untuk proses request melakukan proses manual EOD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SYS_IT_PARAM', @level2type = N'COLUMN', @level2name = N'EOD_MANUAL_FLAG';

