CREATE PROCEDURE dbo.xsp_et_main_update
(
	@p_code				nvarchar(50)
	,@p_et_date			datetime
	,@p_et_remarks		nvarchar(4000)  
	,@p_agreement_no    nvarchar(50)
	,@p_reason			nvarchar(4000)	= ''
	,@p_bank_code		nvarchar(50)	= ''
	,@p_bank_name		nvarchar(250)	= ''
	,@p_bank_account_no	nvarchar(50)	= ''
	,@p_bank_account_name	nvarchar(250)	 = ''
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@et_exp_date	datetime 
			,@total_amount	decimal(18, 2)			
			,@agreement_external_no nvarchar(50)
			,@bast_date				datetime
			,@credit_amount			decimal(18, 2)
			,@refund_amount			decimal(18, 2)
			,@billing_type			nvarchar(50)
			,@billing_amount		decimal(18, 2)
			,@days_month			int
			,@days_et				int
			,@due_date				datetime
			,@pro_rate				decimal(18, 2)
			,@invoice_status		nvarchar(10)
			,@invoice_no			nvarchar(50)
			,@invoice_date			datetime
			,@et_date				datetime
			,@asset_no				nvarchar(50)
			,@agreement_no			nvarchar(50)
			,@sum_credit_amount		decimal(18,2)
			,@sum_refund_amount		decimal(18,2)
			,@penalty_charges		decimal(18,2)
			,@et_interim			decimal(18,2)
			,@multiplier			int
			,@first_payment_type	nvarchar(15); 

	begin try
		select	@et_exp_date = dateadd(day, cast(value as int), @p_et_date)
		from	dbo.sys_global_param
		where	code = 'EXPOPL' ; 
		
		-- (sepria 21/04/2025:2504000068 - validasi hanya per asset saja untuk cover juga case yg billing scheme) validasi pindah ke et detail dan saat proceed
		----(+ 2329684)
		--declare @invoice_date			datetime
		--		,@bast_date				datetime

		--if exists (select 1 FROM dbo.AGREEMENT_ASSET_AMORTIZATION where AGREEMENT_NO = @p_agreement_no and isnull(INVOICE_NO,'') <> '')
		--begin
		--	select	top 1
		--			@invoice_date = i.INVOICE_DATE
		--	from	dbo.AGREEMENT_ASSET_AMORTIZATION	aaa
		--			inner join dbo.INVOICE			i on i.INVOICE_NO = aaa.INVOICE_NO
		--	where AGREEMENT_NO = @p_agreement_no and i.INVOICE_STATUS in ('NEW', 'POST', 'PAID')
		--	order by i.INVOICE_DATE desc ;

		--	if @p_et_date < @invoice_date
		--	begin
		--		set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'Invoice Date') ;

		--		raiserror(@msg, 16, 1) ;
		--	end
		--end

		--select top 1
		--		@bast_date = handover_bast_date 
		--from dbo.AGREEMENT_ASSET 
		--where AGREEMENT_NO = @p_agreement_no

		--if @p_et_date < @bast_date
		--	begin
		--		set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'Bast Date') ;

		--		raiserror(@msg, 16, 1) ;
		--	end


		--(raffi 2329684)  

		--IF (@p_et_date < dbo.xfn_get_system_date())
		--BEGIN
		--	SET @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'System Date');

		--	RAISERROR(@msg, 16, 1);
		--END;
		
		-- untuk mereeset jika terjadi perubahan tgl pada etmain update ke et_detail isterminate menjadi 1
		if exists
		(
			select	1
			from	dbo.et_main
			where	code		= @p_code
					and et_date <> @p_et_date
		)
		begin
			--update	dbo.et_detail
			--set		is_terminate = '1'
			--where	et_code = @p_code ;
			
		 
			--insert to et_transaction
			exec dbo.xsp_et_transaction_generate @p_et_code			= @p_code
												 ,@p_agreement_no	= @p_agreement_no
												 ,@p_et_date		= @p_et_date
												 ,@p_cre_date		= @p_mod_date		
												 ,@p_cre_by			= @p_mod_by			
												 ,@p_cre_ip_address = @p_mod_ip_address	
												 ,@p_mod_date		= @p_mod_date
												 ,@p_mod_by			= @p_mod_by
												 ,@p_mod_ip_address = @p_mod_ip_address

			select	@total_amount = isnull(sum(total_amount), 0)
			from	dbo.et_transaction
			where	et_code			   = @p_code
					and is_transaction = '1' ;

			update	dbo.et_main
			set		et_amount		   = @total_amount
					--
					,@p_mod_date	   = @p_mod_date
					,@p_mod_by		   = @p_mod_by
					,@p_mod_ip_address = @p_mod_ip_address 
			where	code			   = @p_code ;
		end ;

		select	@billing_type = a.billing_type
				,@multiplier	= mbt.multiplier
				,@first_payment_type	= a.first_payment_type
		from	dbo.agreement_main a
				inner join dbo.master_billing_type mbt on mbt.code = a.billing_type
		where	a.agreement_no = @p_agreement_no ;

		declare cursor_name cursor fast_forward read_only for
		select	asset_no
		from	dbo.et_detail
		where	et_code = @p_code
		
		open cursor_name
		
		fetch next from cursor_name 
		into @asset_no
		
		while @@fetch_status = 0
		begin
			--if (@first_payment_type = 'ARR')
			--begin

			--	select	@billing_amount	 = billing_amount
			--			,@days_month	 = datediff(day, dateadd(month,@multiplier*-1, a.due_date), a.due_date)
			--			,@due_date		 = a.due_date
			--			,@invoice_status = b.invoice_status
			--	from	dbo.agreement_asset_amortization a
			--			inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
			--	where	@p_et_date
			--			between dateadd(month,@multiplier*-1, a.due_date) and a.due_date
			--			and a.asset_no = @asset_no
			--			and b.invoice_status in('POST','PAID') ;

			--	set @days_et = ABS(DATEDIFF(day, @due_date, @p_et_date)) ;
			--	set @pro_rate = round(@billing_amount / (@days_month) * @days_et,0) ;

			--	if (@invoice_status = 'POST')
			--	begin
			--		update	dbo.et_detail
			--		set		credit_amount = @pro_rate
			--				,refund_amount = 0
			--		where	asset_no = @asset_no ;
			--	end ;
			--	else if (@invoice_status = 'PAID')
			--	begin
			--		update	dbo.et_detail
			--		set		refund_amount = @pro_rate
			--				,credit_amount = 0
			--		where	asset_no = @asset_no ;
			--	end ;
			--end ;
			--------------------------------------------------------------- fauzan
			--else if (@first_payment_type = 'ADV')
			--begin
			
			--	select	@billing_type = a.billing_type
			--	from	dbo.agreement_main a
			--	where	a.agreement_no = @p_agreement_no ;

			--	select	@billing_amount	 = billing_amount
			--			,@days_month	 = datediff(day, dateadd(month,@multiplier, a.due_date), a.due_date)
			--			,@due_date		 = a.due_date
			--			,@invoice_status = b.invoice_status
			--	from	dbo.agreement_asset_amortization a
			--			inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
			--	where	@p_et_date
			--			between dateadd(month,@multiplier, a.due_date) and a.due_date
			--			and a.asset_no = @asset_no
			--			and b.invoice_status in('POST','PAID') ;

			--	set @days_et = ABS(DATEDIFF(day, @due_date, @p_et_date)) ;
			--	set @pro_rate = round(@billing_amount / (@days_month) * @days_et,0) ;

			--	if (@invoice_status = 'POST')
			--	begin
			--		update	dbo.et_detail
			--		set		credit_amount = @pro_rate
			--				,refund_amount = 0
			--		where	asset_no = @asset_no ;
			--	end ;
			--	else if (@invoice_status = 'PAID')
			--	begin
			--		update	dbo.et_detail
			--		set		refund_amount = @pro_rate
			--				,credit_amount = 0
			--		where	asset_no = @asset_no ;
			--	end ;
			--end ;
			--------------------------------------------------------------- fauzan
			--else
			--begin
			--	set @credit_amount = 0 ;
			--	set @refund_amount = 0 ;
			--end ;
		
			select 	@refund_amount = refund_amount,
					@credit_amount = credit_amount
			from	dbo.fn_calccreditrefund(@p_agreement_no, @asset_no, @p_et_date, @first_payment_type, @multiplier);

			-- update ke et_detail
			update	dbo.et_detail
			set		refund_amount = @refund_amount,
					credit_amount = @credit_amount
			where	et_code = @p_code
					and asset_no = @asset_no;

		    fetch next from cursor_name 
			into @asset_no
		end
		
		close cursor_name
		deallocate cursor_name
		
		exec dbo.xsp_et_main_update_amount @p_code = @p_code,                       -- nvarchar(50)
		                                   @p_mod_date = @p_mod_date, -- datetime
		                                   @p_mod_by = @p_mod_by,                     -- nvarchar(15)
		                                   @p_mod_ip_address = @p_mod_ip_address             -- nvarchar(15)

		update	et_main
		set		et_date						= @p_et_date
				,et_exp_date				= @et_exp_date
				,et_remarks					= @p_et_remarks
				,reason						= @p_reason
				,bank_code					= @p_bank_code
				,bank_name					= @p_bank_name
				,bank_account_no			= @p_bank_account_no
				,bank_account_name			= @p_bank_account_name
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;

				
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

