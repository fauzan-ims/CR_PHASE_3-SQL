CREATE PROCEDURE [dbo].[xsp_cashier_transaction_detail_insert]
(
	@p_id						 bigint		   = 0 output
	,@p_cashier_transaction_code nvarchar(50)
	,@p_transaction_code		 nvarchar(50)  = null
	,@p_received_request_code	 nvarchar(50)  = null
	,@p_agreement_no			 nvarchar(50)  = null
	,@p_is_paid					 nvarchar(1)
	,@p_innitial_amount			 decimal(18, 2) = 0
	,@p_orig_amount				 decimal(18, 2)
	,@p_orig_currency_code		 nvarchar(3)
	,@p_exch_rate				 decimal(18, 6)
	,@p_base_amount				 decimal(18, 2)
	,@p_installment_no			 int		   = null
	,@p_remarks					 nvarchar(4000)
	--
	,@p_cre_date				 datetime
	,@p_cre_by					 nvarchar(15)
	,@p_cre_ip_address			 nvarchar(15)
	,@p_mod_date				 datetime
	,@p_mod_by					 nvarchar(15)
	,@p_mod_ip_address			 nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@transaction_code nvarchar(50)
			,@transaction_name nvarchar(250)
			,@sum_amount	   decimal(18, 2)
			,@rate_amount	   decimal(18, 6) ;

	if @p_is_paid = 'T'
		set @p_is_paid = '1' ;
	else
		set @p_is_paid = '0' ;

	begin try
		if exists
		(
			select	1
			from	cashier_transaction ct with (nolock)
					inner join cashier_received_request crr with (nolock) on (crr.code = ct.received_request_code)
			where	ct.code					= @p_cashier_transaction_code
					and pdc_allocation_type = 'INS'
					and doc_ref_flag		= 'PDC'
		)
		begin
			if @p_transaction_code = 'DPINSI'
			begin
				insert into cashier_transaction_detail
				(
					cashier_transaction_code
					,transaction_code
					,received_request_code
					,agreement_no
					,is_paid
					,innitial_amount
					,orig_amount
					,orig_currency_code
					,exch_rate
					,base_amount
					,installment_no
					,remarks
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(	@p_cashier_transaction_code
					,@p_transaction_code
					,@p_received_request_code
					,@p_agreement_no
					,@p_is_paid
					,@p_innitial_amount
					,@p_orig_amount
					,@p_orig_currency_code
					,@p_exch_rate
					,@p_base_amount
					,@p_installment_no
					,@p_remarks
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end ;
		end ;
		else
		begin
			if exists
			(
				select	1
				from	dbo.cashier_transaction with (nolock)
				where	code					= @p_cashier_transaction_code
						and is_received_request = '1'
			)
			begin
				if (
					   isnull(@p_innitial_amount, 0) <> 0
					   or	@p_transaction_code in
				(
					'DPINST', 'TOLAMT'
				)
				   )
				begin
					if exists
					(
						select	1
						from	dbo.cashier_received_request with (nolock)
						where	code			   = @p_received_request_code
								and request_status <> 'HOLD'
					)
					begin
						select	@transaction_code = process_reff_code
								,@transaction_name = process_reff_name
						from	dbo.cashier_received_request with (nolock)
						where	code = @p_received_request_code ;

						set @msg = 'Received Request is in ' + @transaction_name + ', Transaction No : ' + @transaction_code ;

						raiserror(@msg, 16, -1) ;
					end ;

					insert into cashier_transaction_detail
					(
						cashier_transaction_code
						,transaction_code
						,received_request_code
						,agreement_no
						,is_paid
						,innitial_amount
						,orig_amount
						,orig_currency_code
						,exch_rate
						,base_amount
						,installment_no
						,remarks
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					values
					(	@p_cashier_transaction_code
						,@p_transaction_code
						,@p_received_request_code
						,@p_agreement_no
						,@p_is_paid
						,@p_innitial_amount
						,@p_orig_amount
						,@p_orig_currency_code
						,@p_exch_rate
						,@p_base_amount
						,@p_installment_no
						,@p_remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;
				end ;
			end ;
			else
			begin
				if (
					   isnull(@p_innitial_amount, 0) <> 0
					   or	@p_transaction_code in
				(
					'DPINSI', 'DPINST', 'DPOTH', 'SPND'
				)
				   )
				begin
					if exists
					(
						select	1
						from	dbo.cashier_received_request with (nolock)
						where	code			   = @p_received_request_code
								and request_status <> 'HOLD'
					)
					begin
						select	@transaction_code = process_reff_code
								,@transaction_name = process_reff_name
						from	dbo.cashier_received_request with (nolock)
						where	code = @p_received_request_code ;

						set @msg = 'Received Request is in ' + @transaction_name + ', Transaction No : ' + @transaction_code ;

						raiserror(@msg, 16, -1) ;
					end ;

					insert into cashier_transaction_detail
					(
						cashier_transaction_code
						,transaction_code
						,received_request_code
						,agreement_no
						,is_paid
						,innitial_amount
						,orig_amount
						,orig_currency_code
						,exch_rate
						,base_amount
						,installment_no
						,remarks
						--
						,cre_date
						,cre_by
						,cre_ip_address
						,mod_date
						,mod_by
						,mod_ip_address
					)
					values
					(	@p_cashier_transaction_code
						,@p_transaction_code
						,@p_received_request_code
						,@p_agreement_no
						,@p_is_paid
						,@p_innitial_amount
						,@p_orig_amount
						,@p_orig_currency_code
						,@p_exch_rate
						,@p_base_amount
						,@p_installment_no
						,@p_remarks
						--
						,@p_cre_date
						,@p_cre_by
						,@p_cre_ip_address
						,@p_mod_date
						,@p_mod_by
						,@p_mod_ip_address
					) ;
				end ;
			end ;
		end ;

		if (isnull(@p_received_request_code, '') <> '')
		begin
			update	dbo.cashier_received_request
			set		request_status		= 'ON PROCESS'
					,process_reff_code	= @p_cashier_transaction_code
					,process_reff_name	= 'CASHIER'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_received_request_code

			select	@sum_amount = isnull(sum(isnull(base_amount, 0)),0)
			from	dbo.cashier_transaction_detail with (nolock)
			where	cashier_transaction_code = @p_cashier_transaction_code
					and is_paid = '1'

			select	@rate_amount = cashier_exch_rate
			from	dbo.cashier_transaction with (nolock)
			where	code = @p_cashier_transaction_code

			update	dbo.cashier_transaction
			set		cashier_orig_amount		= (@sum_amount / @rate_amount) - deposit_used_amount
					,received_amount		= @sum_amount / @rate_amount
					,cashier_base_amount	= @sum_amount
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_cashier_transaction_code;
		end ;

		set @p_id = @@identity ; 
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
