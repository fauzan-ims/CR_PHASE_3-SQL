CREATE PROCEDURE [dbo].[xsp_rpt_list_faktur_pajak_sale_detail]
(
	@p_user_id			NVARCHAR(50)
	,@p_sale_id			INT
)AS
BEGIN
	
	--DELETE	dbo.rpt_list_faktur_pajak_sale_detail_detail 
	--WHERE	user_id = @p_user_id

	--DELETE	dbo.rpt_list_faktur_pajak_sale_detail
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
			,@faktur_number				NVARCHAR(50)
			,@invoice_no			NVARCHAR(50)
			,@year					NVARCHAR(4)
			,@month					NVARCHAR(2)
			,@print_count			int
			
	set @year = substring(cast(datepart(year, GETDATE()) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, GETDATE()) as nvarchar), 2, 0), ' ', '0') ;

	select	@invoice_code = asset_invoice_no 
	from	dbo.sale_detail
	where	id = @p_sale_id

	IF (isnull(@invoice_code,'')='')
	BEGIN 

	SET @invoice_no = CAST(@p_sale_id AS NVARCHAR(10)) + '.INVS'

		select top 1 @faktur_no = faktur_no
		from ifinopl.dbo.faktur_main
		where status = 'NEW'

		update	ifinopl.dbo.faktur_main
		set		status = 'USED'
				,invoice_no = @invoice_no
		where	faktur_no = @faktur_no

		UPDATE dbo.SALE_DETAIL
		SET ASSET_INVOICE_NO = @invoice_no
			,ASSET_FAKTUR_NO = @faktur_no
		WHERE id = @p_sale_id

	END 

	

	declare c_rpt_list_faktur_pajak_ar_detail cursor local fast_forward for
	select	'09'																--KD_JENIS_TRX		- nvarchar(10)
			,'0'																--FG_PENGGANTI		- nvarchar(10)
			,replace(replace(substring(sd.ASSET_FAKTUR_NO,4,10),'-',''),'.','')	--NOMOR_FAKTUR		- nvarchar(50)
			,datepart(month, sd.SALE_DATE)										--MASA_PAJAK		- nvarchar(5)
			,DATEPART(YEAR, sd.SALE_DATE)										--TAHUN_PAJAK		- nvarchar(5)
			,CAST(sd.SALE_DATE AS DATE)													--TANGGAL_FAKTUR	- datetime
			--,replace(replace((inv.client_npwp),'-',''),'.','')				--NPWP				- nvarchar(50)
			,CASE 
				WHEN sd.BUYER_TYPE = 'PERSONAL' THEN sd.KTP_NO ELSE
				sd.BUYER_NPWP
			END 'NPWP'
			,sd.BUYER_NAME														--NAMA_CUSTOMER		- nvarchar(200)
			,sd.BUYER_ADDRESS													--alamat			- nvarchar(255)
			,sd.SOLD_AMOUNT - sd.PPN_ASSET										--JML_DPP					- decimal(18, 2)
			,sd.PPN_ASSET														--jml_ppn			- decimal(18, 2)
			,''																	--referensi			- nvarchar(50)
			,sd.ASSET_FAKTUR_NO--RIGHT(replace(replace((sd.FAKTUR_NO),'-',''),'.',''),13)
	from	dbo.SALE_DETAIL sd 
	WHERE	sd.ID = @p_sale_id
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
			,@faktur_number
			
	while @@fetch_status = 0
	begin


		insert into rpt_list_faktur_pajak_sale_detail
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
		values
		(
			@p_user_id
			,null
			,null
			----
			,@kd_jenis_trx			
			,@fg_pengganti			
			,@faktur_number			
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
			,@faktur_number			
			--
			,@npwp_no
			,@npwp_name
			,@npwp_address_1
			,''--@npwp_address_2
			,''--@npwp_address_3
			,''--@npwp_address_4
		)	
			
		insert into dbo.rpt_list_faktur_pajak_sale_detail_detail
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
				,@kode_objek
				,a.TYPE_ITEM_NAME + ' ' + a.CHASSIS_NO	--am.client_name				-- nama_trx			- nvarchar(50)
				,sd.SOLD_AMOUNT - sd.PPN_ASSET			-- harga_satuan		- decimal(18, 2)
				,1										-- jumlah_barang	- int
				,sd.SOLD_AMOUNT	- sd.PPN_ASSET			-- harga_total		- decimal(18, 2)
				,0										-- diskon			- decimal(18, 2)
				,sd.SOLD_AMOUNT - sd.PPN_ASSET			-- dpp				- decimal(18, 2)
				,sd.PPN_ASSET							-- ppn				- decimal(18, 2)
				,0
				,0
				,''
				,0
				,''
		from	dbo.SALE_DETAIL sd
		INNER JOIN dbo.ASSET_VEHICLE a ON a.ASSET_CODE = sd.ASSET_CODE
		where	id = @p_sale_id	
		

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
			,@faktur_number
	end			

	/* tutup cursor */
	close		c_rpt_list_faktur_pajak_ar_detail
	deallocate	c_rpt_list_faktur_pajak_ar_detail	

	select	@print_count = print_count
	from	dbo.sale_detail
	where	id = @p_sale_id

	update	dbo.sale_detail
	set		print_count = isnull(@print_count,0) + 1
	where	id = @p_sale_id

end
