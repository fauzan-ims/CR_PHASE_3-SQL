--Created, Aliv at 29-05-2023
CREATE PROCEDURE [dbo].[xsp_rpt_vendor_opl_ui]
(
	@p_user_id		 nvarchar(50)
	,@p_as_of_date	 datetime		
	,@p_is_condition nvarchar(1)
)
as
begin

	delete rpt_vendor_opl_ui
	where	user_id = @p_user_id;

	declare @msg			   nvarchar(max)
			,@report_company   nvarchar(250)
			,@report_title	   nvarchar(250)
			,@report_image	   nvarchar(250)
			,@order_no		   nvarchar(50)
			,@supplier_name	   nvarchar(50)
			,@sales_dealer	   nvarchar(50)
			,@sales_contact_no nvarchar(50)
			,@skd_no		   nvarchar(50)
			,@order_no_n	   nvarchar(50)
			,@lessee		   nvarchar(50)
			,@type_asset	   nvarchar(50)
			,@chassis_no	   nvarchar(50)
			,@engine_no		   nvarchar(50)
			,@status_plat_no   nvarchar(50)
			,@exp_date		   datetime ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Vendor OPL' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		begin
			insert into rpt_vendor_opl_ui
			(
				user_id
				,report_company
				,report_title
				,report_image
				,as_of_date
				,supplier_code
				,supplier_name
				,sales_dealer
				,sales_contact_no
				,skd_no
				,order_no
				,lessee
				,type_asset
				,chassis_no
				,engine_no
				,status_plat_no
				,exp_date
				,is_condition
			)
			select distinct 
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_as_of_date
					,ass.vendor_code
					,ass.vendor_name
					,ass.requestor_name
					,sem.area_handphone_no + sem.handphone_no
					,agreement_external_no
					,po.code
					,ass.client_name
					,ass.item_name
					,avh.chassis_no
					,avh.engine_no
					,''
					,convert(nvarchar(30), avh.stnk_expired_date, 103) 'stnk_expired_date'
					,@p_is_condition
			from dbo.asset ass
			left join dbo.asset_vehicle avh on (avh.asset_code =  ass.code)
			left join ifinsys.dbo.sys_employee_main sem on (sem.code = ass.requestor_code)
			left join ifinopl.dbo.application_asset aas on (aas.fa_code = ass.code)
			left join ifinproc.dbo.procurement_request pr on (pr.asset_no = aas.asset_no)
			left join ifinproc.dbo.procurement prc on (pr.code = prc.procurement_request_code)
			left join ifinproc.dbo.quotation_review_detail qrd on (prc.code collate latin1_general_ci_as = qrd.reff_no collate latin1_general_ci_as)
			inner join ifinproc.dbo.supplier_selection_detail ssd on (ssd.reff_no collate latin1_general_ci_as = isnull(qrd.quotation_review_code,prc.code))
			inner join ifinproc.dbo.purchase_order po on (po.reff_no = ssd.selection_code)
			where purchase_date <= @p_as_of_date
		end ;

		if not exists (select * from dbo.rpt_vendor_opl_ui where user_id = @p_user_id)
		begin
				insert into dbo.rpt_vendor_opl_ui
				(
				    user_id
				    ,report_company
				    ,report_title
				    ,report_image
				    ,as_of_date
				    ,supplier_code
				    ,supplier_name
				    ,sales_dealer
				    ,sales_contact_no
				    ,skd_no
				    ,order_no
				    ,lessee
				    ,type_asset
				    ,chassis_no
				    ,engine_no
				    ,status_plat_no
				    ,exp_date
				    ,is_condition
				)
				values
				(   
					@p_user_id
				    ,@report_company
				    ,@report_title
				    ,@report_image
				    ,@p_as_of_date
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
				)
		end
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
