CREATE PROCEDURE dbo.xsp_rpt_invoice_delivery
(
	@p_user_id			NVARCHAR(MAX)
	,@p_delivery_code	NVARCHAR(50)
	--,@p_invoice_no		nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin

	--(untuk data looping)
	delete dbo.rpt_invoice_delivery_detail
	where	user_id = @p_user_id ;
	delete dbo.rpt_invoice_delivery
	where	user_id = @p_user_id ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@no_invoice			nvarchar(50)
			,@tanggal				datetime
			,@npwp_no				nvarchar(50)
			,@company_address		NVARCHAR(250)
		    ,@company_phone_area	NVARCHAR(5)
		    ,@company_phone_no		NVARCHAR(15)
		    ,@customer_name			NVARCHAR(250)
		    ,@client_no				NVARCHAR(50)
		    ,@billing_to_address	NVARCHAR(250)
		    ,@tanggal_kirim			DATETIME
		    ,@no_tanda_terima		NVARCHAR(50)
			,@topovdp				INT
			,@messanger				NVARCHAR(50);

	begin try
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@topovdp = value
		from	dbo.sys_global_param
		where	code = 'TOPOVDP' ;

		select	@npwp_no = value
		from	dbo.sys_global_param
		where	code = 'invnpwp' ;
		
		set @report_title = 'INVOICE TANDA TERIMA' ;

		SELECT @messanger = NAME FROM IFINSYS.dbo.SYS_EMPLOYEE_MAIN WHERE code = @p_mod_by


		INSERT INTO dbo.RPT_INVOICE_DELIVERY
		(
		     USER_ID
		    ,REPORT_COMPANY
		    ,REPORT_TITLE
		    ,REPORT_IMAGE
		    ,CUSTOMER_NAME
		    ,CLIENT_NO
		    ,NPWP_NO
		    ,BILLING_TO_ADDRESS
		    ,TANGGAL_KIRIM
		    ,NO_TANDA_TERIMA
			--
			,DISIAPKAN_OLEH
			,MESSANGER
			,DITERIMA_OLEH
			--
		    ,CRE_DATE
		    ,CRE_BY
		    ,CRE_IP_ADDRESS
		    ,MOD_DATE
		    ,MOD_BY
		    ,MOD_IP_ADDRESS
		)
		SELECT	   
			 @p_user_id
		    ,@report_company
		    ,@report_title
		    ,@report_image
		    ,a.CLIENT_NAME
		    ,ind.CLIENT_NO
		    ,a.CLIENT_NPWP
		    ,ind.CLIENT_ADDRESS
		    ,a.DELIVERY_DATE
		    ,a.DELIVERY_CODE
			--
			,a.POSTING_BY
			,@messanger
			,a.CLIENT_NAME
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		FROM dbo.INVOICE_DELIVERY ind
			
			OUTER APPLY(
						SELECT		 MAX(idd.DELIVERY_DATE) DELIVERY_DATE
									,MAX(idd.DELIVERY_CODE) DELIVERY_CODE
									,MAX(inv.CLIENT_NAME) CLIENT_NAME
									,MAX(inv.CLIENT_NPWP) CLIENT_NPWP
									,MAX(inv.POSTING_BY) POSTING_BY
									--,MAX(cm.CLIENT_NAME) CLIENT_NAME
						FROM		dbo.INVOICE_DELIVERY_DETAIL idd 
						INNER JOIN	dbo.CLIENT_MAIN cm ON cm.CLIENT_NO = ind.CLIENT_NO 
						INNER JOIN	dbo.INVOICE inv ON inv.INVOICE_NO = idd.INVOICE_NO 
						WHERE		idd.DELIVERY_CODE = ind.CODE
						)a
		WHERE ind.CODE = @p_delivery_code;

		INSERT INTO dbo.RPT_INVOICE_DELIVERY_DETAIL
		(
		     USER_ID
		    ,CUSTOMER_NAME
		    ,BRANCH_CODE
		    ,NO_INVOICE
		    ,NILAI_DPP
		    ,PPN
		    ,TOTAL_TAGIHAN
		    ,TANGGAL_INVOICE
		    ,KELENGKAPAN_DOKUMEN_KETERANGAN
		)
		SELECT
			@p_user_id
			,inv.client_name
			,ind.branch_code
			,idd.invoice_no
			,inv.total_billing_amount
			,inv.total_ppn_amount
			,inv.total_billing_amount + inv.total_ppn_amount
			,inv.invoice_due_date
			,ind.remark
		FROM	dbo.INVOICE_DELIVERY_DETAIL idd
		inner join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
		INNER JOIN dbo.INVOICE_DELIVERY ind ON ind.CODE = idd.DELIVERY_CODE
		WHERE idd.DELIVERY_CODE = @p_delivery_code
		
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;