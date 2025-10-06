-- Louis Selasa, 07 Mei 2024 14.16.51 --
CREATE PROCEDURE dbo.xsp_mtn_invoice_wapu_non_wapu
   @p_invoice_no				 nvarchar(50) --= replace('00560/INV/2015/11/2023', '/', '.') -- NO INVOICE
   ,@p_billing_faktur_type		 nvarchar(50)  --= wapu/non wapu (01, 02/03)
   --
   ,@p_mtn_remark				 nvarchar(4000)
   ,@p_mtn_cre_by				 nvarchar(250)
AS
BEGIN 
begin try
begin transaction ;

	declare @invoice_no				 nvarchar(50) = replace(@p_invoice_no, '/', '.')
			,@invoice_detail_id		 bigint
			,@is_invoice_deduct_pph nvarchar(50) 
			,@msg				     nvarchar(max)
			,@allocation_no			 nvarchar(50)
			,@mod_date			datetime = dbo.xfn_get_system_date()
			,@is_journal	nvarchar(1) 

	if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
	begin
		set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
		raiserror(@msg, 16, 1) ;
		return
	end ;

	if exists
	(
		select	1
		from	dbo.INVOICE
		where	INVOICE_NO		   = @invoice_no
				and INVOICE_STATUS = 'NEW'
	)
	begin
		set @msg = 'Status Invoice masi NEW lakukan Cancel dari IFIN saja';
		raiserror(@msg, 16, 1) ;
		return
	end ;

	if exists
	(
		select	1
		from	dbo.INVOICE
		where	INVOICE_NO		   = @invoice_no
				and INVOICE_STATUS = 'PAID'
	)
	begin
		set @msg = 'Invoice already PAID';
		raiserror(@msg, 16, 1) ;
		return
	end ;

	if exists
	(
		select	1
		from	dbo.INVOICE
		where	INVOICE_NO		   = @invoice_no
				and INVOICE_STATUS = 'CANCEL'
	)
	begin
		set @msg = 'Invoice already CANCEL';
		raiserror(@msg, 16, 1) ;
		return
	end ;

	if exists
	(
		select	1
		from	ifinfin.dbo.cashier_received_request
		where	request_status not in
	(
		'HOLD', 'CANCEL'
	)
				and invoice_no = @invoice_no
	)
	begin
		set @msg = 'Cashier Already Process';
		raiserror(@msg, 16, 1) ;
		return
	end ;

	if exists
	(
		select	1
		from	dbo.invoice
		where	invoice_no				  = @invoice_no
				and billing_to_faktur_type = @p_billing_faktur_type
	)
	begin
		set @msg = 'Setting billing_to_faktur_type already Exists';
		raiserror(@msg, 16, 1) ;
		RETURN
	END ;
	

	-- (+) Ari 2024-02-27 ket : check jika sudah melakukan allocation
	if exists (
				select	1
				from	ifinfin.dbo.deposit_allocation_detail 
				where	received_request_code in (
													select	code 
													from 	ifinfin.dbo.cashier_received_request
													where	invoice_no = @invoice_no 
												)
			  )
	begin
		
			select	@allocation_no = deposit_allocation_code 
			from	ifinfin.dbo.deposit_allocation_detail 
			where	received_request_code in (
												select	code 
												from 	ifinfin.dbo.cashier_received_request
												where	invoice_no = @invoice_no 
											)

			if exists ( select	1
						from	ifinfin.dbo.deposit_allocation
						where	code = @allocation_no
						and		allocation_status <> 'REJECT'
					  )
			begin
				set @msg = 'Cashier already register in deposit allocation'
				raiserror (@msg, 16, -1)
			end
			else
			begin
				delete	ifinfin.dbo.deposit_allocation_detail
				where	deposit_allocation_code = @allocation_no
   
				delete	ifinfin.dbo.deposit_allocation
				where	code = @allocation_no
				and		allocation_status = 'REJECT'
			end
	end
	if exists (
				select	1
				from	ifinfin.dbo.suspend_allocation_detail
				where	received_request_code in (
													select	code 
													from 	ifinfin.dbo.cashier_received_request
													where	invoice_no = @invoice_no 
												)
			  )
	begin
		
			select	@allocation_no = suspend_allocation_code 
			from	ifinfin.dbo.suspend_allocation_detail 
			where	received_request_code in (
												select	code 
												from 	ifinfin.dbo.cashier_received_request
												where	invoice_no = @invoice_no 
											)

			if exists ( select	1
						from	ifinfin.dbo.suspend_allocation
						where	code = @allocation_no
						and		allocation_status <> 'REJECT'
					  )
			begin
				set @msg = 'Cashier already register in suspend allocation'
				raiserror (@msg, 16, -1)
			end
			else
			begin
				delete	ifinfin.dbo.suspend_allocation_detail
				where	suspend_allocation_code = @allocation_no
   
				delete	ifinfin.dbo.suspend_allocation
				where	code = @allocation_no
				and		allocation_status = 'REJECT'
			end
	end

	insert into dbo.agreement_invoice_history
	(
		code
		,invoice_no
		,agreement_no
		,asset_no
		,billing_no
		,due_date
		,invoice_date
		,ar_amount
		,description
		--
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select	code
			,invoice_no
			,agreement_no
			,asset_no
			,billing_no
			,due_date
			,invoice_date
			,ar_amount
			,description
			--
			,@mod_date
			,@p_mtn_cre_by
			,@p_mtn_cre_by
			,@mod_date
			,@p_mtn_cre_by
			,@p_mtn_cre_by
	from	dbo.agreement_invoice
	where	invoice_no = @invoice_no ;
			
	delete dbo.agreement_invoice
	where	invoice_no = @invoice_no ;

	delete dbo.agreement_invoice_pph
	where	invoice_no = @invoice_no ;

	delete dbo.invoice_pph
	where	invoice_no = @invoice_no ;
			
	exec dbo.xsp_invoice_cancel_journal @p_reff_name		= 'INVOICE CANCEL'
										,@p_reff_code		= @invoice_no
										,@p_value_date		= @mod_date
										,@p_trx_date		= @mod_date
										,@p_mod_date		= @mod_date
										,@p_mod_by			= @p_mtn_cre_by
										,@p_mod_ip_address	= @p_mtn_cre_by
	
	delete	OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	delete	IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	delete	IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	select	@is_invoice_deduct_pph = is_invoice_deduct_pph
			,@is_journal			= is_journal	 
	from	dbo.invoice
	where	invoice_no = @invoice_no ;

	update	dbo.invoice
	set		total_amount = (case
								when @p_billing_faktur_type = '01' then TOTAL_BILLING_AMOUNT + TOTAL_PPN_AMOUNT
								else totAL_BILLING_AMOUNT
							end
						   ) - (case
									when @is_invoice_deduct_pph = '1' then TOTAL_PPH_AMOUNT
									else 0
								end
							   )
			,billing_to_faktur_type = @p_billing_faktur_type
			,invoice_status				= 'NEW'
			,is_journal					= '0'
			,is_journal_date 			= null
			,is_journal_ppn_wapu		= '0'
			,is_journal_ppn_wapu_date	= null
			,mod_date		= @mod_date
			,mod_by			= @p_mtn_cre_by
			,mod_ip_address = @p_mtn_cre_by
	where	INVOICE_NO = @invoice_no ;

	declare curr_invoicedetail cursor fast_forward read_only for
	select	id
	from	dbo.invoice_detail
	where	invoice_no = @invoice_no ;

	open curr_invoiceDetail ;

	fetch next from curr_invoiceDetail
	into @invoice_detail_id ;

	while @@fetch_status = 0
	begin
		update	dbo.invoice_detail
		set		total_amount = (case
									when @p_billing_faktur_type = '01' then billing_amount + ppn_amount
									else billing_amount
								end
							   ) - (case
										when @is_invoice_deduct_pph = '1' then pph_amount
										else 0
									end
								   )
			,mod_date		= @mod_date
			,mod_by			= @p_mtn_cre_by
			,mod_ip_address = @p_mtn_cre_by
		where	id			   = @invoice_detail_id
				and invoice_no = @invoice_no ;

		fetch next from curr_invoiceDetail
		into @invoice_detail_id ;
	end ;

	close curr_invoiceDetail ;
	deallocate curr_invoiceDetail ;

	--invoice PPH
	if not exists
	(
		select	1
		from	dbo.INVOICE_PPH
		where	INVOICE_NO = @invoice_no
	)
	begin
		insert into dbo.INVOICE_PPH
		(
			INVOICE_NO
			,SETTLEMENT_TYPE
			,SETTLEMENT_STATUS
			,FILE_PATH
			,FILE_NAME
			,PAYMENT_REFF_NO
			,PAYMENT_REFF_DATE
			,TOTAL_PPH_AMOUNT
			,AUDIT_CODE
			,CRE_DATE
			,CRE_BY
			,CRE_IP_ADDRESS
			,MOD_DATE
			,MOD_BY
			,MOD_IP_ADDRESS
		)
		select	INVOICE_NO
				,case
					 when IS_INVOICE_DEDUCT_PPH = '1' then 'PKP'
					 else 'NON PKP'
				 end
				,'HOLD'
				,null
				,null
				,case is_invoice_deduct_pph
					 when '1' then null
					 else N'NOT DEDUCT PPH'
				 end
				,case is_invoice_deduct_pph
					 when '1' then null
					 else dbo.xfn_get_system_date()
				 end
				,TOTAL_PPH_AMOUNT
				,null
				,@mod_date
				,@p_mtn_cre_by
				,@p_mtn_cre_by
				,@mod_date
				,@p_mtn_cre_by
				,@p_mtn_cre_by
		from	dbo.INVOICE
		where	INVOICE_NO = replace(@invoice_no, '/', '.') ;
	end ;
	else
	begin
		update	dbo.INVOICE_PPH
		set		SETTLEMENT_TYPE = case
									  when @is_invoice_deduct_pph = '1' then 'PKP'
									  else 'NON PKP'
								  end
				,SETTLEMENT_STATUS = case
										 when @is_invoice_deduct_pph = '1' then 'HOLD'
										 else 'POST'
									 end
				,PAYMENT_REFF_NO = case @is_invoice_deduct_pph
									   when '1' then null
									   else N'NOT DEDUCT PPH'
								   end
				,PAYMENT_REFF_DATE = case @is_invoice_deduct_pph
										 when '1' then null
										 else dbo.xfn_get_system_date()
									 end
				,MOD_DATE		= @mod_date
				,MOD_BY			= @p_mtn_cre_by
				,MOD_IP_ADDRESS = @p_mtn_cre_by
		where	INVOICE_NO = @invoice_no ;
	end ;

	exec dbo.xsp_invoice_payment_for_send @p_invoice_no		 = @invoice_no
											,@p_mod_date		 = @mod_date
											,@p_mod_by		 = @p_mtn_cre_by
											,@p_mod_ip_address = @p_mtn_cre_by 
			 	 
	if (@is_journal = '1')
	begin 
		exec dbo.xsp_regenerate_invoice_journal_not_due_to_due @p_invoice_no		= @invoice_no
															   ,@p_mod_date			= @mod_date
															   ,@p_mod_by			= @p_mtn_cre_by
															   ,@p_mod_ip_address	= @p_mtn_cre_by 
	end


	if ((
					select	sum(orig_amount_db) - sum(orig_amount_cr)
					from	dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL a
							inner join dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION b on (b.CODE = a.GL_LINK_TRANSACTION_CODE)
					where	b.REFF_SOURCE_NO = @invoice_no
				) <> 0
				)
			begin 
				set @msg = 'Journal is not balance' ;

				raiserror(@msg, 16, -1) ;
				return
			end ;

	select	sum(a.ORIG_AMOUNT)
	from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL a
			inner join dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST b on (b.CODE = a.CASHIER_RECEIVED_REQUEST_CODE)
	where	b.INVOICE_NO = @invoice_no ; 

	--select	*
	--from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST b
	--where	b.INVOICE_NO = @invoice_no ;

	--select	a.*
	--from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL a
	--		inner join dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST b on (b.CODE = a.CASHIER_RECEIVED_REQUEST_CODE)
	--where	b.INVOICE_NO = @invoice_no ;

	select	*
	from	dbo.INVOICE
	where	invoice_no = @invoice_no ;

	select	*
	from	dbo.INVOICE_DETAIL
	where	invoice_no = @invoice_no ;

	select	*
	from	dbo.INVOICE_PPH
	where	invoice_no = @invoice_no ;

	select		INVOICE_NO
				,count(1)
	from		OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
	where DOC_REFF_NAME <> 'CREDIT NOTE'
	group by	INVOICE_NO
	having		count(1) > 1 ;

	select		INVOICE_NO
				,count(1)
	from		IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST
	where DOC_REF_NAME <> 'CREDIT NOTE'
	group by	INVOICE_NO
	having		count(1) > 1 ;

	select		INVOICE_NO
				,count(1)
	from		IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	where DOC_REF_NAME <> 'CREDIT NOTE'
	group by	INVOICE_NO
	having		count(1) > 1 ;

	select	a.*
					from	dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION_DETAIL a
							inner join dbo.OPL_INTERFACE_JOURNAL_GL_LINK_TRANSACTION b on (b.CODE = a.GL_LINK_TRANSACTION_CODE)
					--where	b.REFF_SOURCE_NO = @invoice_no
					where	b.CRE_BY = @p_mtn_cre_by
					 
	INSERT INTO dbo.MTN_DATA_DSF_LOG
	(
		MAINTENANCE_NAME
		,REMARK
		,TABEL_UTAMA
		,REFF_1
		,REFF_2
		,REFF_3
		,CRE_DATE
		,CRE_BY
	)
	values
	(
		'MTN INVOICE WAPU / NON WAPU'
		,@p_mtn_remark
		,'INVOICE'
		,@invoice_no
		,null -- REFF_2 - nvarchar(50)
		,null -- REFF_3 - nvarchar(50)
		,getdate()
		,@p_mtn_cre_by
	)
	
	if @@error = 0
	begin
		select 'SUCCESS'
		--commit transaction ;
		rollback transaction ;
	end ;
	else
	begin
		select 'GAGAL PROCESS : ' + @msg
		rollback transaction ;
	end

end try
begin catch
	select 'GAGAL PROCESS : ' + @msg
	rollback transaction ;
end catch ;

END
