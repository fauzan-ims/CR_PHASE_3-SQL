CREATE PROCEDURE [dbo].[xsp_application_extention_upload_file_memo]
(
	@p_id			   bigint
	,@p_file_name	   nvarchar(250)
	,@p_file_paths	   nvarchar(250)
	,@p_is_standart	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin 

	update	dbo.application_extention
	set		memo_file_name	 = upper(@p_file_name)
			,memo_file_path	 = upper(@p_file_paths)
			,is_valid		 = '0'
			,is_standart	 = @p_is_standart
			--
			,mod_date		 = @p_mod_date
			,mod_by			 = @p_mod_by
			,mod_ip_address	 = @p_mod_ip_address
	where	id				 = @p_id ;
end ;
