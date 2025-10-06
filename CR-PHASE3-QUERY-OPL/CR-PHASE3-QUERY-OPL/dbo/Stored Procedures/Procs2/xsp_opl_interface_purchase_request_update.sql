CREATE PROCEDURE dbo.xsp_opl_interface_purchase_request_update
(
	@p_code				 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_request_date	 datetime
	,@p_request_status	 nvarchar(10)
	,@p_description		 nvarchar(4000)
	,@p_fa_category_code nvarchar(50)
	,@p_fa_category_name nvarchar(250)
	,@p_fa_merk_code	 nvarchar(50)
	,@p_fa_merk_name	 nvarchar(250)
	,@p_fa_model_code	 nvarchar(50)
	,@p_fa_model_name	 nvarchar(250)
	,@p_fa_type_code	 nvarchar(50)
	,@p_fa_type_name	 nvarchar(250)
	,@p_result_fa_code	 nvarchar(50)
	,@p_result_fa_name	 nvarchar(250)
	,@p_result_date		 datetime
	--						 
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	opl_interface_purchase_request
		set		branch_code		 	= @p_branch_code		
				,branch_name		= @p_branch_name		 
				,request_date	 	= @p_request_date	
				,request_status	 	= @p_request_status	
				,description		= @p_description		 
				,fa_category_code 	= @p_fa_category_code
				,fa_category_name 	= @p_fa_category_name
				,fa_merk_code	 	= @p_fa_merk_code	
				,fa_merk_name	 	= @p_fa_merk_name	
				,fa_model_code	 	= @p_fa_model_code	
				,fa_model_name	 	= @p_fa_model_name	
				,fa_type_code	 	= @p_fa_type_code	
				,fa_type_name	 	= @p_fa_type_name	
				,result_fa_code	 	= @p_result_fa_code	
				,result_fa_name	 	= @p_result_fa_name	
				,result_date		= @p_result_date		 
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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
