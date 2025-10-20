CREATE PROCEDURE dbo.xsp_rpt_invoice_delivery
(
	@p_user_id			nvarchar(MAX)
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
			,@disiapkan_oleh		nvarchar(50);

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

		select @disiapkan_oleh = name from ifinsys.dbo.sys_employee_main where code = @p_mod_by

		insert into dbo.rpt_invoice_delivery
		(
		     user_id
		    ,report_company
		    ,report_title
		    ,report_image
		    ,customer_name
		    ,client_no
		    ,npwp_no
		    ,billing_to_address
		    ,tanggal_kirim
		    ,no_tanda_terima
			--
			,disiapkan_oleh
			,messanger
			,diterima_oleh
			--
		    ,cre_date
		    ,cre_by
		    ,cre_ip_address
		    ,mod_date
		    ,mod_by
		    ,mod_ip_address
		)
		select	   
			 @p_user_id
		    ,@report_company
		    ,@report_title
		    ,@report_image
		    ,a.client_name
		    ,ind.client_no
		    ,a.client_npwp
		    ,ind.client_address
		    ,ind.date
		    ,ind.code
			--
			,@disiapkan_oleh
			,case when ind.method = 'internal' then ind.employee_name
					when ind.method = 'external' then ind.external_pic_name else '' end
			,a.client_name
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		from dbo.invoice_delivery ind
			outer apply (
							select	top 1 inv.client_name
									,inv.client_npwp
									,inv.posting_by
							from	dbo.invoice_delivery_detail indd
									inner join dbo.invoice inv on inv.invoice_no = indd.invoice_no
							where	indd.delivery_code = ind.code
					)a
		where ind.code = @p_delivery_code;

		insert into dbo.rpt_invoice_delivery_detail
		(
		     user_id
		    ,customer_name
		    ,branch_code
		    ,no_invoice
		    ,nilai_dpp
		    ,ppn
		    ,total_tagihan
		    ,tanggal_invoice
		    ,kelengkapan_dokumen_keterangan
		)
		select
				@p_user_id
				,inv.client_name
				,inv.branch_code
				,inv.invoice_external_no
				,inv.total_billing_amount
				,inv.total_ppn_amount
				,inv.total_billing_amount + inv.total_ppn_amount
				,inv.new_invoice_date
				,inv.invoice_name
		from	dbo.invoice_delivery_detail idd
				inner join dbo.invoice inv with(nolock) on (inv.invoice_no = idd.invoice_no)
				inner join dbo.invoice_delivery ind on ind.code = idd.delivery_code
		where idd.delivery_code = @p_delivery_code
		
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