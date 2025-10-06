CREATE PROCEDURE dbo.xsp_deposit_allocation_detail_update
(
	@p_id						bigint
	,@p_deposit_allocation_code nvarchar(50)
	--,@p_transaction_code		nvarchar(50)
	--,@p_received_request_code	nvarchar(50)
	,@p_is_paid					nvarchar(1)
	--,@p_innitial_amount			decimal(18, 2)
	--,@p_orig_amount				decimal(18, 2)
	--,@p_orig_currency_code		nvarchar(3)
	--,@p_exch_rate				decimal(18, 6)
	,@p_base_amount				decimal(18, 2)
	--,@p_installment_no			int
	--,@p_remarks					nvarchar(4000)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@sum_amount			decimal(18, 2)
			,@allocation_exch_rate	decimal(18, 6)

	if @p_is_paid = 'T'
		set @p_is_paid = '1' ;
	else
		set @p_is_paid = '0' ;

	begin try
		--if (	(select isnull(deposit_amount,0) from dbo.deposit_allocation where code = @p_deposit_allocation_code) <
		--		((select isnull(sum(orig_amount),0) from dbo.deposit_allocation_detail where deposit_allocation_code = @p_deposit_allocation_code and is_paid = '1' and id <> @p_id) +
		--		(select isnull(sum(orig_amount),0) from dbo.deposit_allocation_detail where id = @p_id and is_paid = '1'))
		--	)
		--begin
		--	set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Total Allocated Amount','Outstanding Deposit Amount');
		--	raiserror(@msg ,16,-1)
		--end
		--else
		--begin
			update	deposit_allocation_detail
			set		deposit_allocation_code		= @p_deposit_allocation_code
					--,transaction_code			= @p_transaction_code
					--,received_request_code		= @p_received_request_code
					,is_paid					= @p_is_paid
					--,innitial_amount			= @p_innitial_amount
					,orig_amount				= @p_base_amount / exch_rate
					--,orig_currency_code			= @p_orig_currency_code
					--,exch_rate					= @p_exch_rate
					,base_amount				= @p_base_amount
					--,installment_no				= @p_installment_no
					--,remarks					= @p_remarks
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	id							= @p_id 
					--and is_paid					= '1';

			select	@sum_amount = isnull(sum(base_amount),0)
			from	dbo.deposit_allocation_detail
			where	deposit_allocation_code = @p_deposit_allocation_code
					and is_paid = '1'

			select	@allocation_exch_rate = allocation_exch_rate
			from	dbo.deposit_allocation
			where	code = @p_deposit_allocation_code

			update	dbo.deposit_allocation
			set		allocation_orig_amount	= @sum_amount / @allocation_exch_rate
					,allocation_base_amount	= @sum_amount 
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_deposit_allocation_code;

		--end
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
end;
