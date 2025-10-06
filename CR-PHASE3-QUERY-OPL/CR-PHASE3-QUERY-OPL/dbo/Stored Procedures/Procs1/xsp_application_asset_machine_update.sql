CREATE PROCEDURE dbo.xsp_application_asset_machine_update
(
	@p_asset_no				       nvarchar(50)
	,@p_machinery_category_code	   nvarchar(50)	  = null
	,@p_machinery_subcategory_code nvarchar(50)	  = null
	,@p_machinery_merk_code		   nvarchar(50)	  = null
	,@p_machinery_model_code	   nvarchar(50)	  = null
	,@p_machinery_type_code		   nvarchar(50)	  = null
	,@p_machinery_unit_code		   nvarchar(50)	  = null
	,@p_colour					   nvarchar(250)  = null
	,@p_remarks					   nvarchar(4000) = ''
	--											  
	,@p_mod_date				   datetime		  
	,@p_mod_by					   nvarchar(15)	  
	,@p_mod_ip_address			   nvarchar(15)	  
)												  
as												  
begin											  
	declare @msg nvarchar(max) ;  

	begin try 
		update	application_asset_machine
		set		machinery_category_code		= @p_machinery_category_code
				,machinery_subcategory_code = @p_machinery_subcategory_code
				,machinery_merk_code		= @p_machinery_merk_code
				,machinery_model_code		= @p_machinery_model_code
				,machinery_type_code		= @p_machinery_type_code
				,machinery_unit_code		= @p_machinery_unit_code 
				,colour						= @p_colour
				,remarks					= @p_remarks
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	asset_no					= @p_asset_no ;
		 
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

