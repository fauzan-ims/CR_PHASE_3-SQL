
CREATE PROCEDURE dbo.xsp_upload_validation_cannot_be_empty
(
	@p_column_name				nvarchar(250)
	,@p_value_check				nvarchar(4000)
	,@p_primary_key				nvarchar(250)
	--
	 --
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)

)
as
BEGIN
	
	declare @date_check datetime
			,@error_msg	nvarchar(4000)
	

	-- VALIDASI value tidak boleh kosong
	if (isnull(@p_value_check, '') = '')
	BEGIN
    
		set @error_msg = @p_column_name + ' cannot be empty.'

		exec	dbo.xsp_upload_error_log_insert 
				@p_column_name					
			    ,@error_msg
				,@p_primary_key		
				--				
			    ,@p_cre_date					
			    ,@p_cre_by						
			    ,@p_cre_ip_address				
			    ,@p_mod_date					
			    ,@p_mod_by						
			    ,@p_mod_ip_address
	end

end
