CREATE PROCEDURE [dbo].[xsp_cashier_transaction_detail_auto_allocate]
(
	@p_code					nvarchar(50)
	,@p_rate				decimal(18, 6)
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
	declare @msg								   nvarchar(max)
			,@received_amount					   decimal(18, 2)
			,@innitial_amount					   decimal(18, 2)
			,@cashier_trx_date					   datetime
			,@transaction_code					   nvarchar(50)
			,@transaction_id					   bigint
			,@is_partial						   nvarchar(1)
			,@is_paid							   nvarchar(1)
			,@currency_code						   nvarchar(3)
			,@first								   int			 = 1
			,@transaction_code_temp				   nvarchar(50)
			,@results							   nvarchar(500)
			,@remarks							   nvarchar(4000)
			,@total_paid_amount					   decimal(18, 2)
			,@tolerance_amount					   decimal(18, 2)
			,@total_received_amount				   decimal(18, 2)
			,@transaction_code_tolerance		   nvarchar(50)
			,@transaction_code_deposit_installment nvarchar(50) ;

	begin try

		select	@tolerance_amount = cast(value as decimal(18, 2))
		from	dbo.sys_global_param
		where	code = 'TOLAMT' ;
		
	
		if exists (select 1 from dbo.cashier_transaction where code = @p_code and cashier_base_amount <= 0)
		begin
			set @msg = 'Please input Base Amount';
			raiserror(@msg ,16,-1)
		end
		else
		begin
			select	@received_amount	= cashier_base_amount  
					,@cashier_trx_date	= cashier_trx_date
					,@currency_code		= am.currency_code
			from	dbo.cashier_transaction ct
					left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no) -- Louis Kamis, 26 Juni 2025 13.46.33 -- 
			where	code = @p_code

			select	@total_paid_amount = isnull(sum(isnull(base_amount, 0)),0)
			from	dbo.cashier_transaction_detail
			where	cashier_transaction_code = @p_code
					and transaction_code is null

			if exists (select 1 from dbo.cashier_transaction where code = @p_code and is_received_request = '1')
			begin
				select	@transaction_code_tolerance = value
				from	dbo.sys_global_param
				where	code = 'TOLAMTGL' ;

				select	@transaction_code_deposit_installment = value
				from	dbo.sys_global_param
				where	code = 'DPSINSTGL' ;
						   
				
				-- pengecekan jika uang yang diterima lebih kecil dari pada tagihan
				if (@received_amount < @total_paid_amount)
				begin
					set @total_received_amount = @received_amount - @total_paid_amount

					if (@total_received_amount < 0)
					begin
						set @total_received_amount = @total_received_amount * -1 ;
					end ;
					
					if (@total_received_amount <= @tolerance_amount)
					begin  
						update	dbo.cashier_transaction_detail
						set		orig_amount						= (@received_amount - @total_paid_amount) / @p_rate
								,exch_rate						= @p_rate
								,base_amount					= @received_amount - @total_paid_amount
								,is_paid						= '1'
								,mod_date						= @p_mod_date
								,mod_by							= @p_mod_by
								,mod_ip_address					= @p_mod_ip_address
						where	transaction_code				= @transaction_code_tolerance
								and cashier_transaction_code	= @p_code 
					end
					else
					begin 
						update	dbo.cashier_transaction_detail
						set		orig_amount					 = @received_amount / @p_rate
								,exch_rate					 = @p_rate
								,base_amount				 = @received_amount
								,is_paid					 = '1'
								,mod_date					 = @p_mod_date
								,mod_by						 = @p_mod_by
								,mod_ip_address				 = @p_mod_ip_address
						where	transaction_code			 = @transaction_code_deposit_installment
								and cashier_transaction_code = @p_code ;

						update cashier_transaction_detail
						set		is_paid						= '0'	 
								--
								,mod_date					 = @p_mod_date
								,mod_by						 = @p_mod_by
								,mod_ip_address				 = @p_mod_ip_address
						where	cashier_transaction_code = @p_code
								and transaction_code is null
					end
				end
				-- jika uang diterima lebih besar daripada tagihan
				else if (@received_amount > @total_paid_amount)
				begin 
					set @total_received_amount = @received_amount - @total_paid_amount;
					update	dbo.cashier_transaction_detail
					set		orig_amount					 = @total_received_amount  / @p_rate
							,exch_rate					 = @p_rate
							,base_amount				 = @total_received_amount
							,is_paid					 = '1'
							,mod_date					 = @p_mod_date
							,mod_by						 = @p_mod_by
							,mod_ip_address				 = @p_mod_ip_address
					where	transaction_code			 = @transaction_code_deposit_installment
							and cashier_transaction_code = @p_code ;
							
					update cashier_transaction_detail
					set		is_paid						= '1'	 
							--
							,mod_date					 = @p_mod_date
							,mod_by						 = @p_mod_by
							,mod_ip_address				 = @p_mod_ip_address
					where	cashier_transaction_code = @p_code
							and transaction_code is null
				end 
				-- jika uang diterima sama dengan tagihan
				else
				begin
					update cashier_transaction_detail
					set		is_paid						= '1'	 
							--
							,mod_date					 = @p_mod_date
							,mod_by						 = @p_mod_by
							,mod_ip_address				 = @p_mod_ip_address
					where	cashier_transaction_code = @p_code
							and transaction_code is null
				end
				
				-- menghapus transaksi yang tidak memiliki tagihan (khusus Deposit/Tolerance Amount)	 
				delete	from cashier_transaction_detail
				where	cashier_transaction_code = @p_code
						and transaction_code is not null
						and base_amount			 = 0 ;
			end
			else
			begin	 			 
			
			DECLARE cur_cashier_transaction_detail cursor fast_forward read_only for 
				select		ctd.id
							,ctd.innitial_amount * @p_rate
							,cpd.is_partial
							,ctd.transaction_code
				from		dbo.cashier_transaction_detail ctd
							inner join dbo.master_cashier_priority_detail cpd on (cpd.transaction_code = ctd.transaction_code)
							inner join dbo.master_cashier_priority mcp on (mcp.code					   = cpd.cashier_priority_code)
				where		ctd.cashier_transaction_code = @p_code
							and mcp.is_default			 = '1'
				order by	cpd.order_no asc
							,ctd.installment_no asc ;

				open cur_cashier_transaction_detail
		
				fetch next from cur_cashier_transaction_detail 
				into	@transaction_id
						,@innitial_amount
						,@is_partial
						,@transaction_code

				while @@fetch_status = 0
				begin  
					if (@first = 1)
					begin
						set	@transaction_code_temp = @transaction_code;
						set @first = 2;
						set @is_paid = '1';
					end

					if (@transaction_code_temp <> @transaction_code)
					begin
						set	@transaction_code_temp = @transaction_code;
						set @first = 1;
						set @is_paid = '1';
					end

					if (@received_amount >= @innitial_amount and @innitial_amount <> 0)
					begin
						if(@is_paid = '1' and @transaction_code_temp = @transaction_code)
						begin
							update	dbo.cashier_transaction_detail
							set		orig_amount		= @innitial_amount / @p_rate   
									,exch_rate		= @p_rate
									,base_amount	= @innitial_amount 
									,is_paid		= '1'
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address	= @p_mod_ip_address
							where	id				= @transaction_id
							set @received_amount	= @received_amount - @innitial_amount 
						end
					end
					else if (@received_amount <> 0 and @innitial_amount <> 0 and @is_partial = '1')
					begin
						update	dbo.cashier_transaction_detail
						set		orig_amount		= @received_amount / @p_rate
								,exch_rate		= @p_rate
								,base_amount	= @received_amount 
								,is_paid		= '1'
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	id				= @transaction_id
						set @received_amount	= 0;
					end
					else
					begin
						update	dbo.cashier_transaction_detail
						set		orig_amount		= 0
								,exch_rate		= @p_rate
								,base_amount	= 0
								,is_paid		= '0'
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	id				= @transaction_id

						set @is_paid = '0'
					end
                
					fetch next from cur_cashier_transaction_detail 
					into	@transaction_id
							,@innitial_amount
							,@is_partial
							,@transaction_code
			
				end
				close cur_cashier_transaction_detail
				deallocate cur_cashier_transaction_detail

				if (@received_amount > 0)
				begin
					if exists
					(
						select	1
						from	dbo.cashier_transaction_detail
						where	cashier_transaction_code = @p_code
								and transaction_code	 = 'DPINST'
					)
					begin
						update	dbo.cashier_transaction_detail
						set		orig_amount					 = @received_amount / @p_rate
								,exch_rate					 = @p_rate
								,base_amount				 = @received_amount
								,is_paid					 = '1'
								,mod_date					 = @p_mod_date
								,mod_by						 = @p_mod_by
								,mod_ip_address				 = @p_mod_ip_address
						where	transaction_code			 = 'DPINST'
								and cashier_transaction_code = @p_code ;
					end ;

					set @received_amount	= 0;
				end
			end
			
			if exists
			(
				select	1
				from	dbo.cashier_transaction_detail
				where	cashier_transaction_code = @p_code
						and transaction_code	 = 'INST'
						and is_paid				 = '1'
			)
			begin
				select	@remarks = cashier_remarks
				from	dbo.cashier_transaction
				where	code = @p_code

				select		@results = coalesce(@results + ',', '') + convert(varchar(12), installment_no)
				from		dbo.cashier_transaction_detail
				where		transaction_code			 = 'INST'
							and cashier_transaction_code = @p_code
							and is_paid					 = '1'
				order by	installment_no asc

				if ((
						select	charindex('For Installment', @remarks, 1)
					) > 0
					)
				begin
					set @remarks = left(@remarks, charindex(' For Installment', @remarks, 1) - 1)
				end

				update	dbo.cashier_transaction
				set		cashier_remarks = @remarks + ' For Installment ' + @results
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code
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

end



