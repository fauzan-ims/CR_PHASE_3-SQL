CREATE PROCEDURE dbo.xsp_suspend_release_paid
(
	@p_code					nvarchar(50)
	--,@p_transaction_code	nvarchar(50)
	,@p_exch_rate			decimal(18,6)
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
			--,@gl_link_code				nvarchar(50)
			,@suspend_code				nvarchar(50)
			,@release_amount			decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			--,@release_remarks			nvarchar(4000)
			--,@release_date				datetime
			,@suspend_currency_code		nvarchar(3)

	begin try
	
		if exists (select 1 from dbo.suspend_release where code = @p_code and release_status <> 'APPROVE')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else if exists (select 1 from dbo.suspend_release where code = @p_code and release_amount > suspend_amount)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Release Amount','Suspend Amount');
			raiserror(@msg ,16,-1)
		end
		else
		begin
			select	@suspend_code			= suspend_code
					,@release_amount		= release_amount
					,@branch_code			= branch_code
					,@branch_name			= branch_name
					--,@release_date			= release_date
					,@suspend_currency_code	= suspend_currency_code
					--,@release_remarks		= 'Releas Suspend for ' + code + ' ' + release_remarks
			from	dbo.suspend_release
			where	code = @p_code

			update	dbo.suspend_main
			set		used_amount						= used_amount + @release_amount
					,remaining_amount				= remaining_amount - @release_amount
					,transaction_code				= null
					,transaction_name				= null
					,mod_date						= @p_mod_date
					,mod_by							= @p_mod_by
					,mod_ip_address					= @p_mod_ip_address
			where	code							= @suspend_code
			
			set @release_amount = @release_amount * -1;
			set @base_amount = @release_amount * @p_exch_rate;
			exec dbo.xsp_suspend_history_insert @p_id					= 0
												,@p_branch_code			= @branch_code
												,@p_branch_name			= @branch_name
												,@p_suspend_code		= @suspend_code
												,@p_transaction_date	= @p_cre_date
												,@p_orig_amount			= @release_amount
												,@p_orig_currency_code	= @suspend_currency_code
												,@p_exch_rate			= @p_exch_rate
												,@p_base_amount			= @base_amount
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
			set		release_status		= 'PAID'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code = @p_code

			-- jurnal
			--set @release_amount = abs(@release_amount)
			--set @base_amount = abs(@base_amount)

			--select	@gl_link_code = mt.gl_link_code 
			--from	dbo.sys_global_param sgp
			--		inner join dbo.master_transaction mt on (mt.code = sgp.value)
			--where	sgp.code = 'TRXSPND'

			--exec dbo.xsp_fin_interface_journal_gl_link_transaction_detail_insert @p_id							= 0
			--																	 ,@p_gl_link_transaction_code	= @p_transaction_code
			--																	 ,@p_branch_code				= @branch_code
			--																	 ,@p_branch_name				= @branch_name
			--																	 ,@p_gl_link_code				= @gl_link_code
			--																	 ,@p_contra_gl_link_code		= null
			--																	 ,@p_agreement_no				= null
			--																	 ,@p_orig_currency_code			= @suspend_currency_code
			--																	 ,@p_orig_amount_db				= @release_amount
			--																	 ,@p_orig_amount_cr				= 0
			--																	 ,@p_exch_rate					= @p_exch_rate
			--																	 ,@p_base_amount_db				= @base_amount
			--																	 ,@p_base_amount_cr				= 0
			--																	 ,@p_remarks					= @release_remarks
			--																	 ,@p_division_code				= null
			--																	 ,@p_division_name				= null
			--																	 ,@p_department_code			= null
			--																	 ,@p_department_name			= null
			--																	 ,@p_cre_date					= @p_cre_date		
			--																	 ,@p_cre_by						= @p_cre_by			
			--																	 ,@p_cre_ip_address				= @p_cre_ip_address
			--																	 ,@p_mod_date					= @p_mod_date		
			--																	 ,@p_mod_by						= @p_mod_by			
			--																	 ,@p_mod_ip_address				= @p_mod_ip_address

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
