CREATE PROCEDURE dbo.xsp_rpt_bank_book
(
	@p_user_id		   NVARCHAR(50)
	,@p_data_type	   NVARCHAR(50)
	,@p_from_date	   DATETIME
	,@p_to_date		   DATETIME
	,@p_branch_code	   NVARCHAR(50)
	,@p_branch_name	   NVARCHAR(250)
	,@p_bank_code	   NVARCHAR(50)
	,@p_bank_name	   NVARCHAR(50)
	,@p_saldo_awal	   DECIMAL(18, 2)
	,@p_is_condition   NVARCHAR(1)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_by		   NVARCHAR(15)
	,@p_mod_date	   DATETIME
	,@p_mod_ip_address NVARCHAR(15)
)
as
begin
	delete	dbo.rpt_bank_book
	where	user_id = @p_user_id ;

	declare @report_company	   nvarchar(250)
			,@report_title	   nvarchar(250)
			,@report_image	   nvarchar(250)
			,@bank_name		   nvarchar(50)
			,@bank_account_no  nvarchar(50)
			,@date			   datetime
			,@value_date	   datetime
			,@transaction_no   nvarchar(50)
			,@description	   nvarchar(250)
			,@agreement_no	   nvarchar(50)
			,@currency		   nvarchar(3)
			,@rate			   decimal(18, 6)
			,@debet			   decimal(18, 2) = 0
			,@credit		   decimal(18, 2) = 0
			,@balance		   decimal(18, 2)
			,@saldo_awal	   decimal(18, 2) = 0
			,@saldo_akhir	   decimal(18, 2) = 0
			,@orig_amount	   decimal(18, 2)
			,@branch_name	   nvarchar(50)
			,@client_name	   nvarchar(250)
			,@no_urut		   int			  = 1
			--
			,@datetimeNow	   datetime
			,@source_reff_code nvarchar(50)
			,@source_reff_name nvarchar(50)
			,@gl_link_code	   nvarchar(50)
			,@msg			   nvarchar(max)
			,@balance_tampung  decimal(18, 2) ;

	begin try
		if (@p_from_date > @p_to_date)
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('From Date', 'To Date') ;

			raiserror(@msg, 16, -1) ;
		end ;

		set @report_title = N'Report Bank Book' ;
		set @datetimeNow = getdate() ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		set @saldo_awal = @p_saldo_awal ;

		/* declare main cursor */
		if (@p_data_type = 'TRANSACTION')
		begin
			declare c_bank_book cursor local fast_forward read_only for
			select		bmh.transaction_date
						,bmh.value_date
						,isnull(bmh.source_reff_code, '-')
						,isnull(bmh.orig_currency_code, '-')
						,isnull(bmh.exch_rate, 0)
						--,isnull(bm.balance_amount,0)
						,isnull(bmh.source_reff_code, '-')
						,isnull(bmh.source_reff_name, '-')
						,isnull(bm.gl_link_code, '-')
						,isnull(bm.branch_bank_name, '-')
						,isnull(bm.branch_bank_code, '-')
						--,isnull(bm.balance_amount,0)
						,bm.branch_name
						,bmh.orig_amount
						,bmh.remarks
			from		dbo.bank_mutation bm with (nolock)
						inner join dbo.bank_mutation_history bmh with (nolock) on (bmh.bank_mutation_code = bm.code)
			where		cast(bmh.transaction_date as date)
						between cast(@p_from_date as date) and cast(@p_to_date as date)
						and
						(
							bm.branch_code		= @p_branch_code
							or	@p_branch_code	= 'ALL'
						)
						and
						(
							bm.branch_bank_code = @p_bank_code
							or	@p_bank_code	= 'ALL'
						)
			order by	bmh.transaction_date, bmh.source_reff_code; ; --, bmh.orig_amount asc
		end ;
		else
		begin
			declare c_bank_book cursor local fast_forward read_only for
			select		bmh.transaction_date
						,bmh.value_date
						,isnull(bmh.source_reff_code, '-')
						,isnull(bmh.orig_currency_code, '-')
						,isnull(bmh.exch_rate, 0)
						--,isnull(bm.balance_amount,0)
						,isnull(bmh.source_reff_code, '-')
						,isnull(bmh.source_reff_name, '-')
						,ISNULL(bm.gl_link_code, '-')
						,ISNULL(bm.branch_bank_name, '-')
						,ISNULL(bm.branch_bank_code, '-')
						--,isnull(bm.balance_amount,0)
						,bm.branch_name
						,bmh.orig_amount
						,bmh.remarks
			FROM		dbo.bank_mutation bm WITH (NOLOCK)
						INNER JOIN dbo.bank_mutation_history bmh WITH (NOLOCK) ON (bmh.bank_mutation_code = bm.code)
			WHERE		CAST(bmh.VALUE_DATE AS DATE)
						BETWEEN CAST(@p_from_date AS DATE) AND CAST(@p_to_date AS DATE)
						AND
						(
							bm.branch_code		= @p_branch_code
							OR	@p_branch_code	= 'ALL'
						)
						AND
						(
							bm.branch_bank_code = @p_bank_code
							OR	@p_bank_code	= 'ALL'
						)
			ORDER BY	bmh.value_date, bmh.source_reff_code; --, bmh.orig_amount asc
		END ;

		/* fetch record */
		open c_bank_book ;

		fetch c_bank_book
		into @date
			 ,@value_date
			 ,@transaction_no
			 ,@currency
			 ,@rate
			 --,@balance	
			 ,@source_reff_code
			 ,@source_reff_name
			 ,@gl_link_code
			 ,@bank_name
			 ,@bank_account_no
			 --,@saldo_awal
			 ,@branch_name
			 ,@orig_amount
			 ,@description ;

		WHILE @@fetch_status = 0
		BEGIN
			set @debet = 0 ;
			set @credit = 0 ;
			set @description = null ;
			set @agreement_no = null ;
			set @client_name = null ;

			if (@orig_amount > 0)
			begin
				set @debet = isnull(@orig_amount, 0) ;
			end ;
			else
			BEGIN
				SET @credit = isnull(@orig_amount, 0) * -1 ;
			end ;

			--if (@source_reff_name = 'Received Voucher')
			--begin

			--		select @description   = isnull(received_remarks,'-')
			--			   ,@agreement_no = '-'
			--			   ,@debet		  = isnull(received_orig_amount,0)
			--			   ,@credit		  = 0
			--		from dbo.received_voucher with(nolock)
			--		where code = @source_reff_code

			--end
			
			--else if (@source_reff_name = 'Account Transfer')
			--begin

			--		select @description   = isnull(transfer_remarks,'-')
			--			   ,@agreement_no = '-'
			--			   ,@debet		  = isnull(from_orig_amount,0)
			--			   ,@credit		  = 0
			--		from dbo.account_transfer with(nolock)
			--		where code = @source_reff_code

			--end
			--else 
			if (@source_reff_name in
			(
				'Cashier Transaction', 'Reversal Cashier Transaction'
			)
			   )
			begin
				select	@description = case when  @source_reff_name = 'Reversal Cashier Transaction' then 'Reversal Cashier Transaction' + isnull(cashier_remarks, '-') else isnull(cashier_remarks, '-') end
						,@agreement_no = isnull(am.agreement_external_no, '-')
						--,@debet		  = isnull(cashier_orig_amount,0)
						--,@credit		  = 0
						,@client_name = isnull(am.client_name,'-')
				from	dbo.cashier_transaction ct
						left join dbo.agreement_main am on (am.agreement_no = ct.agreement_no)
				where	code = @source_reff_code ;
			end ;
			else if (@source_reff_name = 'payment confirm')
			begin

					select @description   = isnull(payment_remarks,'-')
						   ,@agreement_no = '-'
						   ,@credit		  = isnull(payment_orig_amount,0)
						   ,@debet		  = 0
					from dbo.payment_transaction with(nolock)
					where code = @source_reff_code

			end
			else if (@source_reff_name in
				 (
					 'Payment Voucher'
				 )
					)
			begin
				select	@description = isnull(payment_remarks, '-')
						,@agreement_no = N'-'
						--,@debet = isnull(payment_orig_amount, 0)
						--,@credit = 0
				from	dbo.payment_voucher with (nolock)
				where	code = @source_reff_code ;
			end ;
			else if (@source_reff_name in
				 (
					 'Received Voucher'
				 )
					)
			BEGIN
				SELECT	@description = isnull(received_remarks, '-')
						,@agreement_no = N'-'
						--,@debet = 0
						--,@credit = isnull(received_orig_amount, 0)
				from	dbo.received_voucher with (nolock)
				where	code = @source_reff_code ;
			end ;
			else if (@source_reff_name in
				 (
					 'Payment Trasaction'
				 )
					)
			begin
				select	@description = isnull(payment_remarks, '-')
						,@agreement_no = N'-'
				--,@debet = isnull(payment_orig_amount, 0)
				--,@credit = 0
				from	dbo.PAYMENT_TRANSACTION with (nolock)
				where	code = @source_reff_code ;
			end ;
			else if (@source_reff_name in
				 (
					 'Received Confirm'
				 )
					)
			begin
				select	@description = isnull(received_remarks, '-')
						,@agreement_no = N'-'
				--,@debet = isnull(payment_orig_amount, 0)
				--,@credit = 0
				from	dbo.received_transaction with (nolock)
				where	code = @source_reff_code ;
			end ;
			else if (@source_reff_name in
				 (
					 'Account Transfer'
				 )
					)
			begin
				select	@description = isnull(transfer_remarks, '-')
						,@agreement_no = N'-'
				from	dbo.account_transfer with (nolock)
				where	code = @source_reff_code ;
			end ;
			--else
			--begin
			--	select	@description = isnull(payment_remarks, '-')
			--			,@agreement_no = N'-'
			--			,@debet = isnull(amount, 0)
			--			,@credit = 0
			--	from	dbo.ACCOUNT_TRANSFER with (nolock)
			--	where	code = @source_reff_code ;
			--end ;

			--Payment Trasaction
			--Received Voucher
			--Reversal Cashier Transaction
			--Account Transfer
			--Payment Voucher
			--Cashier Transaction 
			set @balance = isnull(isnull(@saldo_awal, 0) + isnull(@debet, 0) - isnull(@credit, 0), 0) ;

			declare @tempTable table
			(
				user_id				nvarchar(max)
				,report_company		nvarchar(250)
				,report_title		nvarchar(250)
				,report_image		nvarchar(250)
				,filter_data_type	nvarchar(50)
				,filter_from_date	datetime
				,filter_to_date		datetime
				,filter_branch_code nvarchar(50)
				,filter_bank_code	nvarchar(50)
				,filter_bank_name	nvarchar(250)
				,filter_saldo_awal	decimal(18, 2)
				,bank_name			nvarchar(50)
				,bank_account_no	nvarchar(50)
				,date				datetime
				,value_date			datetime
				,client_name		nvarchar(250)
				,transaction_no		nvarchar(50)
				,description		nvarchar(250)
				,agreement_no		nvarchar(50)
				,currency			nvarchar(3)
				,rate				decimal(18, 6)
				,debet				decimal(18, 2)
				,credit				decimal(18, 2)
				,balance			decimal(18, 2)
				,saldo_akhir		decimal(18, 2)
				,branch_name		nvarchar(50)
				,is_condition		nvarchar(1)
				,data_type			nvarchar(50)
				,cre_by				nvarchar(15)
				,cre_date			datetime
				,cre_ip_address		nvarchar(15)
				,mod_by				nvarchar(15)
				,mod_date			datetime
				,mod_ip_address		nvarchar(15)
			) ;

			/* insert into table report */
			insert into @tempTable
			(
				user_id
				,report_company
				,report_title
				,report_image
				,filter_data_type
				,filter_from_date
				,filter_to_date
				,filter_branch_code
				,filter_bank_code
				,filter_bank_name
				,filter_saldo_awal
				,bank_name
				,bank_account_no
				,date
				,value_date
				,client_name
				,transaction_no
				,description
				,agreement_no
				,currency
				,rate
				,debet
				,credit
				,balance
				,saldo_akhir
				,branch_name
				,is_condition
				,data_type
				,cre_by
				,cre_date
				,cre_ip_address
				,mod_by
				,mod_date
				,mod_ip_address
			)
			values
			(
				@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_data_type
				,@p_from_date
				,@p_to_date
				,@p_branch_code
				,@p_bank_code
				,@p_bank_name
				,@p_saldo_awal
				,@bank_name
				,@bank_account_no
				,@date
				,@value_date
				,@client_name
				,@transaction_no
				,@description
				,@agreement_no
				,@currency
				,@rate
				,@debet
				,@credit
				,@balance
				,@saldo_akhir
				,@p_branch_name
				,@p_is_condition
				,case
					 when @p_data_type = 'TRANSACTION' then 'Transaction Date'
					 when @p_data_type = 'VALUE' then 'Value Date'
				 end
				,@no_urut
				,@p_cre_date
				,@p_cre_ip_address
				,@p_mod_by
				,@p_mod_date
				,@p_mod_ip_address
			) ;

			set @saldo_awal = @balance ;
			set @no_urut += 1 ;

			/* fetch record berikutnya */
			fetch c_bank_book
			into @date
				 ,@value_date
				 ,@transaction_no
				 ,@currency
				 ,@rate
				 --,@balance
				 ,@source_reff_code
				 ,@source_reff_name
				 ,@gl_link_code
				 ,@bank_name
				 ,@bank_account_no
				 --,@saldo_awal
				 ,@branch_name
				 ,@orig_amount
				 ,@description ;
		end ;

		/* tutup cursor */
		close c_bank_book ;
		deallocate c_bank_book ;

		insert into dbo.rpt_bank_book
		(
			user_id
			,report_company
			,report_title
			,report_image
			,filter_data_type
			,filter_from_date
			,filter_to_date
			,filter_branch_code
			,filter_bank_code
			,filter_bank_name
			,filter_saldo_awal
			,bank_name
			,bank_account_no
			,date
			,value_date
			,client_name
			,transaction_no
			,description
			,agreement_no
			,currency
			,rate
			,debet
			,credit
			,balance
			,saldo_akhir
			,branch_name
			,is_condition
			,data_type
			,cre_by
			,cre_date
			,cre_ip_address
			,mod_by
			,mod_date
			,mod_ip_address
		)
		select	user_id
				,report_company
				,report_title
				,report_image
				,filter_data_type
				,filter_from_date
				,filter_to_date
				,filter_branch_code
				,filter_bank_code
				,filter_bank_name
				,filter_saldo_awal
				,bank_name
				,bank_account_no
				,date
				,value_date
				,client_name
				,transaction_no
				,description
				,agreement_no
				,currency
				,rate
				,debet
				,credit
				,balance
				,saldo_akhir
				,branch_name
				,is_condition
				,data_type
				,cre_by
				,cre_date
				,cre_ip_address
				,mod_by
				,mod_date
				,mod_ip_address
		from	@temptable ;

		--order BY date desc
		declare @mutasi decimal(18, 2) ;

		select	@mutasi = sum(debet) - sum(credit)
		from	dbo.rpt_bank_book
		where	user_id				 = @p_user_id
				and filter_bank_code = @p_bank_code ;

		update	dbo.rpt_bank_book
		set		saldo_akhir = @p_saldo_awal - @mutasi
		where	user_id				 = @p_user_id
				and filter_bank_code = @p_bank_code ;
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
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;

	if not exists
	(
		select	*
		from	dbo.rpt_bank_book
		where	user_id = @p_user_id
	)
	begin
		insert into dbo.rpt_bank_book
		(
			user_id
			,report_company
			,report_title
			,report_image
			,filter_data_type
			,filter_from_date
			,filter_to_date
			,filter_branch_code
			,filter_bank_code
			,filter_bank_name
			,filter_saldo_awal
			,bank_name
			,bank_account_no
			,date
			,value_date
			,transaction_no
			,description
			,agreement_no
			,currency
			,rate
			,debet
			,credit
			,balance
			,saldo_akhir
			,branch_name
			,is_condition
			,data_type
			,cre_by
			,cre_date
			,cre_ip_address
			,mod_by
			,mod_date
			,mod_ip_address
		)
		values
		(
			@p_user_id
			,@report_company
			,@report_title
			,@report_image
			,@p_data_type
			,@p_from_date
			,@p_to_date
			,@p_branch_code
			,@p_bank_code
			,@p_bank_name
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,null
			,@p_branch_name
			,@p_is_condition
			,@p_data_type
			,0
			,@p_cre_date
			,@p_cre_ip_address
			,@p_mod_by
			,@p_mod_date
			,@p_mod_ip_address
		) ;
	end ;
end ;
