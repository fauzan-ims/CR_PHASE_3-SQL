CREATE PROCEDURE dbo.xsp_cashier_received_request_for_deposit_proceed
(
	@p_code					nvarchar(50)
	,@p_rate				decimal(18, 6)
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
			,@deposit_allocation_code	nvarchar(50)
			,@system_date				datetime = dbo.xfn_get_system_date()
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(250)
			,@request_amount			decimal(18, 2)
			,@base_amount				decimal(18, 2)
			,@agreement_no				nvarchar(50)
			,@request_remarks			nvarchar(4000)
			,@request_currency_code		nvarchar(3);

	begin try
	
		if exists (select 1 from dbo.cashier_received_request where code = @p_code and request_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.cashier_received_request where code = @p_code and isnull(doc_ref_flag,'') <> '')
		begin
			set @msg = 'Please proceed on Cashier Transaction';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.cashier_received_request where code = @p_code and isnull(agreement_no,'') = '')
		begin
			set @msg = 'Please proceed on Cashier Transaction';
			raiserror(@msg ,16,-1)
		end

		if exists (select 1 from dbo.cashier_received_request where code = @p_code and isnull(process_reff_code,'') <> '')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end

		begin
			select	@request_currency_code		= request_currency_code
					,@request_amount			= request_amount
					,@agreement_no				= agreement_no
					,@request_remarks			= request_remarks
					,@branch_code				= branch_code
					,@branch_name				= branch_name
					,@base_amount				= request_amount * @p_rate
			from	dbo.cashier_received_request 
			where   code = @p_code

			if not exists (select 1 from ifinopl.dbo.agreement_deposit_main where agreement_no = @agreement_no and deposit_amount >= @request_amount)
			begin
				set @msg = 'This agreement did not have deposit amount.';
				raiserror(@msg ,16,-1)
			end

			if not exists	(
								select	1 
								from	dbo.deposit_allocation 
								where	allocation_status				= 'HOLD' 
										and allocation_currency_code	= @request_currency_code 
										and branch_code					= @branch_code
										and isnull(agreement_no,'')		= isnull(@agreement_no,'')
							)
			begin 
					
					exec dbo.xsp_deposit_allocation_insert @p_code							= @deposit_allocation_code output 
														   ,@p_branch_code					= @branch_code
														   ,@p_branch_name					= @branch_name
														   ,@p_allocation_status			= N'HOLD' 
														   ,@p_allocation_trx_date			= @system_date
														   ,@p_allocation_value_date		= @system_date
														   ,@p_allocation_orig_amount		= 0
														   ,@p_allocation_currency_code		= @request_currency_code
														   ,@p_allocation_exch_rate			= @p_rate
														   ,@p_allocation_base_amount		= 0
														   ,@p_allocationt_remarks			= N'' -- nvarchar(4000)
														   ,@p_agreement_no					= @agreement_no
														   ,@p_deposit_code					= N'' -- nvarchar(50)
														   ,@p_deposit_type					= N'' -- nvarchar(15)
														   ,@p_deposit_amount				= 0
														   ,@p_deposit_gl_link_code			= N'' -- nvarchar(50)
														   ,@p_is_received_request			= N'1' 
														   ,@p_cre_date						= @p_cre_date
														   ,@p_cre_by						= @p_cre_by
														   ,@p_cre_ip_address				= @p_cre_ip_address
														   ,@p_mod_date						= @p_mod_date
														   ,@p_mod_by						= @p_mod_by
														   ,@p_mod_ip_address				= @p_mod_ip_address
					

			end
			else
			begin
			    select	@deposit_allocation_code= code 
				from	dbo.deposit_allocation 
				where	allocation_status				= 'HOLD' 
						and allocation_currency_code	= @request_currency_code
						and branch_code					= @branch_code
						and isnull(agreement_no,'')		= isnull(@agreement_no,'')
			end

			
			exec dbo.xsp_deposit_allocation_detail_insert @p_id							= 0
														  ,@p_deposit_allocation_code	= @deposit_allocation_code
														  ,@p_transaction_code			= null
														  ,@p_received_request_code		= @p_code
														  ,@p_is_paid					= N'T' 
														  ,@p_innitial_amount			= @request_amount
														  ,@p_orig_amount				= @request_amount
														  ,@p_orig_currency_code		= @request_currency_code
														  ,@p_exch_rate					= @p_rate
														  ,@p_base_amount				= @base_amount
														  ,@p_installment_no			= null
														  ,@p_remarks					= @request_remarks
														  ,@p_cre_date					= @p_cre_date
														  ,@p_cre_by					= @p_cre_by
														  ,@p_cre_ip_address			= @p_cre_ip_address
														  ,@p_mod_date					= @p_mod_date
														  ,@p_mod_by					= @p_mod_by
														  ,@p_mod_ip_address			= @p_mod_ip_address
			
			
			update	cashier_received_request
			set		request_status	= 'ON PROCESS'
					,mod_date		= @p_cre_date
					,mod_by			= @p_cre_by
					,mod_ip_address	= @p_cre_ip_address
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
