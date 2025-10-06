CREATE PROCEDURE dbo.xsp_asset_other_upload_update
(
	@p_fa_upload_id	   bigint
	,@p_file_name	   nvarchar(250)
	,@p_upload_no	   nvarchar(50)
	,@p_asset_code	   nvarchar(50)
	,@p_remark		   nvarchar(4000)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_other_upload
		--set		fa_upload_id = @p_fa_upload_id
		set
				file_name = @p_file_name
				,upload_no = @p_upload_no
				,asset_code = @p_asset_code
				,remark = @p_remark
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	FA_UPLOAD_ID = @p_fa_upload_id ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;	
end ;
