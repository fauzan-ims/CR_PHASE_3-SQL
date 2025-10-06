CREATE PROCEDURE dbo.xsp_et_detail_update
(
	@p_id			   bigint
	,@p_et_code		   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@os_rental_amount_terminate decimal(18, 2)
			,@os_rental_amount_os		 decimal(18, 2)
			,@agreement_no				 nvarchar(50)
			,@asset_no					 nvarchar(50)
			,@is_terminate				 nvarchar(1)
			,@et_code					 nvarchar(50)
			,@et_date					 datetime
			,@total_amount				 decimal(18, 2) 
			,@invoice_status			 nvarchar(10) 
			,@invoice_no				 nvarchar(50) 
			,@invoice_date				datetime
            ,@bast_date					datetime
			,@credit_amount				decimal(18,2)
			,@refund_amount				decimal(18,2)
			,@billing_type				nvarchar(50)
			,@billing_amount			decimal(18,2)
			,@days_month				int
			,@days_et					int
			,@due_date					datetime
			,@pro_rate					decimal(18,2)
			,@sum_credit_amount			decimal(18,2)
			,@sum_refund_amount			decimal(18,2)
			,@penalty_charges			decimal(18,2)
			,@et_interim				decimal(18,2)

	begin try

		select	@is_terminate	= is_terminate
				, @agreement_no = em.agreement_no
				, @et_code		= em.code
				, @et_date		= em.et_date
				, @asset_no		= ad.asset_no
		from	dbo.et_detail	   ad
				inner join et_main em on em.code = ad.et_code
		where	id = @p_id ;

		if @is_terminate = '1'
			set @is_terminate = '0' ;
		else
			set @is_terminate = '1' ;

		if (@is_terminate = 1)
		begin 
				if exists
			(
				select	1
				from	dbo.invoice_detail invd
						inner join dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
				where	invd.agreement_no = @agreement_no
						and invd.asset_no = @asset_no
						and inv.invoice_status = 'NEW'
			)
			begin
				select	top 1
						@invoice_status = invoice_status
						,@invoice_no	= inv.invoice_external_no
				from	dbo.invoice_detail invd
						inner join dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
				where	invd.agreement_no = @agreement_no
						and invd.asset_no = @asset_no
						and inv.invoice_status = 'NEW'

				set @msg = N'Asset have a Pending Invoice, please complete Invoice transaction before ET : ' + @invoice_no + ' - ' + @invoice_status;

				raiserror(@msg, 16, -1) ;
			end ;

			begin
				-- (sepria 21/04/2025:2504000068 - validasi hanya per asset saja untuk cover juga case yg billing scheme)
				if exists (select 1 from dbo.agreement_asset_amortization where agreement_no = @agreement_no and asset_no = @asset_no and isnull(invoice_no,'') <> '')
				begin
					select	top 1
							@invoice_date = i.invoice_date
					from	dbo.agreement_asset_amortization	aaa
							inner join dbo.invoice_detail invd on invd.agreement_no = aaa.agreement_no and invd.asset_no = aaa.asset_no and aaa.invoice_no = invd.invoice_no
							inner join dbo.invoice	i on i.invoice_no = invd.invoice_no
					where	aaa.agreement_no = @agreement_no 
					and		aaa.asset_no  = @asset_no
					and		i.invoice_status in ('NEW')--, 'POST', 'PAID')
					order by i.invoice_date desc ;

					if cast(@et_date as date) < cast(@invoice_date as date)
					begin
						set @msg = 'Asset have last invoice with status NEW on the date ' + convert(nvarchar(50), @invoice_date, 103)
						raiserror(@msg, 16, 1) ;
					end
				end

				select	top 1 @bast_date = handover_bast_date 
				from	dbo.agreement_asset 
				where	agreement_no = @agreement_no
				and		asset_no = @asset_no

				if cast(@et_date as date) < cast(@bast_date as date)
				begin
					set @msg = 'ET Date must be greater than Bast Date Asset : ' + convert(nvarchar(50), @bast_date, 103)
					raiserror(@msg, 16, 1) ;
				end
			end --(sepria 21/04/2025:2504000068 - validasi hanya per asset saja untuk cover juga case yg billing scheme)

			if exists (select 1 from dbo.agreement_main where first_payment_type = 'ADV' and agreement_no = @agreement_no)
			begin
				select @billing_type = a.billing_type 
				from dbo.agreement_main a
				where a.agreement_no = @agreement_no

				if (@billing_type = 'MNT')
				begin
					select	@billing_amount = billing_amount
							,@days_month	= datediff(day, datefromparts(year(dateadd(month, -1, a.due_date)), month(dateadd(month, -1, a.due_date)), 6), a.due_date) + 1
							,@due_date		= a.due_date
							,@invoice_status = b.invoice_status
					from	dbo.agreement_asset_amortization a
							inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					where	@et_date
							between datefromparts(year(dateadd(month, -1, a.due_date)), month(dateadd(month, -1, a.due_date)), 6) and a.due_date
							and a.asset_no = @asset_no
							and b.invoice_status in
					(
						'POST', 'PAID'
					) ;
				end
				else if (@billing_type = 'QTY')
				begin
					select	@billing_amount	 = billing_amount
							,@days_month	 = datediff(day, datefromparts(year(dateadd(month, -3, a.due_date)), month(dateadd(month, -3, a.due_date)), 6), a.due_date) + 1
							,@due_date		 = a.due_date
							,@invoice_status = b.invoice_status
					from	dbo.agreement_asset_amortization a
							inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					where	@et_date
							between datefromparts(year(dateadd(month, -3, a.due_date)), month(dateadd(month, -3, a.due_date)), 6) and a.due_date
							and a.asset_no = @asset_no
							and b.invoice_status in
					(
						'POST', 'PAID'
					) ;
				end
				else if (@billing_type = 'ANN')
				begin
					select	@billing_amount	 = billing_amount
							,@days_month	 = datediff(day, datefromparts(year(dateadd(month, -12, a.due_date)), month(dateadd(month, -12, a.due_date)), 6), a.due_date) + 1
							,@due_date		 = a.due_date
							,@invoice_status = b.invoice_status
					from	dbo.agreement_asset_amortization a
							inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					where	@et_date
							between datefromparts(year(dateadd(month, -12, a.due_date)), month(dateadd(month, -12, a.due_date)), 6) and a.due_date
							and a.asset_no = @asset_no
							and b.invoice_status in
					(
						'POST', 'PAID'
					) ;
				end
				else if (@billing_type = 'SMA')
				begin
					select	@billing_amount	 = billing_amount
							,@days_month	 = datediff(day, datefromparts(year(dateadd(month, -6, a.due_date)), month(dateadd(month, -6, a.due_date)), 6), a.due_date) + 1
							,@due_date		 = a.due_date
							,@invoice_status = b.invoice_status
					from	dbo.agreement_asset_amortization a
							inner join dbo.invoice			 b on a.invoice_no = b.invoice_no
					where	@et_date
							between datefromparts(year(dateadd(month, -6, a.due_date)), month(dateadd(month, -6, a.due_date)), 6) and a.due_date
							and a.asset_no = @asset_no
							and b.invoice_status in
					(
						'POST', 'PAID'
					) ;
				end

				set @days_et = datediff(day, @due_date, @et_date) ;
				set @pro_rate = round(@billing_amount / (@days_month) * @days_et,0)

				if (@invoice_status = 'POST')
				begin
					update	dbo.et_detail
					set		credit_amount = @billing_amount - @pro_rate
							,refund_amount = 0
					where	asset_no = @asset_no ;
				end
				else if (@invoice_status = 'PAID')
				begin
					update	dbo.et_detail
					set		refund_amount = @billing_amount - @pro_rate
							,credit_amount = 0
					where	asset_no = @asset_no ;
				end
			end
			else
			begin
				set @credit_amount = 0
				set @refund_amount = 0
			end

		
			--select	@sum_credit_amount	= isnull(sum(credit_amount),0)
			--		,@sum_refund_amount = isnull(sum(refund_amount),0)
			--from	dbo.et_detail
			--where	et_code = @et_code ;

			--select	@penalty_charges = isnull(sum(total_amount), 0)
			--from	dbo.et_transaction
			--where	et_code				 = @et_code
			--		and transaction_code = 'CETP' ;

			--select	@et_interim = isnull(sum(total_amount), 0)
			--from	dbo.et_transaction
			--where	et_code				 = @et_code
			--		and transaction_code = 'ET_INTERIM' ;

			--if (@sum_credit_amount = 0 and @sum_refund_amount > 0)
			--begin
			--	update	dbo.et_main
			--	set		et_amount			= @total_amount
			--			,credit_note_amount = 0
			--			,refund_amount		= @sum_refund_amount - @penalty_charges - @et_interim
			--			--
			--			,@p_mod_date		= @p_mod_date
			--			,@p_mod_by			= @p_mod_by
			--			,@p_mod_ip_address	= @p_mod_ip_address
			--	where	code = @et_code ;
			--end
			--else
			--begin
			--	update	dbo.et_main
			--	set		et_amount			= @total_amount
			--			,credit_note_amount = @sum_credit_amount - @penalty_charges - @et_interim
			--			,refund_amount		= 0
			--			--
			--			,@p_mod_date		= @p_mod_date
			--			,@p_mod_by			= @p_mod_by
			--			,@p_mod_ip_address	= @p_mod_ip_address
			--	where	code = @et_code ;
			--end

		end

		update	et_detail
		set		is_terminate	= @is_terminate
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;

		if not exists
		(
			select	1
			from	et_detail
			where	et_code			 = @p_et_code
					and is_terminate = '1'
		)
		begin
			set @msg = 'Please select at least 1 Asset' ;

			raiserror(@msg, 16, 1) ;
		end ;

		select	@os_rental_amount_terminate = sum(os_rental_amount)
		from	dbo.et_detail
		where	et_code			 = @p_et_code
				and is_terminate = '1' ;

		select	@os_rental_amount_os = sum(os_rental_amount)
		from	dbo.et_detail
		where	et_code			 = @p_et_code
				and is_terminate = '0' ;

		
		--insert to et_transaction
		exec dbo.xsp_et_transaction_generate @p_et_code				= @et_code
											 , @p_agreement_no		= @agreement_no
											 , @p_et_date			= @et_date
											 , @p_cre_date			= @p_mod_date
											 , @p_cre_by			= @p_mod_by
											 , @p_cre_ip_address	= @p_mod_ip_address
											 , @p_mod_date			= @p_mod_date
											 , @p_mod_by			= @p_mod_by
											 , @p_mod_ip_address	= @p_mod_ip_address ;
											 
		--select	@total_amount = isnull(sum(total_amount), 0)
		--from	dbo.et_transaction
		--where	et_code			   = @et_code
		--		and is_transaction = '1' ;

		exec dbo.xsp_et_main_update_amount @p_code = @et_code,                       -- nvarchar(50)
											@p_mod_date = @p_mod_date, -- datetime
											@p_mod_by = @p_mod_by,                     -- nvarchar(15)
											@p_mod_ip_address = @p_mod_ip_address             -- nvarchar(15)


		--update dbo.et_transaction set transaction_amount = @os_rental_amount_terminate, total_amount = @os_rental_amount_terminate where et_code = @p_et_code and transaction_code = 'PRAJ_ET'
		--if exists
		--(
		--	select	1
		--	from	dbo.et_transaction
		--	where	et_code				 = @p_et_code
		--			and transaction_code = 'PRAJ_ET'
		--)
		--begin
		--	update	dbo.et_transaction
		--	set		transaction_amount = isnull(@os_rental_amount_os, 0)
		--			,total_amount = isnull(@os_rental_amount_os, 0)
		--	where	et_code				 = @p_et_code
		--			and transaction_code = 'PRAJ_ET' ;
		--end ;
		--else
		--begin
			--insert into dbo.et_transaction
			--(
			--	et_code
			--	,transaction_code
			--	,transaction_amount
			--	,disc_pct
			--	,disc_amount
			--	,total_amount
			--	,order_key
			--	,is_amount_editable
			--	,is_discount_editable
			--	,is_transaction
			--	,cre_date
			--	,cre_by
			--	,cre_ip_address
			--	,mod_date
			--	,mod_by
			--	,mod_ip_address
			--)
			--values
			--(	@p_et_code
			--	,'PRAJ_ET'
			--	,isnull(@os_rental_amount_os, 0)
			--	,0
			--	,0
			--	,isnull(@os_rental_amount_os, 0)
			--	,99
			--	,'1'
			--	,'0'
			--	,'1'
			--	--
			--	,@p_mod_date
			--	,@p_mod_by
			--	,@p_mod_ip_address
			--	,@p_mod_date
			--	,@p_mod_by
			--	,@p_mod_ip_address
			--) ;

			--if (isnull(@os_rental_amount_os, 0) = 0)
			--begin
			--	delete dbo.et_transaction
			--	where	et_code				 = @p_et_code
			--			and transaction_code = 'PRAJ_ET' ;
			--end ;
		--end ;
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
