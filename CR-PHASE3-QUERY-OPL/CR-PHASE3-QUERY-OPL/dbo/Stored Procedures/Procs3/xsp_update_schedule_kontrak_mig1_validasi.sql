CREATE PROCEDURE dbo.xsp_update_schedule_kontrak_mig1_validasi
(
	@p_agreement_no	nvarchar(50) 
)
as    
begin
    
	SET @p_agreement_no = REPLACE(@p_agreement_no,'/','.')

	DECLARE @invoice_no NVARCHAR(50)

	/*  cre_by : Sepria
		cre_date : 12 Des 2023
		Tujuan: ini di bikin karena ada ratusan kontrak yang akan dilakukan update data schedule amortizationnya. 
		step:	1. xsp_update_schedule_kontrak_mig1_validasi
					=> validasi jika ada transaksi invoice dari sistem, maka stop semua script. jalankan update schedule manual
				2. xsp_update_schedule_kontrak_mig1_update

	*/
	if exists (select 1 from dbo.agreement_asset_amortization where agreement_no = @p_agreement_no and mod_by not in ( 'migrasi','paid_recon','mig1_migrasi') AND INVOICE_NO IS NOT NULL)
	begin
		select * from dbo.agreement_asset_amortization where agreement_no = @p_agreement_no and mod_by not in  ( 'migrasi','paid_recon','mig1_migrasi') AND INVOICE_NO IS NOT NULL

		raiserror ('amortization telah dilakukan update oleh system',16,1)
		return;
	end
	else
	if exists (	select	1 
				from	dbo.invoice a
						inner join dbo.invoice_detail inv on inv.invoice_no = a.invoice_no
				where	inv.agreement_no = @p_agreement_no
				and		inv.mod_by not in  ( 'migrasi','paid_recon','mig1_migrasi')
				and		a.invoice_status <> 'cancel'
			)
	begin
			select	TOP 1 @invoice_no = a.INVOICE_NO
			from	dbo.invoice a
					inner join dbo.invoice_detail inv on inv.invoice_no = a.invoice_no
			where	inv.agreement_no = @p_agreement_no
			and		inv.mod_by not in  ( 'migrasi','paid_recon','mig1_migrasi')
			and		a.invoice_status <> 'cancel'

			PRINT @invoice_no PRINT '@invoice_no'
	
			raiserror ('invoice telah dilakukan update oleh system',16,1)
			return;
	end
	else
	if exists (	select	1 
				from	dbo.agreement_invoice a
				where	a.agreement_no = @p_agreement_no
				and		a.mod_by not in ( 'migrasi','paid_recon','mig1_migrasi')
			)
	begin
	
		select	a.*
		from	dbo.agreement_invoice a
		where	a.agreement_no = @p_agreement_no
		and		a.mod_by not in ( 'migrasi','paid_recon','mig1_migrasi')

		raiserror ('agreement_invoice telah dilakukan update oleh system',16,1)
		return;
	end
	else
	if exists (	select	1 
				from	dbo.agreement_invoice_payment a
				where	a.agreement_no = @p_agreement_no
				and		a.mod_by not in ( 'migrasi','paid_recon','mig1_migrasi')
			)
	begin
	
		select	a.* 
		from	dbo.agreement_invoice_payment a
		where	a.agreement_no = @p_agreement_no
		and		a.mod_by not in ( 'migrasi','paid_recon','mig1_migrasi')
	
		raiserror ('agreement_invoice_payment telah dilakukan update oleh system',16,1)
		return;
	end
    else
	if exists (	select	1 
				from	ifinfin.dbo.cashier_received_request a
						inner join ifinfin.dbo.cashier_received_request_detail b on b.cashier_received_request_code = a.code
				where	a.agreement_no = @p_agreement_no
				and		a.request_status not in ('HOLD','PAID_RECON','CANCEL')
				)
	begin
		
		select	a.*
		from	ifinfin.dbo.cashier_received_request a
				inner join ifinfin.dbo.cashier_received_request_detail b on b.cashier_received_request_code = a.code
		where	a.agreement_no = @p_agreement_no
		and		a.request_status not in ('HOLD','PAID_RECON','CANCEL')

		raiserror ('cashier_received_request telah dilakukan update oleh system',16,1)
		return;
	end
	else
	if not exists (select 1 from dbo.mig1_agreement_asset_amortization_annualy where agreement_no = @p_agreement_no)
	begin
		raiserror ('agreement tidak terdapat dalam list mig1_agreement_asset_amortization_annualy',16,1)
		return;
	end
	else
	begin
	   -- panggil sp untuk update schedule dan hapus invoice yang telah tergenerate jika sebelumnya bulanan jadi tahunan
		exec dbo.xsp_update_schedule_kontrak_mig1_update @p_agreement_no
	  
		--exec xsp_update_schedule_kontrak_mig1_delete @p_agreement_no

	end

end
