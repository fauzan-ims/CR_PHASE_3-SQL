--created by, Rian at /06/2023 

CREATE PROCEDURE dbo.xsp_payment_transaction_proceed
(
	@p_code					nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare	@msg	nvarchar(max)
			-- (+) Ari 2023-11-03
			,@get_time				   time
			,@start_transaction		   time
			,@end_transaction	       time
			,@amount				   decimal(18,2)
			,@glink_code			   nvarchar(50)
			,@branch_bank_code			nvarchar(50)
			,@to_bank_name				nvarchar(50)
			,@bank_code					nvarchar(50)

	begin try
		
		-- (+) Ari 2023-11-03
		set @get_time = cast(getdate() as time)
		set @start_transaction = cast('23:59:59' as time)

		select	@end_transaction = value + ':00:00'
		from	dbo.sys_global_param
		where	code = 'MTPS'

		select	@glink_code = bank_gl_link_code 
				,@branch_bank_code= branch_bank_code
				,@to_bank_name	= to_bank_name
		from	dbo.payment_transaction
		where	code = @p_code
		
		--sepria 22092025: tutup karna lagi sit
		---- (+) Ari 2023-11-03 ket : validasi jika batas pembayaran host to host sudah melebihi
		--if(@get_time between @end_transaction and @start_transaction and @glink_code = 'MUFG168')
		--begin
		--	set @msg = 'Cannot Proceed Payment because Payment Host to Host Closed at ' + cast(@end_transaction as nvarchar(8)) + ' WIB'
		--	raiserror(@msg, 16, -1)
		--end
		
		select	@amount = payment_orig_amount
		from	dbo.payment_transaction
		where	code = @p_code

		-- (+) Ari 2023-11-03 ket : validasi jika limit sudah max
		if exists
		(
			select	1
			from	dbo.bank_mutation_history 
			outer	apply (
							select	cast(replace(replace(value,'.',''),',','') as decimal(18,2)) 'value'
							from	dbo.sys_global_param 
							where	code = 'MBTD'
							) limit
			outer	apply (
							select	isnull(sum(payment_amount),0) 'amount'
							from	payment_request 
							where	mod_date > cast(dbo.xfn_get_system_date() as datetime)
							and		payment_status in ('ON PROCESS')
						  ) onpay
			where	source_reff_name = 'Payment Confirm'
			and		transaction_date = dbo.xfn_get_system_date()
			and		bank_mutation_code in (select code from dbo.bank_mutation where branch_bank_name = 'MUFG' and gl_link_code = 'MUFG168')
			group	by	limit.value	
						,onpay.amount
			having	((limit.value + isnull(sum(orig_amount),0)) - onpay.amount) <= 0
		)
		begin
			set @msg = 'Cannot Continue Payment because Payment has reached the Limit'
			raiserror(@msg, 16, -1)
		end
		else if(@amount > (	select	cast(replace(replace(value,'.',''),',','') as decimal(18,2))
							from	dbo.sys_global_param 
							where	code = 'MBTD'
						  ))
		begin
			set @msg = 'Cannot Continue Payment because Payment has reached the Limit'
			raiserror(@msg, 16, -1)
		end
		
		select	@bank_code = sbb.master_bank_code
		from	ifinsys.dbo.sys_branch_bank sbb
		where	sbb.code = @branch_bank_code

		-- imont:2505000165 sepria 02062025
		if(@bank_code = '042' AND @to_bank_name LIKE '%MUFG%')
		begin
		    set @msg = 'Cannot Payment Form MUFG to MUFG'
			raiserror(@msg, 16, -1)
		END
        
		-- (+) Ari 2023-11-03
		
		if exists (select 1 from dbo.payment_transaction where code = @p_code and payment_status <> 'HOLD')
		begin
			set @msg = dbo.xfn_get_msg_err_data_already_proceed();
			raiserror(@msg ,16,-1)
		end
		else
		begin
			update	dbo.payment_transaction
			set		payment_status		= 'ON PROCESS'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
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
END
