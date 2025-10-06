CREATE PROCEDURE dbo.xsp_rpt_list_faktur_pajak_ar_detail_old
(
	@p_user_id			NVARCHAR(50)
	,@p_faktur_no		NVARCHAR(50)
)AS
BEGIN
	
	DELETE	dbo.rpt_list_faktur_pajak_ar_detail_detail 
	WHERE	user_id = @p_user_id

	DELETE	dbo.rpt_list_faktur_pajak_ar_detail
	WHERE	user_id = @p_user_id
		
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
			,@counter				INT = 0
			,@code_barcode			NVARCHAR(50)
			,@invoice_code			NVARCHAR(50)
			--
			,@fee_type				NVARCHAR(10)
			,@fee_desc				NVARCHAR(50)
			--
			,@is_escrow				NVARCHAR(1)
			,@remarks				NVARCHAR(1000)
			--
			,@npwp_no				NVARCHAR(50) 
			,@npwp_name				NVARCHAR(50) 
			,@npwp_address_1		NVARCHAR(100)
			,@npwp_address_2		NVARCHAR(100)
			,@npwp_address_3		NVARCHAR(100)
			,@npwp_address_4		NVARCHAR(100)
			,@nama_trx				NVARCHAR(50)
			--
			,@jumlah_barang_str		NVARCHAR(50)
			,@faktur_no				NVARCHAR(50)
			
	--select * from dbo.invoice ii
	--inner join dbo.faktur_allocation_detail fad on (fad.invoice_no = ii.invoice_no)
	--where fad.allocation_code

	SELECT	@npwp_no = REPLACE(REPLACE((value),'-',''),'.','')
	FROM	dbo.sys_global_param 
	WHERE	code IN('INVNPWP')

	SELECT	@npwp_name = value
	FROM	dbo.sys_global_param 
	WHERE	code IN('COMP2')

	SELECT	@npwp_address_1 = SUBSTRING(value,1,44) 
	FROM	dbo.sys_global_param 
	WHERE	code IN('INVADD')

	DECLARE c_rpt_list_faktur_pajak_ar_detail CURSOR LOCAL FAST_FORWARD FOR
	SELECT	REPLACE(REPLACE(SUBSTRING(fad.FAKTUR_NO,1,2),'-',''),'.','')	--KD_JENIS_TRX		- nvarchar(10)
			,REPLACE(REPLACE(CHARINDEX(fad.FAKTUR_NO,3),'-',''),'.','')		--FG_PENGGANTI		- nvarchar(10)
			,REPLACE(REPLACE(SUBSTRING(fad.FAKTUR_NO,4,10),'-',''),'.','')	--NOMOR_FAKTUR		- nvarchar(50)
			,DATEPART(MONTH, inv.new_invoice_date)								--MASA_PAJAK		- nvarchar(5)
			,DATEPART(YEAR, inv.new_invoice_date)								--TAHUN_PAJAK		- nvarchar(5)
			,inv.new_invoice_date												--TANGGAL_FAKTUR	- datetime
			,REPLACE(REPLACE((inv.client_npwp),'-',''),'.','')												--NPWP				- nvarchar(50)
			,inv.client_name												--NAMA_CUSTOMER		- nvarchar(200)
			,inv.client_address												--alamat			- nvarchar(255)
			,inv.total_billing_amount - inv.total_discount_amount			--JML_DPP			- decimal(18, 2)
			,inv.total_ppn_amount											--jml_ppn			- decimal(18, 2)
			,fad.invoice_no													--referensi			- nvarchar(50)
			,RIGHT(REPLACE(REPLACE((fad.FAKTUR_NO),'-',''),'.',''),13)
	FROM	dbo.faktur_allocation fa
			LEFT JOIN dbo.faktur_allocation_detail fad ON (fad.allocation_code = fa.code)
			LEFT JOIN dbo.invoice inv ON inv.invoice_no = fad.invoice_no
	WHERE	fa.code = @p_faktur_no
			AND fad.invoice_no = inv.invoice_no

	 

	OPEN	c_rpt_list_faktur_pajak_ar_detail
	FETCH	c_rpt_list_faktur_pajak_ar_detail
	INTO	@kd_jenis_trx		
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
			
	WHILE @@fetch_status = 0
	BEGIN

		--set @masa_pajak		= convert(nvarchar(2),month(@tanggal_faktur))
		--set @tahun_pajak	= convert(nvarchar(4),year(@tanggal_faktur))

		--set @nomor_faktur =  replace(replace(@nomor_faktur, '.', ''), '-', '')
		--set @nomor_faktur = substring(@nomor_faktur, 4, len(@nomor_faktur))
		----set @nomor_faktur = '''' + @nomor_faktur
		--set @nomor_faktur =  @nomor_faktur


		INSERT INTO rpt_list_faktur_pajak_ar_detail
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
			
		insert into dbo.rpt_list_faktur_pajak_ar_detail_detail
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
				,'SEWA KENDARAAN ' + aa.asset_name--am.client_name				-- nama_trx			- nvarchar(50)
				,ivd.billing_amount			-- harga_satuan		- decimal(18, 2)
				,ivd.quantity				-- jumlah_barang	- int
				,ivd.billing_amount			-- harga_total		- decimal(18, 2)
				,ivd.discount_amount		-- diskon			- decimal(18, 2)
				,ivd.billing_amount	-ivd.discount_amount -- dpp				- decimal(18, 2)
				,ivd.ppn_amount				-- ppn				- decimal(18, 2)
				,0
				,0
				,''
				,0
				,inv.invoice_no
		from	dbo.invoice inv 
				inner join dbo.invoice_detail ivd on ivd.invoice_no = inv.invoice_no
				inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
				INNER JOIN dbo.agreement_asset aa ON (aa.agreement_no = am.agreement_no AND ivd.ASSET_NO = aa.ASSET_NO)
		where	inv.invoice_no = @referensi	
		

		--Cursor_detail--
		
		
		--select 'Sewa Kendaraan Untuk Operasional', sum(BILLING_AMOUNT), PPN_AMOUNT,  from dbo.INVOICE_DETAIL where INVOICE_NO = ''

		--declare c_pajak_detail cursor local fast_forward for
		--select	am.client_name				-- nama_trx			- nvarchar(50)
		--		,ivd.billing_amount			-- harga_satuan		- decimal(18, 2)
		--		,ivd.quantity				-- jumlah_barang	- int
		--		,ivd.billing_amount			-- harga_total		- decimal(18, 2)
		--		,ivd.discount_amount		-- diskon			- decimal(18, 2)
		--		,ivd.billing_amount			-- dpp				- decimal(18, 2)
		--		,ivd.ppn_amount				-- ppn				- decimal(18, 2)
		--from	dbo.invoice inv 
		--		left join dbo.invoice_detail ivd on ivd.invoice_no = inv.invoice_no
		--		inner join dbo.agreement_main am on (am.agreement_no = ivd.agreement_no)
		--where	inv.invoice_no = @referensi	
		
		--/*fecth record*/
		--open	c_pajak_detail
		--fetch	c_pajak_detail
		--into 	@nama_trx		
		--		,@harga_satuan	
		--		,@jumlah_barang
		--		,@harga_total	
		--		,@diskon		
		--		,@dpp			
		--	   	,@ppn	
						
		--while @@fetch_status = 0
		--begin
			
		--	set @counter = @counter + 1

		--	set @jumlah_barang = 1
		--	set @jumlah_barang_str = '01.00'
		--	set @harga_total = @jumlah_barang * @harga_satuan
		--	set @kode_objek = 'NE.' + cast(@counter as nvarchar)

		--	--if @is_escrow = '0'
		--	--begin
				
		--	--	select	@fee_desc = description
		--	--	from	master_trx_type_header
		--	--	where	flag = 'AF'
		--	--	and		@fee_type = trx_code

		--	--	set @nama = isnull(@fee_desc, '') +  ' ' + isnull(@nama, '')
			
		--	--end
		--	--else
		--	--begin

		--	--	-- Eka+, per tanggal 27 Feb 2019, untuk invoice escrow yang diatas tanggal 16 Feb 2019
		--	--	-- menggunakan data remarks untuk invoice description
		--	--	if @tanggal_faktur < '2019-02-16'
		--	--	begin

		--	--		select	@fee_desc = description
		--	--		from	master_trx_type_header
		--	--		where	flag = 'AF'
		--	--		and		@fee_type = trx_code

		--	--		set @nama = isnull(@fee_desc, '') +  ' ' + isnull(@nama, '')

		--	--	end
		--	--	else
		--	--	begin

		--	--		set @nama = substring(@remarks, charindex(':', @remarks) + 1, len(@remarks))

		--	--	end
				
		--	--end

		--	--set @nama = isnull(@fee_desc, '') +  ' ' + isnull(@nama, '')
			
		--	/* insert into table report */							
		--	insert into rpt_list_faktur_pajak_ar_detail_detail
		--	( 
		--		user_id
		--		,kode_objek			
		--		,nama_trx				
		--		,harga_satuan			
		--		,jumlah_barang			
		--		,harga_total			
		--		,diskon				
		--		,dpp					
		--		,ppn					
		--		,tarif_ppnbm			
		--		,ppnbm
		--		,invoice_code		
		--		,jumlah_barang_str
		--	)
		--	values  
		--	( 
		--		@p_user_id
		--		,@kode_objek			
		--		,'SEWA KENDARAAN UNTUK OPERATIONAL'					
		--		,@harga_satuan			
		--		,@jumlah_barang	--@jumlah_barang			
		--		,@harga_total			
		--		,0--@diskon				
		--		,@harga_satuan--@dpp					
		--		,@ppn					
		--		,0--@tarif_ppnbm			
		--		,0--@ppnbm	
		--		,''--@invoice_code	
		--		,''--@jumlah_barang_str
							
		--	)

		--	/* fetch record berikutnya */
		--	fetch	c_pajak_detail
		--	into	@nama_trx		
		--			,@harga_satuan	
		--			,@jumlah_barang
		--			,@harga_total	
		--			,@diskon		
		--			,@dpp			
		--			,@ppn

		--end

		--/* tutup cursor */
		--close		c_pajak_detail
		--deallocate	c_pajak_detail	

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
---------------------------------------------------------------------------------------------------
end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [aryo]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [wawan]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [DSF\wawan.hermawan]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [DSF\aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [wawa.hermawan]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [aryo.budi]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [windy.nurbani]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [eddy.rakhman]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_list_faktur_pajak_ar_detail_old] TO [bsi-miki.maulana]
    AS [dbo];

