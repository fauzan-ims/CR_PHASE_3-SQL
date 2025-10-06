CREATE PROCEDURE dbo.xsp_rpt_asset_new
(
	@p_user_id			nvarchar(50)
	,@p_branch_code		NVARCHAR(50)
	,@p_branch_name		nvarchar(50)
	,@p_from_date		datetime	
	,@p_to_date			datetime	
    ,@p_is_condition    NVARCHAR(1)
)
as
BEGIN

	delete dbo.rpt_asset
	where	user_id = @p_user_id ;

	declare @msg							nvarchar(max)
			,@report_company				nvarchar(250)
			,@report_title					nvarchar(250)
			,@report_image					nvarchar(250)	
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(50)
			,@plat_no						nvarchar(50)
			,@brand							nvarchar(50)
			,@product_category				nvarchar(50)
			,@vehicle_ype					nvarchar(50)
			,@chassis_no					nvarchar(50)
			,@engine_no						nvarchar(50)
			,@yeardate						nvarchar(50)
			,@color							nvarchar(50)
			,@mileage						int
			,@lessee						nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@beginning_period				datetime
			,@ending_period					nvarchar(50)
			,@period						int
			,@status						nvarchar(50)
			,@aging							int
			,@province						nvarchar(50)
			,@city							nvarchar(50)
			,@parking_location				nvarchar(50)
			,@contract_status				nvarchar(50)
			,@stnk_date						datetime
			,@keur							datetime
			,@color_plat					nvarchar(50)
			,@insurance_polis				nvarchar(50)
			,@insurance_company				nvarchar(50)
			,@start_date					datetime
			,@end_date						datetime
			,@supplier						nvarchar(50)
			,@maintenance_scheme			nvarchar(50)
			,@cop_non_cop					nvarchar(50)
			,@ni							nvarchar(50)
			,@registration_budget			decimal(18, 2)
			,@maintenance_budget			decimal(18, 2)
			,@replacement_budget			decimal(18, 2)
			,@insurance_cost				decimal(18, 2)
			,@mobilization_cost				decimal(18, 2)
			,@marketing_officer				nvarchar(50)
			,@remark						NVARCHAR(4000)
	


	DECLARE @temptable table
    ( branch_code			nvarchar(50)
	  ,branch_name			nvarchar(250)
	  ,from_date			DATETIME
	  ,to_date				DATETIME
	  ,plat_no				nvarchar(50)
	  ,brand				nvarchar(250)
	  ,product_category		nvarchar(4000)
	  ,vehicle_ype			nvarchar(250)
	  ,chassis_no			nvarchar(50)
	  ,engine_no			nvarchar(50)
	  ,year_item			NVARCHAR(4)
	  ,color				nvarchar(50)
	  ,mileage				nvarchar(50)
	  ,lessee				NVARCHAR(250)
	  ,agreement_no			nvarchar(50)
	  ,beginning_period		DATETIME
	  ,ending_period		DATETIME
	  ,period				int
	  ,status				nvarchar(50)
	  ,aging				int
	  ,province				nvarchar(250)
	  ,city					nvarchar(250)
	  ,parking_location		NVARCHAR(250)
	  ,contract_status		NVARCHAR(50)
	  ,stnk_date			DATETIME
	  ,keur					DATETIME
	  ,color_plat			nvarchar(50)
	  ,insurance_polis		NVARCHAR(50)
	  ,insurance_company	NVARCHAR(250)
	  ,start_date			DATETIME
	  ,end_date				DATETIME
	  ,supplier				nvarchar(250)
	  ,maintenance_scheme	nvarchar(50)
	  ,cop_non_cop			NVARCHAR(50)
	  ,ni					decimal(18,2)
	  ,registration_budget	decimal(18,2)
	  ,maintenance_budget	decimal(18,2)
	  ,replacement_budget	decimal(18,2)
	  ,insurance_cost		DECIMAL(18,2)
	  ,mobilization_cost	DECIMAL(18,2)
	  ,marketing_officer	NVARCHAR(250)
	  ,remark				NVARCHAR(4000)
	  ,IS_CONDITION			NVARCHAR(5)
	  ,asset_code			NVARCHAR(50)
	  )




	begin try
	
		SELECT	@report_company = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'COMP2' ;

		set	@report_title = 'Report Asset';

		select	@report_image = value
		from	dbo.SYS_GLOBAL_PARAM
		where	CODE = 'IMGDSF' ;

	BEGIN

	INSERT INTO @temptable
	(
	    branch_code,
	    branch_name,
	    from_date,
	    to_date,
	    plat_no,
	    brand,
	    product_category,
	    vehicle_ype,
	    chassis_no,
	    engine_no,
	    year_item,
	    color,
	    mileage,
	    lessee,
	    agreement_no,
	    beginning_period,
	    ending_period,
	    period,
	    status,
	    aging,
	    province,
	    city,
	    parking_location,
	    contract_status,
	    stnk_date,
	    keur,
	    color_plat,
	    insurance_polis,
	    insurance_company,
	    start_date,
	    end_date,
	    supplier,
	    maintenance_scheme,
	    cop_non_cop,
	    ni,
	    registration_budget,
	    maintenance_budget,
	    replacement_budget,
	    insurance_cost,
	    mobilization_cost,
	    marketing_officer,
	    remark,
	    IS_CONDITION,
	    asset_code
	)
			SELECT	DISTINCT	@p_branch_code
								,ass.branch_name
								,@p_from_date
								,@p_to_date
								,av.plat_no
								,ass.merk_name
								,sgs4.description --product
								,ass.item_name
								,av.chassis_no
								,av.engine_no
								,YEAR(ass.purchase_date)
								,av.colour
								,ass.use_life --milliage
								,ass.client_name -- lesse
								,ass.agreement_external_no
								,agset.handover_bast_date--aman.agreement_date
								,maxdate.maxdate
								,period.maxdate -- period
								,CASE 
									WHEN ass.RENTAL_STATUS='IN USE' AND ass.status='STOCK' THEN 'ACTIVE'
									ELSE NULL
								END--status
								,DATEDIFF(DAY, CAST(aman.agreement_date AS DATE), CAST(dbo.xfn_get_system_date() AS DATE))
								,ass.unit_province_name --province
								,ass.unit_city_name --city
								,ass.parking_location --parkingloc
								,CASE
									 WHEN ISNULL(aman.agreement_sub_status, '') = '' THEN aman.agreement_status
									 ELSE aman.agreement_status + ' - ' + aman.agreement_sub_status
								 END 'agreement_status'
								,av.stnk_expired_date --stnk_date
								,av.keur_expired_date --keur
								,aman.plat_colour --colorplat
								,pol.policy_no --insurancepolis
								,pol.insurance_name --insurancecomp
								,pol.policy_eff_date --startdate
								,pol.policy_exp_date --enddate
								,ass.vendor_name --supplier
								,case budget.is_maintenance
									 when 1 then 'WITH MAINTENANCE'
									 else 'WITHOUT MAINTENANCE'
								 end 'maintenance' --maintenance
								,case aman.is_purchase_requirement_after_lease
									 when 1 then 'COP'
									 else 'NON COP'
								 end 'COP'
								,ass.net_book_value_comm+ass.residual_value
								,registration.registration_amount --
								--,maintenance.maintenance_amount --
								,budget.Maintenance_amount --(+) Raffy 22/04/2024 perubahan pengambilan amount budget maintenance
								,replacement.replacement_amount --
								,insurance.insurance_amount --
								,aman.mobilization_amount
								,aman.marketing_name
								,ass.remarks --remark
								,@p_is_condition
								,ass.code
			from	ifinams.dbo.asset ass
					left join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code)
					--left join ifinopl.dbo.agreement_main aman on (aman.agreement_no = ass.agreement_no)
					--left join ifinopl.dbo.application_asset apss on (apss.fa_code = ass.code and aman.application_no = apss.application_no)
					left join ifinbam.dbo.master_item mim on (mim.code = ass.item_code)
					left join ifinbam.dbo.sys_general_subcode sgs4 on (sgs4.code = mim.registration_class_type)
					OUTER APPLY
						(
							select	am.AGREEMENT_NO, am.marketing_name, am.is_purchase_requirement_after_lease, am.agreement_status, am.agreement_sub_status, am.agreement_date, aps.plat_colour, aps.mobilization_amount
							from	ifinopl.dbo.agreement_main am
							inner join ifinopl.dbo.application_asset aps on am.application_no = aps.application_no
							where	am.agreement_no = ass.agreement_no and aps.fa_code = ass.code
						)aman
					--OUTER APPLY
					--	(
					--		SELECT	aps.PLAT_COLOUR, aps.MOBILIZATION_AMOUNT
					--		FROM	ifinopl.dbo.application_asset aps 
					--		WHERE	aps.fa_code = ass.code 
					--		AND		aman.application_no = aps.application_no
					--	) apss
					outer apply
						(
							select	budget_amount 'replacement_amount'
							from	ifinopl.dbo.application_asset_budget asd
							where	asset_no	  = ass.asset_no
									and cost_code = 'MBDC.2208.000001'
						) replacement
					outer apply
						(
							select	budget_amount 'registration_amount'
							from	ifinopl.dbo.application_asset_budget asd1
							where	asset_no	  = ass.asset_no
									and cost_code = 'MBDC.2301.000001'
						) registration
					outer apply
						(
							select	budget_amount 'maintenance_amount'
							from	ifinopl.dbo.application_asset_budget asd1
							where	asset_no	  = ass.asset_no
									and cost_code = 'MBDC.2211.000003'
						) maintenance
					outer apply 
						(
						select	ast.budget_maintenance_amount 'Maintenance_amount'
								,ast.is_use_maintenance 'is_maintenance'
						from	ifinopl.dbo.agreement_asset ast
						where	ast.agreement_no = aman.agreement_no
						and		ass.code	= ast.fa_code
						) budget
					outer apply
						(
							select	budget_amount 'insurance_amount'
							from	ifinopl.dbo.application_asset_budget asd1
							where	asset_no	  = ass.asset_no
									and cost_code = 'MBDC.2211.000001'
						) insurance
					--outer apply
					--	(
					--		select max(DUE_DATE) 'maxdate'
					--		from ifinopl.dbo.AGREEMENT_ASSET_AMORTIZATION
					--		where AGREEMENT_NO = aman.AGREEMENT_NO
					--		and ASSET_NO = ass.ASSET_NO
					--	) maxdate
					outer apply
					(
						select MATURITY_DATE 'maxdate'
						from ifinopl.dbo.AGREEMENT_INFORMATION 
						where AGREEMENT_NO = aman.AGREEMENT_NO
						--and ASSET_NO = ass.ASSET_NO
					) maxdate
					outer apply
						(
							select max(BILLING_NO) 'maxdate'
							from ifinopl.dbo.AGREEMENT_ASSET_AMORTIZATION
							where AGREEMENT_NO = aman.AGREEMENT_NO
							and ASSET_NO = ass.ASSET_NO
						) period
					outer apply 
						( 
						select top 1 ipm.policy_eff_date, ipm.policy_exp_date, ipm.policy_no, mi.insurance_name
						from dbo.insurance_policy_main ipm
						inner join ifinams.dbo.master_insurance mi on (mi.code = ipm.insurance_code)
						inner join ifinams.dbo.insurance_policy_asset ipa on ipa.fa_code = ass.code
						where ipm.code = ipa.policy_code
						and ipa.fa_code = ass.code
						and mi.code = ipm.insurance_code
						and ipm.policy_status = 'ACTIVE'
						and ipm.policy_eff_date <= dbo.xfn_get_system_date()
						order by ipm.policy_eff_date desc
						) pol
					outer apply
						(
						select top 1 ags.handover_bast_date 
						from ifinopl.dbo.agreement_asset ags
						where ags.agreement_no = aman.agreement_no
						--and		ags.fa_code		= ass.code
						) agset
			where	ass.branch_code = case @p_branch_code
										  when 'ALL' then ass.branch_code
										  else @p_branch_code
									  end
                    and ass.status <> 'CANCEL'
					and cast(ass.purchase_date as date)
					between cast(@p_from_date as date) and cast(@p_to_date as date) 
					--and isnull(pol.policy_no,'')<>'';

			INSERT INTO dbo.RPT_ASSET
			(
			    USER_ID,
			    REPORT_COMPANY,
			    REPORT_TITLE,
			    REPORT_IMAGE,
			    FILTER_BRANCH_NAME,
			    BRANCH_CODE,
			    BRANCH_NAME,
			    FROM_DATE,
			    TO_DATE,
			    PLAT_NO,
			    BRAND,
			    PRODUCT_CATEGORY,
			    VEHICLE_YPE,
			    CHASSIS_NO,
			    ENGINE_NO,
			    YEAR_ITEM,
			    COLOR,
			    MILEAGE,
			    LESSEE,
			    AGREEMENT_NO,
			    BEGINNING_PERIOD,
			    ENDING_PERIOD,
			    PERIOD,
			    STATUS,
			    AGING,
			    PROVINCE,
			    CITY,
			    PARKING_LOCATION,
			    CONTRACT_STATUS,
			    STNK_DATE,
			    KEUR,
			    COLOR_PLAT,
			    INSURANCE_POLIS,
			    INSURANCE_COMPANY,
			    START_DATE,
			    END_DATE,
			    SUPPLIER,
			    MAINTENANCE_SCHEME,
			    COP_NON_COP,
			    NI,
			    REGISTRATION_BUDGET,
			    MAINTENANCE_BUDGET,
			    REPLACEMENT_BUDGET,
			    INSURANCE_COST,
			    MOBILIZATION_COST,
			    MARKETING_OFFICER,
			    REMARK,
			    IS_CONDITION,
			    ASSET_CODE
			)
			SELECT	
					@p_user_id
					,@report_company
					,@report_title
					,@report_image
					,@p_branch_name -- FILTER_BRANCH_NAME - nvarchar(250)
					,branch_code,
                    branch_name,
                    from_date,
                    to_date,
                    plat_no,
                    brand,
                    product_category,
                    vehicle_ype,
                    chassis_no,
                    engine_no,
                    year_item,
                    color,
                    mileage,
                    lessee,
                    agreement_no,
                    beginning_period,
                    ending_period,
                    period,
                    status,
                    aging,
                    province,
                    city,
                    parking_location,
                    contract_status,
                    stnk_date,
                    keur,
                    color_plat,
                    insurance_polis,
                    insurance_company,
                    start_date,
                    end_date,
                    supplier,
                    maintenance_scheme,
                    cop_non_cop,
                    ni,
                    registration_budget,
                    maintenance_budget,
                    replacement_budget,
                    insurance_cost,
                    mobilization_cost,
                    marketing_officer,
                    remark,
                    IS_CONDITION,
                    asset_code  		   
				 FROM @temptable	

					if not exists (select * from dbo.rpt_asset where user_id = @p_user_id)
					begin
							insert into dbo.rpt_asset
							(
							    user_id
							    ,report_company
							    ,report_title
							    ,report_image
							    ,filter_branch_name
							    ,branch_code
							    ,branch_name
							    ,from_date
							    ,to_date
							    ,plat_no
							    ,brand
							    ,product_category
							    ,vehicle_ype
							    ,chassis_no
							    ,engine_no
							    ,year_item
							    ,color
							    ,mileage
							    ,lessee
							    ,agreement_no
							    ,beginning_period
							    ,ending_period
							    ,period
							    ,status
							    ,aging
							    ,province
							    ,city
							    ,parking_location
							    ,contract_status
							    ,stnk_date
							    ,keur
							    ,color_plat
							    ,insurance_polis
							    ,insurance_company
							    ,start_date
							    ,end_date
							    ,supplier
							    ,maintenance_scheme
							    ,cop_non_cop
							    ,ni
							    ,registration_budget
							    ,maintenance_budget
							    ,replacement_budget
							    ,insurance_cost
							    ,mobilization_cost
							    ,marketing_officer
							    ,remark
							    ,is_condition
								,ASSET_CODE
							)
							values
							(   
								@p_user_id
							    ,@report_company
							    ,@report_title
							    ,@report_image
							    ,@p_branch_name
							    ,@p_branch_code
							    ,null
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
								,NULL
							)
					end
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
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

