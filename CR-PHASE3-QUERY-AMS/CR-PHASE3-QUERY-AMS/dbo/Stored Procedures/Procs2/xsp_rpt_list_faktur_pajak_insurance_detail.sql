CREATE PROCEDURE [dbo].[xsp_rpt_list_faktur_pajak_insurance_detail]
(
	@p_user_id			NVARCHAR(50)
	,@p_policy_no		NVARCHAR(50)
)AS
BEGIN
	
	--DELETE	dbo.rpt_list_faktur_pajak_insurance_detail_detail 
	--WHERE	user_id = @p_user_id

	--DELETE	dbo.rpt_list_faktur_pajak_insurance_detail
	--WHERE	user_id = @p_user_id
		
	DECLARE	@kd_jenis_trx			NVARCHAR(10)
			,@fg_pengganti			NVARCHAR(50)
			,@nomor_faktur			NVARCHAR(50)
			,@masa_pajak			NVARCHAR(5)--datetime
			,@tahun_pajak			NVARCHAR(5)
			,@tanggal_faktur		DATETIME
			,@npwp					NVARCHAR(50)
			,@nama_customer			NVARCHAR(200)
			,@alamat				NVARCHAR(200)
			,@jml_dpp				DECIMAL(18,2)
			,@jml_ppn				DECIMAL(18,0)
			,@jml_ppn_bm			DECIMAL(18,0)
			,@id_ket_tamb			NVARCHAR(50)
			,@fg_uang_muka			DECIMAL(18,2)
			,@uang_muka_dpp			DECIMAL(18,2)
			,@uang_muka_ppn			DECIMAL(18,2)
			,@uang_muka_ppnbm		DECIMAL(18,2)
			,@referensi				NVARCHAR(50)
			,@masa					NVARCHAR(6)
			---
			,@kode_objek			NVARCHAR(50)
			,@nama					NVARCHAR(50)
			,@harga_satuan			DECIMAL(18,2)
			,@jumlah_barang			INT	
			,@harga_total			DECIMAL(18,2)
			,@diskon				DECIMAL(18,2)
			,@dpp					DECIMAL(18,2)
			,@ppn					DECIMAL(18,2)
			,@tarif_ppnbm			DECIMAL(18,2)
			,@ppnbm					DECIMAL(18,2)		
			-- Chichi 03. May 2018 11:33 AM
			--
			,@counter				int = 0
			,@code_barcode			nvarchar(50)
			,@invoice_code			nvarchar(50)
			--
			,@fee_type				nvarchar(10)
			,@fee_desc				nvarchar(50)
			--
			,@is_escrow				nvarchar(1)
			,@remarks				nvarchar(1000)
			--
			,@npwp_no				nvarchar(50) 
			,@npwp_name				nvarchar(50) 
			,@npwp_address_1		nvarchar(100)
			,@npwp_address_2		nvarchar(100)
			,@npwp_address_3		nvarchar(100)
			,@npwp_address_4		nvarchar(100)
			,@nama_trx				nvarchar(50)
			--
			,@jumlah_barang_str		nvarchar(50)
			,@faktur_no				NVARCHAR(50)
			,@faktur_number			NVARCHAR(50)
			,@invoice_no			NVARCHAR(50)
			,@print_count			int

			
	SELECT	@invoice_code = asset_invoice_no 
	from	dbo.INSURANCE_POLICY_MAIN
	where	CODE = @p_policy_no

	IF (isnull(@invoice_code,'')='')
	BEGIN 

	SET @invoice_no = @p_policy_no + '.INVP'

		select top 1 @faktur_no = faktur_no
		from ifinopl.dbo.faktur_main
		where status = 'NEW'

		update	ifinopl.dbo.faktur_main
		set		status = 'USED'
				,invoice_no = @invoice_no
		where	faktur_no = @faktur_no

		update	dbo.insurance_policy_main
		set		asset_invoice_no = @invoice_no
				,asset_faktur_no = @faktur_no
		where	code = @p_policy_no

	END 

	declare c_rpt_list_faktur_pajak_ar_detail cursor local fast_forward FOR
	select	'01'	--KD_JENIS_TRX		- nvarchar(10)
			,replace(replace(charindex(ipm.FAKTUR_NO,3),'-',''),'.','')		--FG_PENGGANTI		- nvarchar(10)
			,replace(replace(substring(ipm.FAKTUR_NO,4,10),'-',''),'.','')	--NOMOR_FAKTUR		- nvarchar(50)
			,datepart(month, ipm.INVOICE_DATE)								--MASA_PAJAK		- nvarchar(5)
			,DATEPART(YEAR, ipm.INVOICE_DATE)								--TAHUN_PAJAK		- nvarchar(5)
			,ipm.INVOICE_DATE												--TANGGAL_FAKTUR	- datetime
			--,replace(replace((inv.client_npwp),'-',''),'.','')												--NPWP				- nvarchar(50)
			,mi.TAX_FILE_NO
			,'PT ' + ipm.INSURED_NAME												--NAMA_CUSTOMER		- nvarchar(200)
			,mi.TAX_FILE_ADDRESS											--alamat			- nvarchar(255)
			,ipm.TOTAL_DISCOUNT_AMOUNT			--JML_DPP			- decimal(18, 2)
			,ascov.ppn_amount												--jml_ppn			- decimal(18, 2)
			,''																--referensi			- nvarchar(50)
			,ipm.ASSET_FAKTUR_NO--RIGHT(replace(replace((ASSET_FAKTUR_NO),'-',''),'.',''),13)
	from	dbo.INSURANCE_POLICY_MAIN ipm
	INNER JOIN dbo.MASTER_INSURANCE mi ON mi.CODE = ipm.INSURANCE_CODE
	outer apply
	(
		select	sum(initial_discount_ppn)  'ppn_amount'
				,sum(initial_discount_pph) 'pph_amount'
		from	dbo.insurance_policy_asset_coverage	  ipac
				inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
		where	ipa.policy_code		   = ipm.code
				--and (ipac.COVERAGE_TYPE = 'NEW' or ipac.COVERAGE_TYPE is null)
				and ipac.sppa_code = ipm.sppa_code
	)ascov					
	WHERE	ipm.CODE = @p_policy_no
			--and fad.invoice_no = inv.invoice_no

	 

	open	c_rpt_list_faktur_pajak_ar_detail
	fetch	c_rpt_list_faktur_pajak_ar_detail
	into	@kd_jenis_trx		
			,@fg_pengganti		
			,@nomor_faktur		
			,@masa_pajak		
			,@tahun_pajak		
			,@tanggal_faktur	
			,@npwp				
			,@nama_customer		
			,@alamat		
			,@jml_dpp			
			,@jml_ppn		
			,@referensi
			,@faktur_no
			
	while @@fetch_status = 0
	begin


		INSERT INTO rpt_list_faktur_pajak_insurance_detail
		(
			user_id
			,from_date
			,to_date
			----
			,kd_jenis_trx			
			,fg_pengganti			
			,nomor_faktur			
			,masa_pajak			
			,tahun_pajak			
			,tanggal_faktur		
			,npwp					
			,nama_customer			
			,alamat				
			,jml_dpp				
			,jml_ppn				
			,jml_ppn_bm			
			,id_ket_tamb			
			,fg_uang_muka			
			,uang_muka_dpp			
			,uang_muka_ppn			
			,uang_muka_ppnbm		
			,referensi	
			,code_barcode			
			--
			,npwp_no
			,npwp_name
			,npwp_address_1
			,npwp_address_2
			,npwp_address_3
			,npwp_address_4
		)
		VALUES
		(
			@p_user_id
			,NULL
			,NULL
			----
			,@kd_jenis_trx			
			,@fg_pengganti			
			,@faktur_no			
			,@masa_pajak		
			,@tahun_pajak			
			,@tanggal_faktur		
			,@npwp					
			,@nama_customer			
			,@alamat				
			,@jml_dpp				
			,@jml_ppn				
			,0		--,@jml_ppn_bm			
			,0		--,@id_ket_tamb			
			,0		--,@fg_uang_muka			
			,0		--,@uang_muka_dpp			
			,0		--,@uang_muka_ppn			
			,0		--,@uang_muka_ppnbm		
			,@referensi
			,@code_barcode			
			--
			,@npwp_no
			,@npwp_name
			,@npwp_address_1
			,''--@npwp_address_2
			,''--@npwp_address_3
			,''--@npwp_address_4
		)	
			
		INSERT INTO dbo.rpt_list_faktur_pajak_insurance_detail_detail
		(
		    user_id,
		    kode_objek,
		    nama_trx,
		    harga_satuan,
		    jumlah_barang,
		    harga_total,
		    diskon,
		    dpp,
		    ppn,
		    tarif_ppnbm,
		    ppnbm,
		    invoice_code,
		    jumlah_barang_str,
			referensi
		)
		select	@p_user_id
				,''
				,'KOMISI ASURANSI ' --am.client_name				-- nama_trx			- nvarchar(50)
				,ipm.TOTAL_DISCOUNT_AMOUNT		-- harga_satuan		- decimal(18, 2)
				,1				-- jumlah_barang	- int
				,ipm.TOTAL_DISCOUNT_AMOUNT			-- harga_total		- decimal(18, 2)
				,0		-- diskon			- decimal(18, 2)
				,ipm.TOTAL_DISCOUNT_AMOUNT -- dpp				- decimal(18, 2)
				,ascov.ppn_amount				-- ppn				- decimal(18, 2)
				,0
				,0
				,''
				,0
				,@faktur_no
		from	dbo.INSURANCE_POLICY_MAIN ipm
		outer apply
		(
			select	sum(initial_discount_ppn)  'ppn_amount'
					,sum(initial_discount_pph) 'pph_amount'
			from	dbo.insurance_policy_asset_coverage	  ipac
					inner join dbo.insurance_policy_asset ipa on (ipa.code = ipac.register_asset_code)
			where	ipa.policy_code		   = ipm.code
					--and (ipac.COVERAGE_TYPE = 'NEW' or ipac.COVERAGE_TYPE is null)
					and ipac.sppa_code = ipm.sppa_code
		)ascov					
		WHERE	ipm.CODE = @p_policy_no
		

	fetch	c_rpt_list_faktur_pajak_ar_detail
	into	@kd_jenis_trx		
			,@fg_pengganti		
			,@nomor_faktur		
			,@masa_pajak		
			,@tahun_pajak		
			,@tanggal_faktur	
			,@npwp				
			,@nama_customer		
			,@alamat		
			,@jml_dpp			
			,@jml_ppn		
			,@referensi
			,@faktur_no
	end			

	/* tutup cursor */
	close		c_rpt_list_faktur_pajak_ar_detail
	deallocate	c_rpt_list_faktur_pajak_ar_detail	

	select	@print_count = print_count
	from	dbo.INSURANCE_POLICY_MAIN
	where	CODE = @p_policy_no

	update	dbo.INSURANCE_POLICY_MAIN
	set		print_count = isnull(@print_count,0) + 1
	where	CODE = @p_policy_no
end
