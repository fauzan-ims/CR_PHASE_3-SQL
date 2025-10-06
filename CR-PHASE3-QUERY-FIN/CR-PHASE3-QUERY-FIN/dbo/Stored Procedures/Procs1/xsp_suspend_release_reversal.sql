CREATE PROCEDURE dbo.xsp_suspend_release_reversal
(
	@p_code				nvarchar(50)
	--,@p_approval_reff		nvarchar(250)
	--,@p_approval_remark	nvarchar(4000)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg						nvarchar(max)
			,@suspend_code				nvarchar(50)
			,@release_amount			decimal(18, 2)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@release_date				datetime
			,@suspend_currency_code		nvarchar(3)

	begin try
	
		if exists (select 1 from dbo.suspend_release where code = @p_code and release_status <> 'PAID')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			select	@suspend_code			= suspend_code
					,@release_amount		= release_amount
					,@branch_code			= branch_code
					,@branch_name			= branch_name
					,@release_date			= release_date
					,@suspend_currency_code	= suspend_currency_code
			from	dbo.suspend_release
			where	code = @p_code

			update	dbo.suspend_main
			set		suspend_amount					= suspend_amount + @release_amount
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @suspend_code
			
			exec dbo.xsp_suspend_history_insert @p_id					= 0
												,@p_branch_code			= @branch_code
												,@p_branch_name			= @branch_name
												,@p_suspend_code		= @suspend_code
												,@p_transaction_date	= @p_cre_date
												,@p_orig_amount			= @release_amount
												,@p_orig_currency_code	= @suspend_currency_code
												,@p_exch_rate			= 1
												,@p_base_amount			= @release_amount
												,@p_agreement_no		= null
												,@p_source_reff_code	= @p_code
												,@p_source_reff_name	= N'Suspend Release'
												,@p_cre_date			= @p_cre_date		
												,@p_cre_by				= @p_cre_by			
												,@p_cre_ip_address		= @p_cre_ip_address
												,@p_mod_date			= @p_mod_date		
												,@p_mod_by				= @p_mod_by			
												,@p_mod_ip_address		= @p_mod_ip_address

			update	dbo.suspend_release
			set		release_status		= 'REVERSE'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code
		end
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
end


