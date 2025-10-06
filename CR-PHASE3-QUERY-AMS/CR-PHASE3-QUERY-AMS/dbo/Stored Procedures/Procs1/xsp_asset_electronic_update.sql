CREATE PROCEDURE dbo.xsp_asset_electronic_update
(
	@p_asset_code					nvarchar(50)
	,@p_merk_code					nvarchar(50)	= ''
	,@p_merk_name					nvarchar(250)	= ''
	,@p_type_item_code				nvarchar(50)	= ''
	,@p_type_item_name				nvarchar(250)	= ''
	,@p_model_code					nvarchar(50)	= ''
	,@p_model_name					nvarchar(250)	= ''
	,@p_serial_no					nvarchar(50)	= ''
	,@p_dimension					nvarchar(50)	= ''
	,@p_hdd							nvarchar(10)	= ''
	,@p_processor					nvarchar(10)	= ''
	,@p_ram_size					nvarchar(8)		= ''
	,@p_domain						nvarchar(100)	= ''
	,@p_imei						nvarchar(100)	= ''
	,@p_remark						nvarchar(4000)	= ''
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists (select 1 from dbo.asset_electronic where serial_no  = @p_serial_no and serial_no <> '')
		begin
			set @msg = 'The serial number already exists on another asset.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_electronic where domain  = @p_domain and domain <> '')
		begin
			set @msg = 'Domain already exists on another asset.';
			raiserror(@msg ,16,-1);	    
		end
		if exists (select 1 from dbo.asset_electronic where imei  = @p_imei and imei <> '')
		begin
			set @msg = 'Imei number already exists on another asset';
			raiserror(@msg ,16,-1);	    
		end
		

		update	asset_electronic
		set		merk_code					= @p_merk_code
				,merk_name					= @p_merk_name
				,type_item_code				= @p_type_item_code
				,type_item_name				= @p_type_item_name
				,model_code					= @p_model_code
				,model_name					= @p_model_name
				,serial_no					= @p_serial_no
				,dimension					= @p_dimension
				,hdd						= @p_hdd
				,processor					= @p_processor
				,ram_size					= @p_ram_size
				,domain						= @p_domain
				,imei						= @p_imei
				,remark						= @p_remark
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	asset_code					= @p_asset_code ;
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
