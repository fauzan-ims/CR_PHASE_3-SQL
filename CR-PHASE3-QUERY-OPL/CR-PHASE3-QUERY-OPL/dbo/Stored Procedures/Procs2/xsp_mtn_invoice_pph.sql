-- Louis Selasa, 12 Desember 2023 10.06.23 --
CREATE PROCEDURE dbo.xsp_mtn_invoice_pph
   @p_invoice_no				 nvarchar(50) --= replace('00560/INV/2015/11/2023', '/', '.') -- NO INVOICE
   ,@p_is_invoice_deduct_pph	 nvarchar(1)  --= N'0' --potong pph isi '1', tidak potong pph isi '0'
   --
   ,@p_mtn_remark				 nvarchar(4000)
   ,@p_mtn_cre_by				 nvarchar(250)
AS
BEGIN
    --1. sebelum menjalankan SCRIPT check Invoice terlebih dahulu
--SELECT IS_INVOICE_DEDUCT_PPH, * FROM dbo.INVOICE where INVOICE_NO = replace('59156/INV/SBY/10/2023', '/', '.')

--2. check invoice PPH 
--SELECT * FROM dbo.INVOICE_PPH where INVOICE_NO = replace('00388/INV/2008/11/2023', '/', '.')


begin try
begin transaction ;

	declare @invoice_no				 nvarchar(50) = replace(@p_invoice_no, '/', '.')
			,@invoice_detail_id		 bigint
			,@billing_to_faktur_type nvarchar(50) 
			,@msg				     nvarchar(max)
			,@allocation_no			 nvarchar(50)
			,@mod_date				 DATETIME =  GETDATE()

	--select	*
	--from	dbo.INVOICE
	--where	invoice_no = @invoice_no ;

	--select	*
	--from	dbo.INVOICE_DETAIL
	--where	invoice_no = @invoice_no ;

	--select	*
	--from	dbo.INVOICE_PPH
	--where	invoice_no = @invoice_no ;
	

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

	if exists
	(
		select	1
		from	dbo.invoice
		where	invoice_no				  = @invoice_no
				and is_invoice_deduct_pph = @p_is_invoice_deduct_pph
	)
	begin
		set @msg = 'Setting is_invoice_deduct_pph already Exists';
		raiserror(@msg, 16, 1) ;
		RETURN
	END ;
	
	delete	OPL_INTERFACE_CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	delete	IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;


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
				set @msg = 'Cashier already register in deposit allocatiom'
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


	delete	IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	where	INVOICE_NO = @invoice_no ;

	select	@billing_to_faktur_type = billing_to_faktur_type
	from	dbo.invoice
	where	invoice_no = @invoice_no ;

	update	dbo.INVOICE
	set		TOTAL_AMOUNT = (case
								when BILLING_TO_FAKTUR_TYPE = '01' then TOTAL_BILLING_AMOUNT + TOTAL_PPN_AMOUNT
								else TOTAL_BILLING_AMOUNT
							end
						   ) - (case
									when @p_is_invoice_deduct_pph = '1' then TOTAL_PPH_AMOUNT
									else 0
								end
							   )
			,is_invoice_deduct_pph = @p_is_invoice_deduct_pph
			,mod_date = getdate()
			,mod_by = N'MTN_PPH'
			,mod_ip_address = N'MTN_PPH'
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
									when @billing_to_faktur_type = '01' then billing_amount + ppn_amount
									else billing_amount
								end
							   ) - (case
										when @p_is_invoice_deduct_pph = '1' then pph_amount
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
				,getdate()
				,N'MTN_DATA'
				,N'MTN_DATA'
				,getdate()
				,N'MTN_DATA'
				,N'MTN_DATA'
		from	dbo.INVOICE
		where	INVOICE_NO = replace(@invoice_no, '/', '.') ;
	end ;
	else
	begin
		update	dbo.INVOICE_PPH
		set		SETTLEMENT_TYPE = case
									  when @p_is_invoice_deduct_pph = '1' then 'PKP'
									  else 'NON PKP'
								  end
				,SETTLEMENT_STATUS = case
										 when @p_is_invoice_deduct_pph = '1' then 'HOLD'
										 else 'POST'
									 end
				,PAYMENT_REFF_NO = case @p_is_invoice_deduct_pph
									   when '1' then null
									   else N'NOT DEDUCT PPH'
								   end
				,PAYMENT_REFF_DATE = case @p_is_invoice_deduct_pph
										 when '1' then null
										 else dbo.xfn_get_system_date()
									 end
				,MOD_DATE = getdate()
				,MOD_BY = N'MTN_DATA'
				,MOD_IP_ADDRESS = N'MTN_DATA'
		where	INVOICE_NO = @invoice_no ;
	end ;

	IF @invoice_no IN ('01624.INV.1000.11.2023','01623.INV.1000.11.2023') --02FEB2024: SEPRIA - SEMENTARA UNTUK CASE ADDITIONAL INVOICE
	BEGIN
	
	exec IFINOPL.DBO.INVOICE_TO_INTERFACE_CASHIER_RECEIVE_INSERT @p_invoice_no = @invoice_no -- NVARCHAR(50)
																	 ,@P_MOD_DATE = @mod_date -- DATETIME
																	 ,@P_MOD_BY = N'MTN_DATA' -- NVARCHAR(15)
																	 ,@P_MOD_IP_ADDRESS = N'MTN_DATA' ; -- NVARCHAR(15)

	END
	ELSE
	BEGIN

	declare @DATE				 datetime = getdate()
			,@CASHIER_INVOICE_NO nvarchar(50) ;

	declare C_INVOICE cursor for
	select	INVOICE_NO
	from	IFINOPL.DBO.INVOICE
	where	INVOICE_NO = @invoice_no ;

	open C_INVOICE ;

	fetch C_INVOICE
	into @CASHIER_INVOICE_NO ;

	while @@fetch_status = 0
	BEGIN
		PRINT @CASHIER_INVOICE_NO
   
		exec IFINOPL.DBO.INVOICE_TO_INTERFACE_CASHIER_RECEIVE_INSERT @p_invoice_no = @CASHIER_INVOICE_NO -- NVARCHAR(50)
																	 ,@P_MOD_DATE = @DATE -- DATETIME
																	 ,@P_MOD_BY = N'MTN_DATA' -- NVARCHAR(15)
																	 ,@P_MOD_IP_ADDRESS = N'MTN_DATA' ; -- NVARCHAR(15)

		fetch C_INVOICE
		into @CASHIER_INVOICE_NO ;
	end ;

	close C_INVOICE ;
	deallocate C_INVOICE ;
	END

	select	sum(a.ORIG_AMOUNT)
	from	dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST_DETAIL a
			inner join dbo.OPL_INTERFACE_CASHIER_RECEIVED_REQUEST b on (b.CODE = a.CASHIER_RECEIVED_REQUEST_CODE)
	where	b.INVOICE_NO = @invoice_no ;

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
	group by	INVOICE_NO, BRANCH_CODE
	having		count(1) > 1 ;

	select		INVOICE_NO
				,count(1)
	from		IFINFIN.dbo.FIN_INTERFACE_CASHIER_RECEIVED_REQUEST
	group by	INVOICE_NO, BRANCH_CODE
	having		count(1) > 1 ;

	select		INVOICE_NO
				,count(1)
	from		IFINFIN.dbo.CASHIER_RECEIVED_REQUEST
	group by	INVOICE_NO, BRANCH_CODE
	having		count(1) > 1 ;

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
		'MTN INVOICE PPH'
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_invoice_pph] TO [wawa.hermawan]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_invoice_pph] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_invoice_pph] TO [ims-raffyanda]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_mtn_invoice_pph] TO [eddy.rakhman]
    AS [dbo];

