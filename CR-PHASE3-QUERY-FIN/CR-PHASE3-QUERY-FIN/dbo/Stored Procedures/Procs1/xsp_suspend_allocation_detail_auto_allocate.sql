CREATE PROCEDURE dbo.xsp_suspend_allocation_detail_auto_allocate
(
	@p_code				nvarchar(50)
	,@p_rate			decimal(18, 6)
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
	declare	@msg					nvarchar(max)
			,@suspend_amount		decimal(18, 2)
			,@innitial_amount		decimal(18, 2)
			,@currency_code			nvarchar(3)
			,@allocation_trx_date	datetime
			,@transaction_id		bigint
			,@is_partial			nvarchar(1)
			,@sum_amount			decimal(18, 2)
			,@allocation_exch_rate	decimal(18, 6)

	begin try
	
		if exists (select 1 from dbo.suspend_allocation where code = @p_code and suspend_amount <= 0)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_greater_than('Outstanding Suspend Amount','0');
			raiserror(@msg ,16,-1)
		end
		else
		begin
			
			select	@suspend_amount = suspend_amount * allocation_exch_rate
					,@allocation_trx_date	= allocation_trx_date
					,@currency_code			= am.currency_code
			from	dbo.suspend_allocation sa
					inner join dbo.agreement_main am on (am.agreement_no = sa.agreement_no)
			where	code = @p_code

			declare cur_suspend_allocation_detail cursor fast_forward read_only for
			
			select		ctd.id 
						,ctd.innitial_amount * @p_rate
						,cpd.is_partial
			from		dbo.suspend_allocation_detail ctd
						inner join dbo.master_cashier_priority_detail cpd on (cpd.transaction_code = ctd.transaction_code)
						inner join dbo.master_cashier_priority mcp on (mcp.code = cpd.cashier_priority_code)
			where		ctd.suspend_allocation_code	= @p_code
						and	mcp.is_default				= '1'	
			order by	cpd.order_no asc,
						ctd.installment_no asc

			open cur_suspend_allocation_detail
		
			fetch next from cur_suspend_allocation_detail 
			into	@transaction_id
					,@innitial_amount
					,@is_partial

			while @@fetch_status = 0
			begin
				
				if (@innitial_amount > 0)
				begin
					if (@suspend_amount >= @innitial_amount)
					begin
					    update	dbo.suspend_allocation_detail
						set		orig_amount		= @innitial_amount / @p_rate
								,exch_rate		= @p_rate
								,base_amount	= @innitial_amount
								,is_paid		= '1'
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	id				= @transaction_id

						set @suspend_amount	= @suspend_amount - @innitial_amount 
					end
					else if (@suspend_amount != 0 and @is_partial = '1')
					begin
					    update	dbo.suspend_allocation_detail
						set		orig_amount		= @suspend_amount / @p_rate
								,exch_rate		= @p_rate
								,base_amount	= @suspend_amount
								,is_paid		= '1'
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	id				= @transaction_id

						set @suspend_amount	= 0;
					end
					else
					begin
					    update	dbo.suspend_allocation_detail
						set		orig_amount		= 0
								,exch_rate		= @p_rate
								,base_amount	= 0
								,is_paid		= '0'
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	id				= @transaction_id
					end
				end
				fetch next from cur_suspend_allocation_detail 
				into	@transaction_id
						,@innitial_amount
						,@is_partial
			
			end
			close cur_suspend_allocation_detail
			deallocate cur_suspend_allocation_detail

			if (@suspend_amount > 0)
			begin
			    update	dbo.suspend_allocation_detail
				set		orig_amount		= @suspend_amount / @p_rate
						,exch_rate		= @p_rate
						,base_amount	= @suspend_amount
						,is_paid		= '1'
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	transaction_code ='DPINST'

				set @suspend_amount	= 0;
			end

			select	@sum_amount = isnull(sum(base_amount),0)
			from	dbo.suspend_allocation_detail
			where	suspend_allocation_code = @p_code
					and is_paid = '1'

			select	@allocation_exch_rate = allocation_exch_rate
			from	dbo.suspend_allocation
			where	code = @p_code

			update	dbo.suspend_allocation
			set		allocation_orig_amount	= @sum_amount / @allocation_exch_rate
					,allocation_base_amount	= @sum_amount  
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code;

		end
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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


