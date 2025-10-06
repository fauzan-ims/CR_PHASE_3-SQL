CREATE procedure dbo.xsp_rpt_stnk_and_keur
	@p_user_id		 nvarchar(50)
	,@p_as_of_date	 datetime
	--,@p_from_date    datetime    
	--,@p_to_date      datetime 
	,@p_type_option	 nvarchar(50)
	,@p_is_condition nvarchar(1)
as
begin
	delete	rpt_stnk_and_keur
	where	user_id = @p_user_id ;

	declare @msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_title			nvarchar(250)
			,@report_image			nvarchar(250)
			,@asset_no				nvarchar(50)
			,@lessee				nvarchar(50)
			,@brand					nvarchar(50)
			,@type					nvarchar(50)
			,@surat_kuasa			nvarchar(50)
			,@object				nvarchar(50)
			,@color					nvarchar(50)
			,@year					nvarchar(4)
			,@chassis_no			nvarchar(50)
			,@engine_no				nvarchar(50)
			,@plat_no				nvarchar(50)
			,@keur_or_stnk			nvarchar(50)
			,@end_date_keur_or_stnk datetime
			,@area					nvarchar(50)
			,@keur_or_stnk_region	nvarchar(50)
			,@order_name			nvarchar(50)
			,@birojasa_name			nvarchar(50)
			,@date_received_file	datetime
			,@end_date_new			datetime
			,@date_of_delivery_cust datetime
			,@name					nvarchar(50)
			,@address				nvarchar(50)
			,@no_telp				nvarchar(50)
			,@notes					nvarchar(50)
			,@report_date			datetime ;

	begin try
		select	@report_company = value
		from	dbo.sys_global_param
		where	CODE = 'COMP2' ;

		set @report_title = N'Report Monitoring STNK and Keur' ;

		select	@report_image = value
		from	dbo.sys_global_param
		where	CODE = 'IMGDSF' ;

		begin
			declare @temp_table_stnk table
			(
				asset_no					  nvarchar(50)
				,lessee						  nvarchar(250)
				,brand						  nvarchar(250)
				,type						  nvarchar(250)
				,surat_kuasa				  nvarchar(50)
				,object						  nvarchar(250)
				,color						  nvarchar(50)
				,year						  nvarchar(50)
				,chassis_no					  nvarchar(50)
				,engine_no					  nvarchar(50)
				,plat_no					  nvarchar(50)
				,end_date_keur_or_stnk		  datetime
				,area						  nvarchar(50)
				,birojasa_name				  nvarchar(250)
				,order_name					  nvarchar(250)
				,order_date					  datetime
				,received_date				  datetime
				,end_date_new				  datetime
				,aging						  int
				,date_of_delivery_to_customer datetime
				,delivery_to_name			  nvarchar(250)
				,delivery_to_address		  nvarchar(4000)
				,delivery_to_phone_no		  nvarchar(50)
				,delivery_by				  nvarchar(250)
				,service_fee_amount			  decimal(18, 2)
				,actual_fee					  decimal(18, 2)
				,ppn						  decimal(18, 2)
				,pph						  decimal(18, 2)
				,total_amount				  decimal(18, 2)
				,status						  nvarchar(50)
				,stnk_expired_date			  datetime
			) ;

			insert into @temp_table_stnk
			(
				asset_no
				,lessee
				,brand
				,type
				,surat_kuasa
				,object
				,color
				,year
				,chassis_no
				,engine_no
				,plat_no
				,end_date_keur_or_stnk
				,area
				,birojasa_name
				,order_name
				,order_date
				,received_date
				,end_date_new
				,aging
				,date_of_delivery_to_customer
				,delivery_to_name
				,delivery_to_address
				,delivery_to_phone_no
				,delivery_by
				,service_fee_amount
				,actual_fee
				,ppn
				,pph
				,total_amount
				,status
				,stnk_expired_date
			)
			select	asset.code
					,asset.client_name
					,vehicle.merk_name
					,stuff((
							   select	', ' + isnull(replace(sgd.description, '&', ' dan '), '')
							   from		dbo.register_detail				   rd
										inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.code
							   where	register_code = rm.code
										and sgd.DESCRIPTION like '%KEUR%'
							   for xml path('')
						   ), 1, 1, ''
						  )
					,null
					,vehicle.type_item_name
					,vehicle.colour
					,vehicle.built_year
					,vehicle.chassis_no
					,vehicle.engine_no
					,vehicle.plat_no
					,case
						 when rm.stnk_expired_date is not null then rm.stnk_expired_date
						 else rm.keur_expired_date
					 end
					,null
					,public_service.public_service_name
					,nama.name
					,order_main.order_date
					,rm.receive_date
					,rm.stnk_tax_date
					,isnull(datediff(day, order_main.order_date, dbo.xfn_get_system_date()), 0)
					,rm.delivery_date
					,rm.delivery_to_name
					,rm.delivery_to_address
					,isnull(rm.delivery_to_phone_area, '') + isnull(rm.delivery_to_phone_no, '')
					,rm.delivery_receive_by
					,rm.realization_service_fee
					,rm.realization_actual_fee
					,rm.realization_service_fee * (rm.realization_service_tax_ppn_pct / 100)
					,rm.realization_service_fee * (rm.realization_service_tax_pph_pct / 100)
					,rm.public_service_settlement_amount
					,rm.register_status
					,vehicle.stnk_expired_date
			from	dbo.register_main rm
					outer apply
			(
				select	om.ORDER_DATE
						,om.PUBLIC_SERVICE_CODE
						,om.CRE_BY
				from	dbo.ORDER_MAIN om
				where	om.code collate latin1_general_ci_as = rm.order_code collate latin1_general_ci_as
			)						  order_main
					outer apply
			(
				select	mps.PUBLIC_SERVICE_NAME
				from	dbo.MASTER_PUBLIC_SERVICE mps
				where	mps.code = order_main.PUBLIC_SERVICE_CODE
			) public_service
					outer apply
			(
				select	code
						,ass.client_name
				from	dbo.asset ass
				where	rm.fa_code = ass.code
			) asset
					outer apply
			(
				select	av.merk_name
						,av.type_item_name
						,av.colour
						,av.built_year
						,av.chassis_no
						,av.engine_no
						,av.plat_no
						,av.stnk_expired_date
				from	dbo.asset_vehicle av
				where	av.asset_code = rm.fa_code
			) vehicle
					outer apply
			(
				select	name
				from	ifinsys.dbo.SYS_EMPLOYEE_MAIN
				where	code = order_main.CRE_BY
			) nama
			where	rm.register_status not in --= @p_type_option
			(
				'CANCEL'
			)
					and (stuff((
								   select	', ' + isnull(replace(sgd.description, '&', ' dan '), '')
								   from		dbo.register_detail				   rd
											inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.code
								   where	register_code = rm.code
								   for xml path('')
							   ), 1, 1, ''
							  ) like '%STNK%'
						) ;

			if (@p_type_option like '%STNK%')
			begin
				insert into dbo.rpt_stnk_and_keur
				(
					user_id
					,report_company
					,report_title
					,report_image
					,from_date
					,to_date
					,as_of_date
					,asset_no
					,lessee
					,brand
					,type
					,surat_kuasa
					,object
					,color
					,year
					,chassis_no
					,engine_no
					,plat_no
					,end_date_keur_or_stnk
					,area
					,birojasa_name
					,order_name
					,order_date
					,received_date
					,end_date_new
					,aging
					,date_of_delivery_to_customer
					,delivery_to_name
					,delivery_to_address
					,delivery_to_phone_no
					,delivery_by
					,service_fee_amount
					,actual_fee
					,ppn
					,pph
					,total_amount
					,status
					,is_condition
				)
				select	@p_user_id
						,@report_company
						,@report_title
						,@report_image
						,dbo.xfn_get_system_date()
						,dbo.xfn_get_system_date()
						,@p_as_of_date
						,asset_no
						,lessee
						,brand
						,type
						,surat_kuasa
						,object
						,color
						,year
						,chassis_no
						,engine_no
						,plat_no
						,end_date_keur_or_stnk
						,area
						,birojasa_name
						,order_name
						,order_date
						,received_date
						,end_date_new
						,aging
						,date_of_delivery_to_customer
						,delivery_to_name
						,delivery_to_address
						,delivery_to_phone_no
						,delivery_by
						,service_fee_amount
						,actual_fee
						,ppn
						,pph
						,total_amount
						,status
						,@p_is_condition
				from	@temp_table_stnk
				where	stnk_expired_date
				between cast(dateadd(year, -1, @p_as_of_date) as date) and cast(dateadd(year, 1, @p_as_of_date) as date) ;

				delete @temp_table_stnk ;

			--select	@p_user_id
			--		,@report_company
			--		,@report_title
			--		,@report_image
			--		,dbo.xfn_get_system_date()
			--		,dbo.xfn_get_system_date()
			--		,@p_as_of_date
			--		,ast.code
			--		,ast.client_name
			--		,av.merk_name
			--		,stuff((
			--				   select	', ' + isnull(replace(sgd.description, '&', ' dan '), '')
			--				   from		dbo.register_detail				   rd
			--							inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.code
			--				   where	register_code = rm.code
			--							and sgd.DESCRIPTION like '%STNK%'
			--				   for xml path('')
			--			   ), 1, 1, ''
			--			  )
			--		,null
			--		,av.type_item_name
			--		,av.colour
			--		,av.built_year
			--		,av.chassis_no
			--		,av.engine_no
			--		,av.plat_no
			--		,case
			--			 when rm.stnk_expired_date is not null then rm.stnk_expired_date
			--			 else rm.keur_expired_date
			--		 end
			--		,null
			--		,mps.public_service_name
			--		,nama.name
			--		,om.order_date
			--		,rm.receive_date
			--		,rm.stnk_tax_date
			--		,isnull(datediff(day, om.order_date, dbo.xfn_get_system_date()), 0)
			--		,rm.delivery_date
			--		,rm.delivery_to_name
			--		,rm.delivery_to_address
			--		,isnull(rm.delivery_to_phone_area, '') + isnull(rm.delivery_to_phone_no, '')
			--		,rm.delivery_receive_by
			--		,rm.realization_service_fee
			--		,rm.realization_actual_fee
			--		,rm.realization_service_fee * (rm.realization_service_tax_ppn_pct / 100)
			--		,rm.realization_service_fee * (rm.realization_service_tax_pph_pct / 100)
			--		,rm.public_service_settlement_amount
			--		,rm.register_status
			--		,@p_is_condition
			--from	dbo.asset							ast
			--		inner join dbo.asset_vehicle		av on av.asset_code = ast.code
			--		left join dbo.register_main			rm on rm.fa_code = ast.code
			--		left join dbo.order_main			om on om.code collate latin1_general_ci_as = rm.order_code collate latin1_general_ci_as
			--		left join dbo.master_public_service mps on mps.code = om.public_service_code
			--		left join ifinbam.dbo.master_vendor mve on mve.code = ast.vendor_code
			--		outer apply
			--(
			--	select	name
			--	from	ifinsys.dbo.SYS_EMPLOYEE_MAIN
			--	where	code = om.CRE_BY
			--)											nama
			--where	(
			--			av.stnk_expired_date
			--		between cast(dateadd(month, -2, @p_as_of_date) as date) and cast(dateadd(month, 5, @p_as_of_date) as date)
			--			or	av.stnk_expired_date
			--		between cast(dateadd(year, -1, @p_as_of_date) as date) and cast(dateadd(year, 1, @p_as_of_date) as date)
			--		)
			--		and rm.register_status not in --= @p_type_option
			--(
			--	'CANCEL'
			--)
			--		and (stuff((
			--					   select	', ' + isnull(replace(sgd.description, '&', ' dan '), '')
			--					   from		dbo.register_detail				   rd
			--								inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.code
			--					   where	register_code = rm.code
			--					   for xml path('')
			--				   ), 1, 1, ''
			--				  ) like '%STNK%'
			--			) ;
			end ;
			else
			begin
				insert into dbo.rpt_stnk_and_keur
				(
					user_id
					,report_company
					,report_title
					,report_image
					,from_date
					,to_date
					,as_of_date
					,asset_no
					,lessee
					,brand
					,type
					,surat_kuasa
					,object
					,color
					,year
					,chassis_no
					,engine_no
					,plat_no
					,end_date_keur_or_stnk
					,area
					,birojasa_name
					,order_name
					,order_date
					,received_date
					,end_date_new
					,aging
					,date_of_delivery_to_customer
					,delivery_to_name
					,delivery_to_address
					,delivery_to_phone_no
					,delivery_by
					,service_fee_amount
					,actual_fee
					,ppn
					,pph
					,total_amount
					,status
					,is_condition
				)
				select	@p_user_id
						,@report_company
						,@report_title
						,@report_image
						,dbo.xfn_get_system_date()
						,dbo.xfn_get_system_date()
						,@p_as_of_date
						,ast.code
						,ast.client_name
						,av.merk_name
						,stuff((
								   select	', ' + isnull(replace(sgd.description, '&', ' dan '), '')
								   from		dbo.register_detail				   rd
											inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.code
								   where	register_code = rm.code
											and sgd.DESCRIPTION like '%KEUR%'
								   for xml path('')
							   ), 1, 1, ''
							  )
						,null
						,av.type_item_name
						,av.colour
						,av.built_year
						,av.chassis_no
						,av.engine_no
						,av.plat_no
						,case
							 when rm.stnk_expired_date is not null then rm.stnk_expired_date
							 else rm.keur_expired_date
						 end
						,null
						,mps.public_service_name
						,nama.name
						,om.order_date
						,rm.receive_date
						,rm.stnk_tax_date
						,isnull(datediff(day, om.order_date, dbo.xfn_get_system_date()), 0)
						,rm.delivery_date
						,rm.delivery_to_name
						,rm.delivery_to_address
						,isnull(rm.delivery_to_phone_area, '') + isnull(rm.delivery_to_phone_no, '')
						,rm.delivery_receive_by
						,rm.realization_service_fee
						,rm.realization_actual_fee
						,rm.realization_service_fee * (rm.realization_service_tax_ppn_pct / 100)
						,rm.realization_service_fee * (rm.realization_service_tax_pph_pct / 100)
						,rm.public_service_settlement_amount
						,rm.register_status
						,@p_is_condition
				from	dbo.asset							 ast
						inner join dbo.asset_vehicle		 av on av.asset_code = ast.code
						inner join dbo.register_main		 rm on rm.fa_code = ast.code
						inner join dbo.order_main			 om on om.code collate latin1_general_ci_as = rm.order_code collate latin1_general_ci_as
						inner join dbo.master_public_service mps on mps.code = om.public_service_code
						left join ifinbam.dbo.master_vendor	 mve on mve.code = ast.vendor_code
						outer apply
				(
					select	name
					from	ifinsys.dbo.SYS_EMPLOYEE_MAIN
					where	code = om.CRE_BY
				)											 nama
				where	(
							av.keur_expired_date
						between cast(dateadd(month, -2, @p_as_of_date) as date) and cast(dateadd(month, 5, @p_as_of_date) as date)
							or	av.keur_expired_date
						between cast(dateadd(year, -1, @p_as_of_date) as date) and cast(dateadd(year, 1, @p_as_of_date) as date)
						)
						and rm.register_status not in --= @p_type_option
				(
					'CANCEL'
				)
						and (stuff((
									   select	', ' + isnull(replace(sgd.description, '&', ' dan '), '')
									   from		dbo.register_detail				   rd
												inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.code
									   where	register_code = rm.code
									   for xml path('')
								   ), 1, 1, ''
								  ) like '%KEUR%'
							) ;
			end ;
		end ;

		--       insert into rpt_stnk_and_keur
		--       (
		--          user_id
		--          ,report_company
		--          ,report_title
		--          ,report_image
		--          ,from_date
		--          ,to_date
		--          ,asset_no
		--          ,lessee
		--          ,brand
		--          ,type
		--          ,surat_kuasa
		--          ,object
		--          ,color
		--          ,year
		--          ,chassis_no
		--          ,engine_no
		--          ,plat_no
		--          ,keur_or_stnk
		--          ,end_date_keur_or_stnk
		--          ,area
		--          ,keur_or_stnk_region
		--	,ORDER_NAME
		--          ,order_date
		--          ,birojasa_name
		--          ,date_received_file
		--          ,end_date_new
		--          ,date_of_delivery_cust
		--          ,name
		--          ,address
		--          ,no_telp
		--          ,notes
		--          ,report_date
		--	,is_condition
		--       )
		--select	@p_user_id
		--		,@report_company
		--		,@report_title
		--		,@report_image
		--		,@p_from_date
		--		,@p_to_date
		--		,ast.code
		--		,ast.client_name
		--		,av.merk_name
		--		,stuff((
		--				   select	', ' + isnull(REPLACE(sgd.description,'&',' DAN '), '')
		--				   from		dbo.register_detail rd
		--							inner join dbo.sys_general_subcode sgd on rd.service_code = sgd.CODE
		--				   where	register_code = rm.code
		--				   for xml path('')
		--			   ), 1, 1, ''
		--			  )
		--		,mps.contact_person_name --'surat_kuasa'
		--		,av.type_item_name
		--		,av.colour
		--		,av.built_year
		--		,av.chassis_no
		--		,av.engine_no
		--		,av.plat_no
		--		,cast(rm.public_service_settlement_amount as nvarchar(50)) + '/' + mps.public_service_name -- fee keur/stnk
		--		,case
		--			 when rm.stnk_expired_date is not null then rm.stnk_expired_date
		--			 else rm.keur_expired_date
		--		 end
		--		,ast.branch_name
		--		,isnull(ast.unit_city_name, '-') + ', ' + isnull(ast.unit_province_name, '-') -- wilayah uji
		--		,om.ORDER_STATUS --order status
		--		,om.order_date
		--		,mps.public_service_name
		--		,rm.realization_date
		--		,rm.receive_date
		--		,rm.delivery_date
		--		,rm.delivery_receive_by
		--		,mve.address
		--		,mps.phone_no
		--		,rm.delivery_remarks
		--		,cast(@p_to_date as date)
		--		,@p_is_condition
		--from	dbo.asset ast
		--		inner join dbo.asset_vehicle av on av.asset_code = ast.code
		--		inner join dbo.register_main rm on rm.fa_code = ast.code
		--		inner join dbo.order_main om on om.code collate latin1_general_ci_as = rm.order_code collate latin1_general_ci_as
		--		inner join dbo.master_public_service mps on mps.code = om.public_service_code
		--		left join IFINBAM.dbo.master_vendor mve on mve.code = ast.vendor_code
		----		outer apply
		----(
		----	select	avi1.stnk_expired_date 'exp_date'
		----	from	ifinams.dbo.asset ast1
		----			left join ifinams.dbo.asset_vehicle avi1 on avi1.asset_code			  = ast1.code
		----			left join ifinams.dbo.asset_document asd1 on asd1.asset_code		  = ast1.code
		----			left join ifinams.dbo.sys_general_document sgt1 on asd1.document_code = sgt1.code
		----	where	SGT1.document_name = 'STNK'
		----			and ast1.CODE	   = ast.CODE
		----) stnk
		----		outer apply
		----(
		----	select	avi1.keur_expired_date 'EXP_DATE'
		----	from	ifinams.dbo.asset ast1
		----			left join ifinams.dbo.asset_vehicle avi1 on avi1.asset_code			  = ast1.code
		----			left join ifinams.dbo.asset_document asd1 on asd1.asset_code		  = ast1.code
		----			left join ifinams.dbo.sys_general_document sgt1 on asd1.document_code = sgt1.code
		----	where	sgt1.document_name = 'KEUR'
		----			and ast1.code	   = ast.code
		----) keur
		--where	rm.REGISTER_DATE between cast(@p_from_date as date) and cast(@p_to_date as date)
		--		and rm.register_status not in
		--(
		--	'CANCEL'
		--) ;
		--    end ;
		if not exists
		(
			select	*
			from	dbo.rpt_stnk_and_keur
			where	user_id = @p_user_id
		)
		begin
			insert into dbo.rpt_stnk_and_keur
			(
				user_id
				,report_company
				,report_title
				,report_image
				,from_date
				,to_date
				,as_of_date
				,asset_no
				,lessee
				,brand
				,type
				,surat_kuasa
				,object
				,color
				,year
				,chassis_no
				,engine_no
				,plat_no
				,end_date_keur_or_stnk
				,area
				,birojasa_name
				,order_name
				,order_date
				,received_date
				,end_date_new
				,aging
				,date_of_delivery_to_customer
				,delivery_to_name
				,delivery_to_address
				,delivery_to_phone_no
				,delivery_by
				,service_fee_amount
				,actual_fee
				,ppn
				,pph
				,total_amount
				,status
				,is_condition
			)
			values
			(
				@p_user_id
				,@report_company
				,@report_title
				,@report_image
				,null
				,null
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
