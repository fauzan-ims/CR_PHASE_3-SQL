CREATE PROCEDURE dbo.xsp_mtn_rpt_invoice_insert
(
	@p_user_id		   nvarchar(50)
	,@p_invoice_no							nvarchar(50)
)
as
begin
	declare		@invoice_no				nvarchar(50)
				,@invoice_externa_no	nvarchar(50)
				,@invoice_kwitansi_no	nvarchar(50)
				,@year					nvarchar(4)
				,@years					nvarchar(4)
				,@month					nvarchar(2)
				,@user_id				nvarchar(50)
				,@msg					nvarchar(max) ;

	begin try
	
	if (@p_invoice_no in ('01556.INV.2004.11.2023', '01499.INV.2004.11.2023','01500.INV.2004.11.2023'))
		begin

			if (@p_invoice_no = '01556.INV.2004.11.2023')
			begin
				set @user_id = N'SYS01556' ;
			end ;
			else if (@p_invoice_no = '01499.INV.2004.11.2023')
			begin
				set @user_id = N'SYS01499' ;
			end ;
			else if (@p_invoice_no = '01500.INV.2004.11.2023')
			begin
				set @user_id = N'SYS01500' ;
			end

			insert into dbo.RPT_INVOICE_PENAGIHAN
			(
				USER_ID
				,NO_INVOICE
				,REPORT_COMPANY
				,REPORT_TITLE
				,REPORT_IMAGE
				,TANGGAL
				,NPWP_COMPANY
				,STAR_PERIODE
				,END_PERIODE
				,JATUH_TEMPO
				,NO_PERJANJIAN
				,CLIENT_NAME
				,ALAMAT_CLIENT
				,NPWP_NO
				,JENIS
				,TYPE
				,URAIAN
				,JUMLAH
				,HARGA_PERUNIT
				,JUMLAH_HARGA
				,SUB_TOTAL
				,PPN
				,TOTAL
				,SEJUMLAH
				,NAMA_BANK
				,REK_ATAS_NAMA
				,NO_REK
				,EMPLOYEE_NAME
				,EMPLOYEE_POSITION
				,INVOICE_TYPE
				,PERIODE_DENDA_FROM
				,PERIODE_DENDA_TO
				,CRE_DATE
				,CRE_BY
				,CRE_IP_ADDRESS
				,MOD_DATE
				,MOD_BY
				,MOD_IP_ADDRESS
				,INVOICE_NO
			)
			SELECT @p_user_id
				  ,NO_INVOICE
				  ,REPORT_COMPANY
				  ,REPORT_TITLE
				  ,REPORT_IMAGE
				  ,TANGGAL
				  ,NPWP_COMPANY
				  ,STAR_PERIODE
				  ,END_PERIODE
				  ,JATUH_TEMPO
				  ,NO_PERJANJIAN
				  ,CLIENT_NAME
				  ,ALAMAT_CLIENT
				  ,NPWP_NO
				  ,JENIS
				  ,TYPE
				  ,URAIAN
				  ,JUMLAH
				  ,HARGA_PERUNIT
				  ,JUMLAH_HARGA
				  ,SUB_TOTAL
				  ,PPN
				  ,TOTAL
				  ,SEJUMLAH
				  ,NAMA_BANK
				  ,REK_ATAS_NAMA
				  ,NO_REK
				  ,EMPLOYEE_NAME
				  ,EMPLOYEE_POSITION
				  ,INVOICE_TYPE
				  ,PERIODE_DENDA_FROM
				  ,PERIODE_DENDA_TO
				  ,CRE_DATE
				  ,CRE_BY
				  ,CRE_IP_ADDRESS
				  ,MOD_DATE
				  ,MOD_BY
				  ,MOD_IP_ADDRESS
				  ,INVOICE_NO FROM dbo.RPT_INVOICE_PENAGIHAN where USER_ID = @user_id
			
			INSERT INTO dbo.RPT_INVOICE_PENAGIHAN_DETAIL_ASSET
			(
				USER_ID
				,JENIS
				,CODE
				,TYPE
				,URAIAN
				,JUMLAH
				,HARGA_PERUNIT
				,JUMLAH_HARGA
				,SUB_TOTAL
				,PPN
				,PPN_RATE
				,TOTAL
				,INVOICE_NO
			)
			SELECT @p_user_id
				  ,JENIS
				  ,CODE
				  ,TYPE
				  ,URAIAN
				  ,JUMLAH
				  ,HARGA_PERUNIT
				  ,JUMLAH_HARGA
				  ,SUB_TOTAL
				  ,PPN
				  ,PPN_RATE
				  ,TOTAL
				  ,INVOICE_NO FROM rpt_invoice_penagihan_detail_asset where USER_ID = @user_id

			INSERT INTO dbo.RPT_INVOICE_PEMBATALAN_KONTRAK_DETAIL
			(
				USER_ID
				,JENIS
				,TYPE
				,URAIAN
				,NO_POLISI
				,JUMLAH
				,JUMLAH_DENDA
				,JUMLAH_DESC
				,NO_INVOICE
			)
			SELECT @p_user_id
				  ,JENIS
				  ,TYPE
				  ,URAIAN
				  ,NO_POLISI
				  ,JUMLAH
				  ,JUMLAH_DENDA
				  ,JUMLAH_DESC
				  ,NO_INVOICE FROM dbo.RPT_INVOICE_PEMBATALAN_KONTRAK_DETAIL where USER_ID = @user_id

			INSERT INTO dbo.RPT_INVOICE_PENAGIHAN_DETAIL
			(
				USER_ID
				,NO_INVOICE
				,AGREEMENT_NO
				,AGREEMENT_DATE
				,JENIS
				,TYPE
				,UNIT
				,PERIODE_STAR
				,PERIODE_END
				,POLICE_NO
				,CONTRACT_STAR
				,CONTRACT_END
				,HARGA_PERUNIT
				,JUMLAH_HARGA
				,SUB_TOTAL
				,PPN_PCT
				,PPN
				,TOTAL
				,SUM_AGREEMENT
				,SUM_JENIS_OR_TYPE
				,SUM_UNIT
				,PERIODE_SEWA
				,REMARKS
			)
			SELECT @p_user_id
				  ,NO_INVOICE
				  ,AGREEMENT_NO
				  ,AGREEMENT_DATE
				  ,JENIS
				  ,TYPE
				  ,UNIT
				  ,PERIODE_STAR
				  ,PERIODE_END
				  ,POLICE_NO
				  ,CONTRACT_STAR
				  ,CONTRACT_END
				  ,HARGA_PERUNIT
				  ,JUMLAH_HARGA
				  ,SUB_TOTAL
				  ,PPN_PCT
				  ,PPN
				  ,TOTAL
				  ,SUM_AGREEMENT
				  ,SUM_JENIS_OR_TYPE
				  ,SUM_UNIT
				  ,PERIODE_SEWA
				  ,REMARKS FROM dbo.RPT_INVOICE_PENAGIHAN_DETAIL where USER_ID = @user_id

				  INSERT INTO dbo.RPT_INVOICE_KWITANSI
				  (
				  	USER_ID
				  	,NO_INVOICE
				  	,REPORT_COMPANY
				  	,REPORT_TITLE
				  	,REPORT_IMAGE
				  	,NO_KWITANSI
				  	,SUDAH_TERIMA
				  	,SEJUMLAH
				  	,UNTUK_PEMBAYARAN
				  	,STAR_PERIODE
				  	,END_PERIODE
				  	,JATUH_TEMPO
				  	,TOTAL
				  	,KOTA
				  	,TANGGAL
				  	,NAMA
				  	,JABATAN
				  	,NAMA_BANK
				  	,REK_ATAS_NAMA
				  	,NO_REK
				  	,TYPE
				  	,CRE_DATE
				  	,CRE_BY
				  	,CRE_IP_ADDRESS
				  	,MOD_DATE
				  	,MOD_BY
				  	,MOD_IP_ADDRESS
				  	,CURRENCY_DESC
				  ) 
				  select @p_user_id
						,NO_INVOICE
						,REPORT_COMPANY
						,REPORT_TITLE
						,REPORT_IMAGE
						,NO_KWITANSI
						,SUDAH_TERIMA
						,SEJUMLAH
						,UNTUK_PEMBAYARAN
						,STAR_PERIODE
						,END_PERIODE
						,JATUH_TEMPO
						,TOTAL
						,KOTA
						,TANGGAL
						,NAMA
						,JABATAN
						,NAMA_BANK
						,REK_ATAS_NAMA
						,NO_REK
						,TYPE
						,CRE_DATE
						,CRE_BY
						,CRE_IP_ADDRESS
						,MOD_DATE
						,MOD_BY
						,MOD_IP_ADDRESS
						,CURRENCY_DESC FROM dbo.RPT_INVOICE_KWITANSI where USER_ID = @user_id

						INSERT INTO dbo.RPT_INVOICE_KWITANSI_DETAIL
						(
							USER_ID
							,RECEIPT_NO
							,AGREEMENT_NO
							,AGREEMENT_DATE
							,JENIS_ALAT
							,TYPE
							,UNIT
							,STAR_PERIODE
							,END_PERIODE
							,NO_POLISI
							,STAR_CONTRACT
							,END_CONTRACT
							,HARGA_PERUNIT
							,JUMLAH_HARGA
							,SUB_TOTAL
							,PPN
							,PPH
							,TOTAL
							,SUM_AGREEMENT
							,SUM_JENI_OR_TYPE
							,SUM_UNIT
							,KWITANSI_NO
						) 
						select @p_user_id
							  ,RECEIPT_NO
							  ,AGREEMENT_NO
							  ,AGREEMENT_DATE
							  ,JENIS_ALAT
							  ,TYPE
							  ,UNIT
							  ,STAR_PERIODE
							  ,END_PERIODE
							  ,NO_POLISI
							  ,STAR_CONTRACT
							  ,END_CONTRACT
							  ,HARGA_PERUNIT
							  ,JUMLAH_HARGA
							  ,SUB_TOTAL
							  ,PPN
							  ,PPH
							  ,TOTAL
							  ,SUM_AGREEMENT
							  ,SUM_JENI_OR_TYPE
							  ,SUM_UNIT
							  ,KWITANSI_NO FROM dbo.RPT_INVOICE_KWITANSI_DETAIL where USER_ID = @user_id
		end

		--delete dbo.rpt_invoice_penagihan
		--where	user_id = @p_user_id ;

		--delete dbo.rpt_invoice_penagihan_detail_asset
		--where	user_id = @p_user_id ;

		--delete dbo.rpt_invoice_pembatalan_kontrak_detail
		--where	user_id = @p_user_id ;

		--delete dbo.rpt_invoice_penagihan_detail
		--where	user_id = @p_user_id ;

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

