CREATE PROCEDURE dbo.xsp_deposit_allocation_detail_insert
(
	@p_id						bigint = 0 output
	,@p_deposit_allocation_code nvarchar(50)
	,@p_transaction_code		nvarchar(50)   = null
	,@p_received_request_code	nvarchar(50)   = null
	,@p_is_paid					nvarchar(1)
	,@p_innitial_amount			decimal(18, 2) = 0
	,@p_orig_amount				decimal(18, 2)
	,@p_orig_currency_code		nvarchar(3)
	,@p_exch_rate				decimal(18, 6)
	,@p_base_amount				decimal(18, 2)
	,@p_installment_no			int = null
	,@p_remarks					nvarchar(4000)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@transaction_code		nvarchar(50)
			,@transaction_name		nvarchar(250)
			,@sum_amount			decimal(18, 2)
			,@allocation_exch_rate	decimal(18, 6)
	
	if @p_is_paid = 'T'
		set @p_is_paid = '1' ;
	else
		set @p_is_paid = '0' ;

	begin try
	if (isnull(@p_innitial_amount,0) <> 0)
	begin
		if exists (select 1 from dbo.cashier_received_request where code = @p_received_request_code and request_status <> 'HOLD')
		begin
			select	@transaction_code	= process_reff_code
					,@transaction_name	= process_reff_name 
			from	dbo.cashier_received_request 
			where	code = @p_received_request_code

		    set @msg = 'Received Request is in ' + @transaction_name + ', Transaction No : '+ @transaction_code;
			raiserror(@msg ,16,-1);
		end

		insert into deposit_allocation_detail
		(
			deposit_allocation_code
			,transaction_code
			,received_request_code
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
		(	@p_deposit_allocation_code
			,@p_transaction_code
			,@p_received_request_code
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

		set @p_id = @@identity ;

		if(isnull(@p_received_request_code,'') <> '')
		begin
		    update	dbo.cashier_received_request
			set		request_status		= 'ON PROCESS'
					,process_reff_code	= @p_deposit_allocation_code
					,process_reff_name	= 'DEPOSIT'
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_received_request_code

			select	@sum_amount = isnull(sum(orig_amount),0)
			from	dbo.deposit_allocation_detail
			where	deposit_allocation_code = @p_deposit_allocation_code
					and is_paid = '1'

			select	@allocation_exch_rate = allocation_exch_rate
			from	dbo.deposit_allocation
			where	code = @p_deposit_allocation_code

			update	dbo.deposit_allocation
			set		allocation_orig_amount	= @sum_amount
					,allocation_base_amount	= @sum_amount * @allocation_exch_rate
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_deposit_allocation_code;
		end
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
end ;
