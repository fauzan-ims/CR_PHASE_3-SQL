CREATE PROCEDURE dbo.xsp_mtn_invoice_change
(
   @p_invoice_no_old			 nvarchar(50)
   ,@p_invoice_no_new			 nvarchar(50)
   --
   ,@p_mtn_remark				 nvarchar(4000)
   ,@p_mtn_cre_by				 nvarchar(250)
 )
AS
BEGIN
 

begin try
begin transaction ;

	declare @invoice_no				 nvarchar(50) = replace(@p_invoice_no_old, '/', '.')
			,@invoice_detail_id		 bigint
			,@billing_to_faktur_type nvarchar(50) 
			,@msg				     nvarchar(max)
			,@mod_date				datetime = dbo.xfn_get_system_date()
			,@mod_by				nvarchar(15) = 'MAINTENANCE'
			,@mod_ip_address		nvarchar(15) = '127.0.0.1'
			,@invoice_no_new		nvarchar(50) = replace(@p_invoice_no_new,'/','.')
			,@is_invoice_deduct_pph	nvarchar(1)

	set @p_invoice_no_new = replace(@p_invoice_no_new,'.','/')


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


	delete	OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	delete	IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	delete	IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;


	
	insert into dbo.invoice
	(
		invoice_no
		,invoice_external_no
		,branch_code
		,branch_name
		,invoice_type
		,invoice_date
		,invoice_due_date
		,invoice_name
		,invoice_status
		,client_no
		,client_name
		,client_address
		,client_area_phone_no
		,client_phone_no
		,client_npwp
		,currency_code
		,total_billing_amount
		,credit_billing_amount
		,total_discount_amount
		,total_ppn_amount
		,credit_ppn_amount
		,total_pph_amount
		,credit_pph_amount
		,total_amount
		,stamp_duty_amount
		,faktur_no
		,generate_code
		,scheme_code
		,received_reff_no
		,received_reff_date
		,deliver_code
		,deliver_date
		,payment_ppn_code
		,payment_ppn_date
		,payment_pph_code
		,payment_pph_date
		,additional_invoice_code
		,is_journal
		,is_recognition_journal
		,kwitansi_no
		,new_invoice_date
		,billing_to_faktur_type
		,is_invoice_deduct_pph
		,is_receipt_deduct_pph
		,is_journal_ppn_wapu
		,is_journal_date
		,cre_date
		,cre_by
		,cre_ip_address
		,mod_date
		,mod_by
		,mod_ip_address
	)
	select	@invoice_no_new
		   ,@p_invoice_no_new
		   ,branch_code
		   ,branch_name
		   ,invoice_type
		   ,invoice_date
		   ,invoice_due_date
		   ,invoice_name
		   ,invoice_status
		   ,client_no
		   ,client_name
		   ,client_address
		   ,client_area_phone_no
		   ,client_phone_no
		   ,client_npwp
		   ,currency_code
		   ,total_billing_amount
		   ,credit_billing_amount
		   ,total_discount_amount
		   ,total_ppn_amount
		   ,credit_ppn_amount
		   ,total_pph_amount
		   ,credit_pph_amount
		   ,total_amount
		   ,stamp_duty_amount
		   ,faktur_no
		   ,generate_code
		   ,scheme_code
		   ,received_reff_no
		   ,received_reff_date
		   ,deliver_code
		   ,deliver_date
		   ,payment_ppn_code
		   ,payment_ppn_date
		   ,payment_pph_code
		   ,payment_pph_date
		   ,additional_invoice_code
		   ,is_journal
		   ,is_recognition_journal
		   ,kwitansi_no
		   ,new_invoice_date
		   ,billing_to_faktur_type
		   ,is_invoice_deduct_pph
		   ,is_receipt_deduct_pph
		   ,is_journal_ppn_wapu
		   ,is_journal_date
		   ,@mod_date
		   ,@mod_by
		   ,@mod_ip_address
		   ,@mod_date
		   ,@mod_by
		   ,@mod_ip_address
	from	dbo.invoice 
	where	invoice_no = @invoice_no

	select	@billing_to_faktur_type = billing_to_faktur_type
			,@is_invoice_deduct_pph = is_invoice_deduct_pph
	from	dbo.invoice
	where	invoice_no = @invoice_no ;


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
									when @billing_to_faktur_type = '01' then billing_amount + ppn_amount
									else billing_amount
								end
							   ) - (case
										when @is_invoice_deduct_pph = '1' then pph_amount
										else 0
									end
								   )
				,mod_date = getdate()
				,mod_by = N'MTN_PPH'
				,mod_ip_address = N'MTN_PPH'
		where	id			   = @invoice_detail_id
				and invoice_no = @invoice_no ;

		fetch next from curr_invoiceDetail
		into @invoice_detail_id ;
	end ;

	close curr_invoiceDetail ;
	deallocate curr_invoiceDetail ;

	update	dbo.invoice_detail
	set		invoice_no = @invoice_no_new
	where	invoice_no = @invoice_no

	--invoice PPH
	if not exists
	(
		select	1
		from	dbo.INVOICE_PPH
		where	INVOICE_NO = @invoice_no_new
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
				,getdate()
				,N'MTN_DATA'
				,N'MTN_DATA'
				,getdate()
				,N'MTN_DATA'
				,N'MTN_DATA'
		from	dbo.INVOICE
		where	INVOICE_NO = @invoice_no_new
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
				,MOD_DATE = getdate()
				,MOD_BY = N'MTN_DATA'
				,MOD_IP_ADDRESS = N'MTN_DATA'
		where	INVOICE_NO = @invoice_no_new;
	end ;

	declare @DATE				 datetime = getdate()
			,@CASHIER_INVOICE_NO nvarchar(50) ;
			 
	declare C_INVOICE cursor for
	select	INVOICE_NO
	from	IFINOPL.DBO.INVOICE
	where	INVOICE_NO = @invoice_no_new ;

	open C_INVOICE ;

	fetch C_INVOICE
	into @CASHIER_INVOICE_NO ;

	while @@fetch_status = 0
	begin
		exec IFINOPL.DBO.INVOICE_TO_INTERFACE_CASHIER_RECEIVE_INSERT @p_invoice_no = @CASHIER_INVOICE_NO -- NVARCHAR(50)
																	 ,@P_MOD_DATE = @DATE -- DATETIME
																	 ,@P_MOD_BY = N'MTN_DATA' -- NVARCHAR(15)
																	 ,@P_MOD_IP_ADDRESS = N'MTN_DATA' ; -- NVARCHAR(15)

		fetch C_INVOICE
		into @CASHIER_INVOICE_NO ;
	end ;

	close C_INVOICE ;
	deallocate C_INVOICE ;

	select	sum(a.ORIG_AMOUNT)
	from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL a
			inner join dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST b on (b.CODE = a.CASHIER_RECEIVED_REQUEST_CODE)
	where	b.INVOICE_NO = @invoice_no_new ;

	--select	*
	--from	dbo.INVOICE
	--where	invoice_no = @invoice_no ;

	--select	*
	--from	dbo.INVOICE_DETAIL
	--where	invoice_no = @invoice_no ;

	--select	*
	--from	dbo.INVOICE_PPH
	--where	invoice_no = @invoice_no ;

	select		INVOICE_NO
				,count(1)
	from		OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
	group by	INVOICE_NO
	having		count(1) > 1 ;

	select		INVOICE_NO
				,count(1)
	from		IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST
	group by	INVOICE_NO
	having		count(1) > 1 ;

	select		INVOICE_NO
				,count(1)
	from		IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	group by	INVOICE_NO
	having		count(1) > 1 ;

	update		dbo.invoice
	set			invoice_status = 'CANCEL'
	where		invoice_no = @invoice_no

	insert into dbo.MTN_DATA_DSF_LOG
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
		'MTN INVOICE CHANGE'
		,@p_mtn_remark
		,'INVOICE'
		,@invoice_no
		,@invoice_no_new -- REFF_2 - nvarchar(50)
		,null -- REFF_3 - nvarchar(50)
		,getdate()
		,@p_mtn_cre_by
	)
	
	if @@error = 0
	begin
		select 'SUCCESS'
		commit transaction ;
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
