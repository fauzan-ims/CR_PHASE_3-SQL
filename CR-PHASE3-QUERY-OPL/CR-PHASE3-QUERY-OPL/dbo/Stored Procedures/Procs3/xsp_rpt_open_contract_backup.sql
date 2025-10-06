--created by, Rian at 20/06/2023 

create PROCEDURE dbo.xsp_rpt_open_contract_backup
(
	@p_user_id		   nvarchar(15)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   NVARCHAR(250)
	,@p_from_date	   DATETIME
	,@p_to_date		   DATETIME
    ,@p_is_condition   NVARCHAR(1)
	--
	,@p_cre_date	   DATETIME
	,@p_cre_by		   NVARCHAR(15)
	,@p_cre_ip_address NVARCHAR(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
BEGIN

	delete dbo.rpt_open_contract
	where	user_id = @p_user_id ;

	-- CREATE TEMP TABLE 
	create table #rpt_open_contract
	(
		user_id				  nvarchar(15)
		,from_date			  datetime
		,to_date			  datetime
		,branch_code		  nvarchar(50)
		,report_company		  nvarchar(250)
		,report_image		  nvarchar(250)
		,report_title		  nvarchar(250)
		,nomor_skd			  nvarchar(50)
		,nomor_kontrak		  nvarchar(50)
		,customer			  nvarchar(250)
		,total_unit			  int
		,brand				  nvarchar(250)
		,type_unit			  nvarchar(250)
		,product			  nvarchar(250)
		,tahun				  nvarchar(4)
		,tenor				  int
		,value_date			  datetime
		,l_r				  decimal(9, 6)
		,roa				  decimal(9, 6)
		,rv					  decimal(9, 6)
		,otr_price			  decimal(18, 2)
		,cost_price			  decimal(18, 2)
		,net_investasi		  decimal(18, 2)
		,rv_amount			  decimal(18, 2)
		,rental_fee			  decimal(18, 2)
		,total_profit		  decimal(18, 2)
		,rent_to_own		  nvarchar(10)
		,unit_condition		  nvarchar(10)
		,skema_maintenance	  nvarchar(25)
		,maintenance_cost	  decimal(18, 2)
		,supplier			  nvarchar(250)
		,mo					  nvarchar(250)
		,section			  nvarchar(250)
		,keterangan			  nvarchar(4000)
		,mits				  nvarchar(25)
		,branch_name		  nvarchar(250)
		,average_asset_amount decimal(18, 2)
		,is_condition		  nvarchar(1)
		,is_gts				  NVARCHAR(3)
		,unit_gts			  NVARCHAR(100)
		,tahun_unit_gts		  NVARCHAR(4)
		,cre_date			  datetime
		,cre_by				  nvarchar(15)
		,cre_ip_address		  nvarchar(15)
		,mod_date			  datetime
		,mod_by				  nvarchar(15)
		,mod_ip_address		  nvarchar(15)
	) ;

	declare @msg				nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)
			,@nomor_skd			nvarchar(50)
			,@nomor_kontrak		nvarchar(50)
			,@customer			nvarchar(250)
			,@total_unit		int
			,@brand				nvarchar(250)
			,@type_unit			nvarchar(250)
			,@product			nvarchar(250)
			,@tahun				int
			,@tenor				int
			,@value_date		datetime
			,@l_r				decimal(9, 6)
			,@roa				decimal(9, 6)
			,@rv				decimal(9, 6)
			,@otr_price			decimal(18, 2)
			,@cost_price		decimal(18, 2)
			,@net_investasi		decimal(18, 2)
			,@rv_amount			decimal(18, 2)
			,@rental_fee		decimal(18, 2)
			,@total_profit		decimal(18, 2)
			,@rent_to_own		nvarchar(5)
			,@unit_condition	nvarchar(10)
			,@skema_maintenance nvarchar(25)
			,@maintenance_cost	decimal(18, 2)
			,@supplier			nvarchar(250)
			,@mo				nvarchar(250)
			,@section			nvarchar(250)
			,@keterangan		nvarchar(4000)
			,@mits				nvarchar(25) ;

	begin try
		
		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2';

		set @report_title = 'Report Open Contract' ;

		--SELECT COUNT(1) FROM 	dbo.agreement_main am
		--		--left join dbo.application_main apm on (apm.application_no = am.application_no)
		--		--inner join dbo.agreement_asset ags on (ags.agreement_no = am.agreement_no)
		--		--inner JOIN dbo.agreement_asset_vehicle aav on (aav.asset_no = ags.asset_no)
		--		--left join dbo.master_vehicle_merk mvm on (mvm.code = aav.vehicle_merk_code)
		--		--left join dbo.master_vehicle_type mvt on (mvt.code = aav.vehicle_type_code)
		--		--outer apply (	select	ast.vendor_name 
		--		--				from	ifinams.dbo.asset ast 
		--		--				where	ast.code = ags.fa_code
		--		--			) ast
  --  --            outer apply (	select	sema.name 'head_mo'
		--		--				from	ifinsys.dbo.sys_employee_main sem
		--		--						inner join ifinsys.dbo.sys_employee_main sema on sema.code = sem.head_emp_code
		--		--				where	sem.code = am.marketing_code
		--		--			) SEM
		--		--outer apply (	select	count(aas.asset_no) 'total_asset'
		--		--				from	dbo.agreement_asset aas
		--		--				where	aas.agreement_no = am.agreement_no
		--		--			) agas
		--		--outer apply (	select	aas.average_asset_amount 'rata_rata_amount'
		--		--				from	dbo.agreement_asset aas
		--		--				where	aas.agreement_no = am.agreement_no
		--		--						and aas.asset_no = ags.asset_no
		--		--			) agre
		--where	am.agreement_status = 'GO LIVE'
		--		and	am.branch_code = case @p_branch_code
		--							when 'ALL' then am.branch_code
		--							else @p_branch_code
		--						end	
		--		and cast(am.agreement_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)

		insert into #rpt_open_contract
		(
			user_id
			,from_date
			,to_date
			,branch_code
			,report_company
			,report_image
			,report_title
			,nomor_skd
			,nomor_kontrak
			,customer
			,total_unit
			,brand
			,type_unit
			,product
			,tahun
			,tenor
			,value_date
			,l_r
			,roa
			,rv
			,otr_price
			,cost_price
			,net_investasi
			,rv_amount
			,rental_fee
			,total_profit
			,rent_to_own
			,unit_condition
			,skema_maintenance
			,maintenance_cost
			,supplier
			,mo
			,section
			,keterangan
			,mits
			,branch_name
			,is_condition
			,AVERAGE_ASSET_AMOUNT
			,is_gts
			,unit_gts
			,tahun_unit_gts
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	DISTINCT @p_user_id
				,@p_from_date
				,@p_to_date
				--,@p_branch_code
				,am.BRANCH_CODE -- rapi 2024-04-03 : perubahan dikarnakan sebelumnya menggunakan parameter jadi tidak termapping sesuai dengan kontraknya
				,@report_company
				,@report_image
				,@report_title
				,ISNULL(apm.application_external_no,am.APPLICATION_NO_EXTERNAL)
				,am.agreement_external_no
				,am.client_name
				,agas.total_asset
				,mvm.description
				,mvt.description
				--,case when isnull(ags.fa_code,'')='' then merk.description
				--		else mvm.description
				--end 
				--,case when isnull(ags.fa_code,'')='' then type.description
				--		else mvt.description
				--end 
				--,case when isnull(ags.fa_code,'')='' then ags.replacement_fa_name
				--		else ags.asset_name
				--end
				,ags.asset_name
				,ags.asset_year
				,am.periode
				,agas.bast_date--ags.handover_bast_date
				,ags.borrowing_interest_rate
				,ags.roa_pct
				,ags.asset_rv_pct
				,ags.market_value + ags.karoseri_amount  + ags.accessories_amount + ags.mobilization_amount
				,ags.asset_amount
				,ags.asset_amount
				,ags.asset_rv_amount
				,ags.lease_rounded_amount
				,ags.yearly_profit_amount
				,case ags.is_purchase_requirement_after_lease
					when '1' then 'COP'
					else 'NON COP'
				end
				,ags.asset_condition
				,case ags.is_use_maintenance
					 when '1' then 'Yes'
					 else 'No'
				 end
				,ags.budget_maintenance_amount
				,ast.vendor_name
				,am.marketing_name
				,sem.head_mo
				,apm.application_remarks
				,case when aav.vehicle_merk_code = 'MITSUBISHI' THEN 'YES' ELSE 'NON' end
				,am.branch_name -- rapi 2024-04-03 : perubahan dikarnakan sebelumnya menggunakan parameter jadi tidak termapping sesuai dengan kontraknya
				--,@p_branch_name
				,@p_is_condition
				,agre.rata_rata_amount
				,case when isnull(ags.replacement_fa_code,'')<>'' then 'YES'
						else 'NO'
				end
                ,ags.replacement_fa_name
				,av.built_year
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main am
				left join dbo.application_main apm on (apm.application_no = am.application_no)
				--LEFT JOIN dbo.application_asset aast ON aast.APPLICATION_NO = apm.APPLICATION_NO
				inner join dbo.agreement_asset ags on (ags.agreement_no = am.agreement_no)
				--outer apply(	select	sum(ags.lease_rounded_amount) 'lease_rounded_amount'
				--				from	dbo.agreement_asset ags 
				--				where	ags.agreement_no = am.agreement_no
				--			) agss
				inner JOIN dbo.agreement_asset_vehicle aav on (aav.asset_no = ags.asset_no)
							 
				left join dbo.master_vehicle_merk mvm on (mvm.code = aav.vehicle_merk_code)
				left join dbo.master_vehicle_type mvt on (mvt.code = aav.vehicle_type_code)
				outer apply (	select	ast.vendor_name 
								from	ifinams.dbo.asset ast 
								where	ast.code = ags.fa_code
							) ast
                outer apply (	select	sema.name 'head_mo'
								from	ifinsys.dbo.sys_employee_main sem
										inner join ifinsys.dbo.sys_employee_main sema on sema.code = sem.head_emp_code
								where	sem.code = am.marketing_code
							) SEM
				outer apply (	select	count(aas.asset_no) 'total_asset'
										,max(aas.handover_bast_date) 'bast_date'
								from	dbo.agreement_asset aas
								where	aas.agreement_no = am.agreement_no
							) agas
				outer apply (	select	aas.average_asset_amount 'rata_rata_amount'
								from	dbo.agreement_asset aas
								where	aas.agreement_no = am.agreement_no
										and aas.asset_no = ags.asset_no
							) agre
				outer apply (	select	merk_code, type_code_asset 
								from	ifinams.dbo.asset asst
								where	asst.agreement_no = ags.agreement_no
								and		asst.asset_no = ags.asset_no
							) ams
				outer apply (	select	ty.description 'description'
								from	dbo.master_vehicle_type ty
								where	ty.code = ams.type_code_asset
							) type
				outer apply (	SELECT	mer.description 'description'
								from	dbo.master_vehicle_merk mer
								where	mer.code = ams.merk_code
							) merk
				outer apply (	select	ave.built_year
								from	ifinams.dbo.asset_vehicle ave
								where	ave.asset_code = ags.replacement_fa_code
							) av
		where	
				--am.agreement_status = 'GO LIVE' --(+) Raffy 2024/04/05 request MO agar report menampilkan semua agreement yang go live nya diperiode terpilih 
				--and	
				am.branch_code = case @p_branch_code
									when 'ALL' then am.branch_code
									else @p_branch_code
								end	
				and cast(am.agreement_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)
		
		if not exists (select 1 from #rpt_open_contract where user_id = @p_user_id)
		begin
				insert into #rpt_open_contract
				(
				    user_id
				    ,from_date
				    ,to_date
				    ,branch_code
				    ,report_company
				    ,report_image
				    ,report_title
				    ,nomor_skd
				    ,nomor_kontrak
				    ,customer
				    ,total_unit
				    ,brand
				    ,type_unit
				    ,product
				    ,tahun
				    ,tenor
				    ,value_date
				    ,l_r
				    ,roa
				    ,rv
				    ,otr_price
				    ,cost_price
				    ,net_investasi
				    ,rv_amount
				    ,rental_fee
				    ,total_profit
				    ,rent_to_own
				    ,unit_condition
				    ,skema_maintenance
				    ,maintenance_cost
				    ,supplier
				    ,mo
				    ,section
				    ,keterangan
				    ,mits
				    ,branch_name
				    ,is_condition
				    ,cre_date
				    ,cre_by
				    ,cre_ip_address
				    ,mod_date
				    ,mod_by
				    ,mod_ip_address
				)
				values
				(   
					@p_user_id
				    ,@p_from_date
				    ,@p_to_date
				    ,@p_branch_code
				    ,@report_company
				    ,@report_image
				    ,@report_title
				    ,''
				    ,''
				    ,''
				    ,null
				    ,''
				    ,''
				    ,''
				    ,''
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
				    ,''
				    ,''
				    ,''
				    ,null
				    ,''
				    ,''
				    ,''
				    ,''
				    ,''
				    ,@p_branch_name
				    ,@p_is_condition
				    ,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				)
		end

		insert into dbo.rpt_open_contract
		(
		    user_id,
		    from_date,
		    to_date,
		    branch_code,
		    report_company,
		    report_image,
		    report_title,
		    nomor_skd,
		    nomor_kontrak,
		    customer,
		    total_unit,
		    brand,
		    type_unit,
		    product,
		    tahun,
		    tenor,
		    value_date,
		    l_r,
		    roa,
		    rv,
		    otr_price,
		    cost_price,
		    net_investasi,
		    rv_amount,
		    rental_fee,
		    total_profit,
		    rent_to_own,
		    unit_condition,
		    skema_maintenance,
		    maintenance_cost,
		    supplier,
		    mo,
		    section,
		    keterangan,
		    mits,
		    branch_name,
		    average_asset_amount,
		    is_condition,
			is_gts,
			unit_gts,
			tahun_unit_gts,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		select user_id
               ,from_date
               ,to_date
               ,branch_code
               ,report_company
               ,report_image
               ,report_title
               ,nomor_skd
               ,nomor_kontrak
               ,customer
               ,sum(total_unit)
               ,brand
               ,type_unit
               ,product
               ,tahun
               ,isnull(max(tenor),0)
               ,isnull(max(value_date),0)
               ,isnull(max(l_r),0)
               ,isnull(max(roa),0)
               ,isnull(max(rv),0)
               ,isnull(max(otr_price),0)
               ,isnull(sum(cost_price),0)
               ,isnull(sum(net_investasi),0)
               ,isnull(sum(rv_amount),0)
               ,isnull(max(rental_fee),0)
               ,isnull(max(total_profit),0)
               ,rent_to_own
               ,unit_condition
               ,skema_maintenance
               ,isnull(sum(maintenance_cost),0)
               ,supplier
               ,mo
               ,section
               ,keterangan
               ,mits
               ,branch_name
               ,isnull(sum(average_asset_amount),0)
               ,is_condition
			   ,is_gts
			   ,unit_gts
			   ,tahun_unit_gts
               ,cre_date
               ,cre_by
               ,cre_ip_address
               ,mod_date
               ,mod_by
               ,mod_ip_address 
		from #rpt_open_contract
		group by	user_id
				   ,from_date
				   ,to_date
				   ,branch_code
				   ,report_company
				   ,report_image
				   ,report_title
				   ,nomor_skd
				   ,nomor_kontrak
				   ,customer
				   ,brand
				   ,type_unit
				   ,product
				   ,tahun
				   ,rent_to_own
				   ,unit_condition
				   ,skema_maintenance
				   ,supplier
				   ,mo
				   ,section
				   ,keterangan
				   ,mits
				   ,branch_name
				   ,is_condition
				   ,is_gts
				   ,unit_gts
				   ,tahun_unit_gts
				   ,cre_date
				   ,cre_by
				   ,cre_ip_address
				   ,mod_date
				   ,mod_by
				   ,mod_ip_address 
		drop table #rpt_open_contract ;
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
