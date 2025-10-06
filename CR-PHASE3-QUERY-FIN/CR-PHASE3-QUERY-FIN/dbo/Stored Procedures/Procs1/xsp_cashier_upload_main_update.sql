CREATE PROCEDURE dbo.xsp_cashier_upload_main_update
(
	@p_code				  nvarchar(50)
	,@p_batch_no		  nvarchar(50)
	,@p_fintech_code	  nvarchar(50)
	,@p_fintech_name	  nvarchar(250)
	,@p_value_date		  datetime
	,@p_trx_date		  datetime
	,@p_branch_bank_code  nvarchar(50)
	,@p_branch_bank_name  nvarchar(50)
	,@p_bank_gl_link_code nvarchar(50)
	,@p_status			  nvarchar(50)
	--
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if(cast(@p_value_date as date) > cast(dbo.xfn_get_system_date() as date))
		begin
			set @msg = 'Value Date must be less or equal then System Date' ;

			raiserror(@msg, 16, -1) ;
		end

		update	cashier_upload_main
		set		batch_no			= @p_batch_no
				,fintech_code		= @p_fintech_code
				,fintech_name		= @p_fintech_name
				,value_date			= @p_value_date
				,trx_date			= @p_trx_date
				,branch_bank_code	= @p_branch_bank_code
				,branch_bank_name	= @p_branch_bank_name
				,bank_gl_link_code	= @p_bank_gl_link_code
				,status				= @p_status
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
