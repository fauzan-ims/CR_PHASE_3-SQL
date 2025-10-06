--Created, Aliv at 29-05-2023
CREATE procedure [dbo].[xsp_rpt_vendor_opl]
(
	@p_user_id		 nvarchar(50)
	,@p_from_date	 datetime
	,@p_to_date		 datetime
	,@p_is_condition nvarchar(1)
)
as
begin
	delete	rpt_vendor_opl
	where	user_id = @p_user_id ;

	declare @msg				  nvarchar(max)
			,@report_company	  nvarchar(250)
			,@report_title		  nvarchar(250)
			,@report_image		  nvarchar(250)
			,@name				  nvarchar(50)
			,@order_no			  nvarchar(50)
			,@skd_or_agreement_no nvarchar(50)
			,@memo_no			  nvarchar(50)
			,@memo_date			  datetime
			,@lessee			  nvarchar(50)
			,@supplier			  nvarchar(50)
			,@unit				  int
			,@type_off_payment	  nvarchar(50)
			,@plat_no			  nvarchar(50)
			,@price_inc_vat		  decimal(18, 2)
			,@disburse_date		  datetime
			,@lessee_n			  nvarchar(50) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Payment Vendor OPL' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_vendor_opl
			(
				user_id
				,report_company
				,report_title
				,report_image
				,from_date
				,to_date
				,name
				,order_no
				,skd_or_agreement_no
				,memo_no
				,memo_date
				,lessee
				,supplier
				,unit
				,type_off_payment
				,plat_no
				,price_inc_vat
				,disburse_date
				,lessee_n
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_from_date
					,@p_to_date
					,''
					,po.code
					,apla.agreement_no
					,null	-- memo dihilangkan
					,null	-- memo dihilangkan
					,aplm.client_name
					,po.supplier_name
					,aird.quantity
					,aird.item_name
					,podo.plat_no
					,aprd.payment_amount
					,apr.invoice_date
					,'' -- not used
					,''
			from	ifinproc.dbo.ap_payment_request_detail					 aprd
					inner join ifinproc.dbo.ap_payment_request				 apr on (apr.code							   = aprd.payment_request_code)
					inner join ifinproc.dbo.ap_invoice_registration_detail	 aird on (aprd.invoice_register_code		   = aird.invoice_register_code)
					inner join ifinproc.dbo.good_receipt_note				 grn on (grn.code							   = aird.grn_code)
					inner join ifinproc.dbo.good_receipt_note_detail		 grnd on (grnd.good_receipt_note_code		   = grn.code)
					inner join ifinproc.dbo.purchase_order					 po on (grn.purchase_order_code				   = po.code)
					inner join ifinproc.dbo.purchase_order_detail			 pod on (
																						pod.po_code						   = po.code
																						and	  pod.id					   = grnd.purchase_order_detail_id
																					)
					left join ifinproc.dbo.purchase_order_detail_object_info podo on (pod.id							   = podo.purchase_order_detail_id)
					left join ifinproc.dbo.supplier_selection_detail		 ssd on (ssd.id								   = pod.supplier_selection_detail_id)
					left join ifinproc.dbo.quotation_review_detail			 qrd on (qrd.id								   = ssd.quotation_detail_id)
					left join ifinproc.dbo.procurement						 prc on (prc.code collate Latin1_General_CI_AS = qrd.reff_no)
					left join ifinproc.dbo.procurement						 prc2 on (prc2.code							   = ssd.reff_no)
					left join ifinproc.dbo.procurement_request				 pr on (pr.code								   = prc.procurement_request_code)
					left join ifinproc.dbo.procurement_request				 pr2 on (pr2.code							   = prc2.procurement_request_code)
					left join ifinopl.dbo.application_asset					 apla on (apla.asset_no						   = isnull(pr.asset_no, pr2.asset_no))
					left join ifinopl.dbo.application_main					 aplm on (aplm.application_no				   = apla.application_no)
			where	cast(apr.invoice_date as date)
					between cast(@p_from_date as date) and cast(@p_to_date as date) ;
		end ;

		if not exists
		(
			select	*
			from	dbo.rpt_vendor_opl
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_vendor_opl
			(
				user_id
				,report_company
				,report_title
				,report_image
				,from_date
				,to_date
				,name
				,order_no
				,skd_or_agreement_no
				,memo_no
				,memo_date
				,lessee
				,supplier
				,unit
				,type_off_payment
				,plat_no
				,price_inc_vat
				,disburse_date
				,lessee_n
				,is_condition
			)
			values
			(
				@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,@p_from_date
				,@p_to_date
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,null
				,@p_is_condition
			) ;
		end ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
