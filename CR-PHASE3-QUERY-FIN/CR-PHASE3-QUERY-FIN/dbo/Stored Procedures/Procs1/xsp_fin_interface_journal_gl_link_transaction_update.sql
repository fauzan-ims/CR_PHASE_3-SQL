CREATE PROCEDURE dbo.xsp_fin_interface_journal_gl_link_transaction_update
(
	@p_id					   bigint
	,@p_code				   nvarchar(50)
	,@p_branch_code			   nvarchar(50)
	,@p_branch_name			   nvarchar(250)
	,@p_transaction_status	   nvarchar(10)
	,@p_transaction_date	   datetime
	,@p_transaction_value_date datetime
	,@p_transaction_code	   nvarchar(50)
	,@p_transaction_name	   nvarchar(250)
	,@p_reff_module_code	   nvarchar(10)
	,@p_reff_source_no		   nvarchar(50)
	,@p_reff_source_name	   nvarchar(250)
	,@p_is_journal_reversal	   nvarchar(1)
	,@p_reversal_reff_no	   nvarchar(50)
	--
	,@p_mod_date			   datetime
	,@p_mod_by				   nvarchar(15)
	,@p_mod_ip_address		   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	fin_interface_journal_gl_link_transaction
		set		code					= @p_code
				,branch_code			= @p_branch_code
				,branch_name			= @p_branch_name
				,transaction_status		= @p_transaction_status
				,transaction_date		= @p_transaction_date
				,transaction_value_date = @p_transaction_value_date
				,transaction_code		= @p_transaction_code
				,transaction_name		= upper(@p_transaction_name)
				,reff_module_code		= upper(@p_reff_module_code)
				,reff_source_no			= @p_reff_source_no
				,reff_source_name		= @p_reff_source_name
				,is_journal_reversal	= @p_is_journal_reversal
				,reversal_reff_no		= @p_reversal_reff_no
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
