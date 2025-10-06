--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
CREATE PROCEDURE xsp_insert_change_password_to_history
(
	 @p_uid					nvarchar(10)
	,@p_date_change_pass	datetime
	,@old_password			nvarchar(20)
	,@u_pass				nvarchar(20) 
	,@p_cre_ip_address		nvarchar(20) 
)
as
begin
insert into dbo.HISTORY_PASSWORD
	        (
			 ID
	        ,DATE_CHANGE_PASS
	        ,OLDPASS
	        ,NEWPASS
	        ,CRE_IP_ADDRESS
	        )
	values  (
			  @p_uid
	        , getdate()
	        , @old_password
	        , @u_pass
	        , @p_cre_ip_address
	        )
end
