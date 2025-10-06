CREATE PROCEDURE dbo.xsp_et_main_insert 
(
	@p_code			   nvarchar(50)	  = '' output
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_agreement_no   nvarchar(50)
	,@p_et_status	   nvarchar(10)
	,@p_et_date		   datetime
	,@p_et_amount	   decimal(18, 2) = 0
	,@p_et_remarks	   nvarchar(4000) = ''
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
AS
BEGIN
declare @msg					nvarchar(max)
		,@et_exp_date			datetime
		,@year					nvarchar(2)
		,@month					nvarchar(2)
		,@code					nvarchar(50)
		,@opl_status			nvarchar(15)
		,@transaction_code		nvarchar(50)
		,@transaction_amount	decimal(18, 2)
		,@disc_pct				decimal(9, 6)
		,@disc_amount			decimal(18, 2)
		,@order_key				int
		,@is_amount_editable	nvarchar(1)
		,@is_discount_editable	nvarchar(1)
		,@is_transaction		nvarchar(1)
		,@total_amount			decimal(18, 2)
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
        ,@first_payment_type	nvarchar(15)

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLEM'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'ET_MAIN'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		select	@et_exp_date = dateadd(day, cast(value as int), @p_et_date)
		from	dbo.sys_global_param
		where	code = 'EXPOPL' ;

		if not exists
		(
			select	1
			from	dbo.agreement_main
			where	agreement_no			   = @p_agreement_no
					and isnull(opl_status, '') = ''
		)
		begin
			select	@opl_status				= opl_status
					,@agreement_external_no = agreement_external_no
			from	dbo.agreement_main
			where	agreement_no = @p_agreement_no ;

			set @msg = N'Agreement : ' + @p_agreement_no + N' already in use at ' + @opl_status ;

			raiserror(@msg, 16, 1) ;
		end ;

		if exists
		(
			select	1
			from	et_main
			where	agreement_no = @p_agreement_no
					and et_status not in
		(
			'CANCEL', 'APPROVE', 'EXPIRED', 'REJECT'
		)
		)
		begin
			select	@p_et_status			= et.et_status
					,@agreement_external_no	= am.agreement_external_no
			from	et_main et
			inner join dbo.agreement_main am on (am.agreement_no = et.agreement_no)
			where	et.agreement_no = @p_agreement_no
					and et_status not in
			(
				'CANCEL', 'APPROVE', 'EXPIRED', 'REJECT'
			) ;

			set @msg = N'Agreement : ' + @p_agreement_no + N' already in transaction with Status : ' + @p_et_status ;

			raiserror(@msg, 16, -1) ;
		end ;
		  
		--if (@p_agreement_no not in ('0000870.4.08.12.2022','0001081.4.01.07.2022','0001034.4.01.05.2022','0002090.4.10.03.2024','0000942.4.01.12.2021','0001089.4.08.08.2023','0001090.4.08.08.2023','0001091.4.08.08.2023'
		--	,'0000599.4.01.01.2021','0000600.4.01.01.2021','0001829.4.10.01.2024','0001556.4.01.11.2023','0001784.4.10.01.2024','0000003.4.34.03.2021','0001183.4.08.10.2023','0001695.4.01.01.2024','0000128.4.03.02.2022'
		--	,'0001777.4.10.01.2024','0001203.4.01.12.2022','0002100.4.10.03.2024','0000125.4.03.02.2022','0002140.4.10.03.2024','0001058.4.08.07.2023','0000869.4.01.10.2021','0000038.4.38.03.2023','0001751.4.10.01.2024'
		--	,'0000220.4.03.09.2023')) --untuk data maintenance
		--begin
		--	if (@p_et_date < dbo.xfn_get_system_date())
		--	begin
		--		set @msg = dbo.xfn_get_msg_err_must_be_greater_or_equal_than('Date', 'System Date') ;

		--		raiserror(@msg, 16, 1) ;
		--	end ;
		--end

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

		insert into et_main
		(
			code
			,branch_code
			,branch_name
			,agreement_no
			,et_status
			,et_date
			,et_exp_date
			,et_amount
			,et_remarks
			,credit_note_amount
			,refund_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@code
			,@p_branch_code
			,@p_branch_name
			,@p_agreement_no
			,@p_et_status
			,@p_et_date
			,@et_exp_date
			,0
			,@p_et_remarks
			,0
			,0
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		insert into dbo.et_detail
		(
			et_code
			,asset_no
			,os_rental_amount
			,is_terminate
			,is_approve_to_sell
			,credit_amount
			,refund_amount
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select		@code
					,aa.asset_no
					,dbo.xfn_agreement_get_all_os_principal(@p_agreement_no, @p_et_date, aa.asset_no)
					,'1'
					,'0'
					,0
					,0
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
		from		dbo.agreement_asset aa
		where		aa.agreement_no		= @p_agreement_no
					and aa.asset_status = 'RENTED'
		group by	aa.asset_no ;
		
		--insert to et_transaction
		exec dbo.xsp_et_transaction_generate @p_et_code			= @code
											 ,@p_agreement_no	= @p_agreement_no
											 ,@p_et_date		= @p_et_date
											 --
											 ,@p_cre_date		= @p_cre_date
											 ,@p_cre_by			= @p_cre_by
											 ,@p_cre_ip_address = @p_cre_ip_address
											 ,@p_mod_date		= @p_mod_date
											 ,@p_mod_by			= @p_mod_by
											 ,@p_mod_ip_address = @p_mod_ip_address ;


		select	@billing_type = a.billing_type
				,@multiplier	= mbt.multiplier
				,@first_payment_type	= a.first_payment_type
		from	dbo.agreement_main a
				inner join dbo.master_billing_type mbt on mbt.code = a.billing_type
		where	a.agreement_no = @p_agreement_no ;

		declare cursor_name cursor fast_forward read_only for
		select	asset_no
		from	dbo.et_detail
		where	et_code = @code
		
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
			where	et_code = @code
					and asset_no = @asset_no;

		    fetch next from cursor_name 
			into @asset_no
		end
		
		close cursor_name
		deallocate cursor_name
	 
		--select	@total_amount = isnull(sum(total_amount), 0)
		--from	dbo.et_transaction
		--where	et_code			   = @code
		--		and is_transaction = '1' ;

		--select	@sum_credit_amount	= isnull(sum(credit_amount),0)
		--		,@sum_refund_amount = isnull(sum(refund_amount),0)
		--from	dbo.et_detail
		--where	et_code = @code 


		--select	@penalty_charges = isnull(sum(total_amount), 0)
		--from	dbo.et_transaction
		--where	et_code				 = @code
		--		and transaction_code = 'CETP' ;

		--select	@et_interim = isnull(sum(total_amount), 0)
		--from	dbo.et_transaction
		--where	et_code				 = @code
		--		and transaction_code = 'ET_INTERIM' ;
		
		--set @penalty_charges =  @penalty_charges + @et_interim

		--while @penalty_charges > 0
		--begin
		--		if @sum_refund_amount > 0
		--		begin
		--			if (@sum_refund_amount - @penalty_charges < 0)
		--			begin
		--				set @penalty_charges = abs(@sum_refund_amount - @penalty_charges)
		--				set @sum_refund_amount = 0
		--				set @total_amount = @total_amount - @penalty_charges
		--			end
		--			else
		--			begin
		--				set @sum_refund_amount = @sum_refund_amount - @penalty_charges
		--				set @penalty_charges = 0
		--				set @total_amount = @penalty_charges
		--			end
		--		end
		--		else if @sum_credit_amount > 0
		--		begin
		--			if (@sum_credit_amount - @penalty_charges < 0)
		--			begin
		--				set @penalty_charges = abs(@sum_credit_amount - @penalty_charges)
		--				set @sum_credit_amount = 0
		--				set @total_amount = @total_amount - @penalty_charges

		--			end
		--			else
		--			begin
		--				set @sum_credit_amount = @sum_credit_amount - @penalty_charges
		--				set @penalty_charges = 0
		--				set @total_amount = @penalty_charges

		--			end
		--		end
  --              else
  --              begin
  --                  set @total_amount = @penalty_charges
		--			set @penalty_charges = 0
  --              end
		--end

		--update	dbo.et_main
		--set		et_amount			= @total_amount
		--		,credit_note_amount = @sum_credit_amount
		--		,refund_amount		= @sum_refund_amount
		--		--
		--		,@p_mod_date		= @p_mod_date
		--		,@p_mod_by			= @p_mod_by
		--		,@p_mod_ip_address	= @p_mod_ip_address
		--where	code = @code ;


		exec dbo.xsp_et_main_update_amount @p_code = @p_code,                       -- nvarchar(50)
		                                @p_mod_date = @p_mod_date, -- datetime
		                                @p_mod_by = @p_mod_by,                     -- nvarchar(15)
		                                @p_mod_ip_address = @p_mod_ip_address             -- nvarchar(15)

		--if @sum_refund_amount > 0 and (@sum_refund_amount - @penalty_charges < 0)
		--begin
		--    update	dbo.et_main
		--	set		et_amount			= @total_amount
		--			,credit_note_amount = 0
		--			,refund_amount		= @sum_refund_amount - @penalty_charges - @et_interim
		--			--
		--			,@p_mod_date		= @p_mod_date
		--			,@p_mod_by			= @p_mod_by
		--			,@p_mod_ip_address	= @p_mod_ip_address
		--	where	code = @p_code ;
		--end
		--if (@sum_credit_amount = 0 and @sum_refund_amount > 0 and (@sum_refund_amount - @penalty_charges < 0)))
		--begin
		--	update	dbo.et_main
		--	set		et_amount			= @total_amount - (@sum_refund_amount - @penalty_charges)
		--			,credit_note_amount = 0
		--			,refund_amount		= @sum_refund_amount - @penalty_charges - @et_interim
		--			--
		--			,@p_mod_date		= @p_mod_date
		--			,@p_mod_by			= @p_mod_by
		--			,@p_mod_ip_address	= @p_mod_ip_address
		--	where	code = @p_code ;
		--end
		--else if (@sum_refund_amount  = 0 and (@sum_credit_amount > 0 and (@sum_credit_amount - @penalty_charges < 0)))
		--begin
		--	update	dbo.et_main
		--	set		et_amount			= @total_amount - (@sum_credit_amount - @penalty_charges)
		--			,credit_note_amount = @sum_credit_amount - @penalty_charges - @et_interim
		--			,refund_amount		= 0
		--			--
		--			,@p_mod_date		= @p_mod_date
		--			,@p_mod_by			= @p_mod_by
		--			,@p_mod_ip_address	= @p_mod_ip_address
		--	where	code = @p_code ;
		--end
  --      else if (@sum_refund_amount  > 0 and @sum_credit_amount > 0)
		--begin
		--	update	dbo.et_main
		--	set		et_amount			= @total_amount
		--			,credit_note_amount = @sum_credit_amount
		--			,refund_amount		= @sum_refund_amount - @penalty_charges - @et_interim
		--			--
		--			,@p_mod_date		= @p_mod_date
		--			,@p_mod_by			= @p_mod_by
		--			,@p_mod_ip_address	= @p_mod_ip_address
		--	where	code = @p_code ;
		--end
		--else
		--begin
		--	update	dbo.et_main
		--	set		et_amount			= @total_amount
		--			--
		--			,@p_mod_date		= @p_mod_date
		--			,@p_mod_by			= @p_mod_by
		--			,@p_mod_ip_address	= @p_mod_ip_address
		--	where	code = @p_code ;
		--end
        
		--update	dbo.et_main
		--set		et_amount			= @total_amount
		--		,credit_note_amount = @sum_credit_amount
		--		,refund_amount		= @sum_refund_amount
		--		--
		--		,@p_mod_date		= @p_mod_date
		--		,@p_mod_by			= @p_mod_by
		--		,@p_mod_ip_address	= @p_mod_ip_address
		--where	code = @code ;
		
		
		-- update opl status
		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @p_agreement_no
													  ,@p_status = N'ET' ;

		set @p_code = @code ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
