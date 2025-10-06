--created by, Rian at 17/02/2023 

CREATE procedure dbo.xsp_master_item_group_gl_update
(
	@p_id				   bigint
	,@p_company_code	   nvarchar(50)
	,@p_item_group_code	   nvarchar(50)
	,@p_currency_code	   nvarchar(10)
	,@p_gl_asset_code	   nvarchar(50) = ''
	,@p_gl_expend_code	   nvarchar(50) = ''
	,@p_gl_inprogress_code nvarchar(50) = ''
	,@p_category		   nvarchar(250)
	--
	,@p_mod_date		   datetime
	,@p_mod_by			   nvarchar(15)
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	master_item_group_gl
		set		company_code		= @p_company_code
				,item_group_code	= @p_item_group_code
				,currency_code		= @p_currency_code
				,gl_asset_code		= @p_gl_asset_code
				,gl_expend_code		= @p_gl_expend_code
				,gl_inprogress_code = @p_gl_inprogress_code
				,category			= @p_category
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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
