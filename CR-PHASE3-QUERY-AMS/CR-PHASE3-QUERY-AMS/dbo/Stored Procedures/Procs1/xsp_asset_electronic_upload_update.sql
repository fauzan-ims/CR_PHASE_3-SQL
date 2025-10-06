CREATE PROCEDURE dbo.xsp_asset_electronic_upload_update
(
	@p_fa_upload_id	   bigint
	,@p_file_name	   nvarchar(250)
	,@p_upload_no	   nvarchar(50)
	,@p_asset_code	   nvarchar(50)
	,@p_merk_code	   nvarchar(50)
	,@p_merk_name	   nvarchar(250)
	,@p_type_code	   nvarchar(50)
	,@p_type_name	   nvarchar(250)
	,@p_model_code	   nvarchar(50)
	,@p_model_name	   nvarchar(250)
	,@p_serial_no	   nvarchar(50)
	,@p_dimension	   nvarchar(50)
	,@p_hdd			   nvarchar(10)
	,@p_processor	   nvarchar(10)
	,@p_ram_size	   nvarchar(8)
	,@p_domain		   nvarchar(100)
	,@p_imei		   nvarchar(100)
	,@p_purchase	   nvarchar(50)
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
		update	asset_electronic_upload
		set		file_name = @p_file_name
				,upload_no = @p_upload_no
				,asset_code = @p_asset_code
				,merk_code = @p_merk_code
				,merk_name = @p_merk_name
				,type_code = @p_type_code
				,type_name = @p_type_name
				,model_code = @p_model_code
				,model_name = @p_model_name
				,serial_no = @p_serial_no
				,dimension = @p_dimension
				,hdd = @p_hdd
				,processor = @p_processor
				,ram_size = @p_ram_size
				,domain = @p_domain
				,imei = @p_imei
				,purchase = @p_purchase
				,remark = @p_remark
				--
				,mod_date = @p_mod_date
				,mod_by = @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	fa_upload_id = @p_fa_upload_id ;
	end try
	Begin catch
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
