--Created, Aliv at 29-05-2023

CREATE PROCEDURE dbo.xsp_rpt_fa_in_use_book
(
	@p_user_id		 nvarchar(50) = ''
	,@p_branch_code	 nvarchar(50) = ''
	,@p_as_of_date	 datetime	  = ''
	,@p_type		 int		  = null
	,@p_is_condition nvarchar(1)
)
as
begin
	delete	dbo.rpt_fa_in_use_book
	where	user_id = @p_user_id ;

	declare @msg				 nvarchar(max)
			,@report_company	 nvarchar(250)
			,@report_title		 nvarchar(250)
			,@report_image		 nvarchar(250)
			,@branch_code		 nvarchar(50)
			,@branch_name		 nvarchar(50)
			,@office_name		 nvarchar(50)
			,@asset_no			 nvarchar(50)
			,@description		 nvarchar(100)
			,@brand				 nvarchar(50)
			,@model				 nvarchar(50)
			,@serial_no			 nvarchar(50)
			,@customer_name		 nvarchar(50)
			,@plat_no			 nvarchar(50)
			,@chassis_no		 nvarchar(50)
			,@engine_no			 nvarchar(50)
			,@rental_income		 decimal(18, 2)
			,@billing			 decimal(18, 2)
			,@overdue_balance	 decimal(18, 2)
			,@posisi_od			 decimal(18, 2)
			,@status_bpkb		 nvarchar(50)
			,@purchase_date		 datetime
			,@supplier			 nvarchar(50)
			,@user_dept			 nvarchar(50)
			,@cost				 decimal(18, 2)
			,@depreciation_month decimal(18, 2)
			,@book_value		 decimal(18, 2)
			,@accumulate_depre	 decimal(18, 2)
			,@status			 nvarchar(50)
			,@remark			 nvarchar(50)
			,@agreement_status	 nvarchar(50)
			,@p_type_name		 nvarchar(50)  = N'Fixed Asset In Use Book'
			,@p_ppn_pct			 decimal(9, 6) ;

	begin try
		select	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Asset Activity' ;

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

		select	@p_ppn_pct = value
		from	ifinopl.dbo.sys_global_param
		where	code = 'RTAXPPN' ;

		begin
			insert into rpt_fa_in_use_book
			(
				user_id
				,report_company
				,report_title
				,report_image
				,AS_OF_DATE
				,type
				,branch_code
				,branch_name
				,office_name
				,asset_no
				,description
				,brand
				,model
				,serial_no
				,customer_name
				,plat_no
				,chassis_no
				,engine_no
				,rental_income
				,billing
				,overdue_balance
				,posisi_od
				,status_bpkb
				,purchase_date
				,supplier
				,user_dept
				,cost
				,depreciation_month
				,book_value
				,accumulate_depre
				,status
				,remark
				,agreement_status
				,is_condition
			)
			select	@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_as_of_date
					,@p_type_name
					,@p_branch_code
					,ast.branch_name
					,ast.branch_name
					,ast.code
					,ast.item_name
					,avi.merk_name
					,avi.model_name
					,''
					,ast.client_name
					,avi.plat_no
					,avi.chassis_no
					,avi.engine_no
					,isnull(agts.lease_rounded_amount, 0)
					,(isnull(agts.lease_rounded_amount, 0) * @p_ppn_pct / 100) + isnull(agts.lease_rounded_amount, 0)
					,isnull(overdue_balance.overdue,0)
					,isnull(overdue_balance.overdue,0)
					,doc.document_status
					,ast.purchase_date
					,ast.vendor_name
					,@p_user_id
					,isnull(ast.purchase_price, 0)
					,isnull(depre.depre_amount, 0)
					,isnull(depre.net_book_value, 0)
					,isnull(depre.accum_depre_amount, 0)
					,case ast.is_depre
						 when '1' then 'DEPRECIABLE'
						 else 'NONDEPRECIABLE'
					 end
					,ast.rental_status
					,case
						 when isnull(agm.agreement_sub_status, '') = '' then agm.agreement_status
						 else agm.agreement_status + ' - ' + agm.agreement_sub_status
					 end 'agreement_status'
					,@p_is_condition
			from	dbo.asset ast
					left join dbo.asset_vehicle avi on avi.asset_code = ast.code
					left join ifinopl.dbo.agreement_main agm on agm.agreement_no = ast.agreement_no
					left join ifinopl.dbo.agreement_asset agts on (agts.agreement_no = agm.agreement_no)
																  and  (ast.code = agts.fa_code)
					outer apply
							(
								select --iddm.asset_no
										top 1
										document_status
								from	ifindoc.dbo.document_main iddm
										left join ifindoc.dbo.document_detail iddd on iddd.document_code = iddm.code
								where	iddm.asset_no = ast.code
							) doc
					outer apply
							(
								select	isnull(iasdsc.depreciation_amount, tes.depreciation_amount) 'depre_amount'
										,isnull(iasdsc.net_book_value, tes.net_book_value) 'net_book_value'
										,isnull(iasdsc.accum_depre_amount, tes.accum_depre_amount) 'accum_depre_amount'
								from	ifinams.dbo.asset_depreciation_schedule_commercial iasdsc
										outer apply
								(
									select	top 1
											id
											,depreciation_amount
											,accum_depre_amount
											,net_book_value
									from	ifinams.dbo.asset_depreciation_schedule_commercial iasdsc
									where	asset_code = ast.code
								) tes
								where	iasdsc.id = isnull((
															   select	max(id)
															   from		ifinams.dbo.asset_depreciation_schedule_commercial
															   where	depreciation_date	 < @p_as_of_date
																		and transaction_code <> ''
																		and asset_code		 = ast.code
														   ), tes.id
														  )
							) depre
					outer apply
							(
								select isnull(ai.AR_AMOUNT,0) - isnull(aip.PAYMENT_AMOUNT,0) 'overdue'
								from ifinopl.dbo.agreement_invoice ai
								inner join ifinopl.dbo.AGREEMENT_INVOICE_PAYMENT aip on aip.AGREEMENT_INVOICE_CODE = ai.CODE
								where ai.ASSET_NO = agts.asset_no
								--select	isnull(sum(isnull(billing_amount, 0) + isnull(ppn_amount, 0)), 0) overdue
								--from	ifinopl.dbo.invoice_detail invd
								--		inner join ifinopl.dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
								--where	invd.asset_no		   = agts.asset_no
								--		and inv.invoice_date   <= @p_as_of_date
								--		and inv.invoice_status = 'POST'
							) overdue_balance
					outer apply
							(
								select	isnull(sum(isnull(billing_amount, 0) + isnull(ppn_amount, 0)), 0) od
								from	ifinopl.dbo.invoice_detail invd
										inner join ifinopl.dbo.invoice inv on (inv.invoice_no = invd.invoice_no)
								where	invd.asset_no			 = agts.asset_no
										and inv.invoice_due_date <= @p_as_of_date
										and inv.invoice_status	 = 'POST'
							) posisi_od
			where	ast.rental_status	  = 'IN USE'
					and ast.purchase_date <= @p_as_of_date ;
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
