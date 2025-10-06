--Created by, Rian at 21/06/2023 

CREATE PROCEDURE [dbo].[xsp_rpt_monthly_sales]
(
	@p_user_id		   nvarchar(50)
	,@p_branch_code	   nvarchar(50)
	,@p_branch_name	   nvarchar(250)
	,@p_month		   nvarchar(20)
	,@p_year		   nvarchar(4)
	,@p_is_condition   nvarchar(1)
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

	delete	dbo.rpt_monthly_sales
	where user_id	= @p_user_id

	declare @msg				nvarchar(max)
			,@report_company	nvarchar(250)
			,@report_image		nvarchar(250)
			,@report_title		nvarchar(250)
			,@branch_code		nvarchar(50)
			,@nomor_skd			nvarchar(50)
			,@nomor_kontrak		nvarchar(50)
			,@customer			nvarchar(250)
			,@total_unit		int
			,@merk				nvarchar(50)
			,@type				nvarchar(250)
			,@product			nvarchar(250)
			,@tahun				nvarchar(4)
			,@tenor				int
			,@value_date		datetime
			,@lr_pct			decimal(9, 6)
			,@roa_pct			decimal(9, 6)
			,@rv_pct			decimal(9, 6)
			,@otr_price			decimal(18, 2)
			,@cost_price		decimal(18, 2)
			,@net_investasi		decimal(18, 2)
			,@rv_amount			decimal(18, 2)
			,@rental_fee		decimal(18, 2)
			,@total_profit		decimal(18, 2)
			,@rent_to_own		nvarchar(10)
			,@condition			nvarchar(10)
			,@skema_maintenance nvarchar(25)
			,@maintenance_cost	decimal(18, 2)
			,@supplier			nvarchar(250)
			,@mo				nvarchar(250)
			,@section			nvarchar(250)
			,@keterangan		nvarchar(4000)
			,@mits				nvarchar(250) 
			,@month				int
            ,@branch_name		nvarchar(250)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value 
		from	dbo.sys_global_param
		where	code = 'COMP2'

		set @report_title = 'Monthly Sales Report' ;

		if @p_month = 'Januari'
			set @month = 1
		else if @p_month = 'Februari'
			set @month = 2
		else if @p_month = 'Maret'
			set @month = 3
		else if @p_month = 'April'
			set @month = 4
		else if @p_month = 'Mei'
			set @month = 5
		else if @p_month = 'Juni'
			set @month = 6
		else if @p_month = 'Juli'
			set @month = 7
		else if @p_month = 'Agustus'
			set @month = 8
		else if @p_month = 'September'
			set @month = 9
		else if @p_month = 'Oktober'
			set @month = 10
		else if @p_month = 'November'
			set @month = 11
		else if @p_month = 'Desember'
			set @month = 12

		insert into dbo.rpt_monthly_sales
		(
			user_id
			,month
			,year
			,report_company
			,report_image
			,report_title
			,nomor_skd
			,nomor_kontrak
			,customer
			,total_unit
			,merk
			,type
			,product
			,tahun
			,tenor
			,value_date
			,lr_pct
			,roa_pct
			,rv_pct
			,otr_price
			,cost_price
			,net_investasi
			,rv_amount
			,rental_fee
			,total_profit
			,rent_to_own
			,condition
			,skema_maintenance
			,maintenance_cost
			,supplier
			,mo
			,section
			,keterangan
			,mits
			,BRANCH_CODE
			,BRANCH_NAME
			,IS_CONDITION
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@p_month
				,@p_year
				,@report_company
				,@report_image
				,@report_title
				,apm.application_external_no
				,am.agreement_external_no
				,am.client_name
				,agas.total_asset
				,mvm.description
				,mvt.description
				,ags.asset_name
				,ags.asset_year
				,am.periode
				,am.agreement_date
				,ags.borrowing_interest_rate
				,ags.roa_pct
				,ags.asset_rv_pct
				,ags.market_value + ags.karoseri_amount  + ags.accessories_amount + ags.mobilization_amount
				,ags.asset_amount
				,ags.asset_amount
				,ags.asset_rv_amount
				,ags.lease_rounded_amount
				,isnull(ags.yearly_profit_amount * ceiling(am.periode/12),0)
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
				,@p_branch_code
				,@p_branch_name
				,@p_is_condition
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main am
				left join dbo.application_main apm on (apm.application_no = am.application_no)
				outer apply(	select	top 1 *
								from	dbo.agreement_asset ags 
								where	ags.agreement_no = am.agreement_no
							) ags
				outer apply(	select	sum(ags.lease_rounded_amount) 'lease_rounded_amount'
								from	dbo.agreement_asset ags 
								where	ags.agreement_no = am.agreement_no
							) agss
				outer apply(	select	top 1 *
								from	dbo.agreement_asset_vehicle aav
								where	aav.asset_no = ags.asset_no
							)aav
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
								from	dbo.agreement_asset aas
								where	aas.agreement_no = am.agreement_no
							) agas
		--from	dbo.agreement_main am
		--		left join dbo.application_main apm on (apm.agreement_no = am.agreement_no)
		--		left join dbo.agreement_asset ags on (ags.agreement_no = am.agreement_no)
		--		left join dbo.agreement_asset_vehicle aav on (aav.asset_no = ags.asset_no)
		--		left join dbo.master_vehicle_merk mvm on (mvm.code = aav.vehicle_merk_code)
		--		left join dbo.master_vehicle_type mvt on (mvt.code = aav.vehicle_type_code)
		--		outer apply
		--(
		--	select	count(aas.asset_no) 'total_asset'
		--	from	dbo.agreement_asset aas
		--	where	aas.agreement_no = am.agreement_no
		--) agas
		where	am.agreement_status = 'GO LIVE'
				and am.branch_code	= case @p_branch_code
										  when 'ALL' then am.branch_code
										  else @p_branch_code
									  end
				and month(am.agreement_date) = @month
				and year(am.agreement_date)	= @p_year

		if not exists (select * from dbo.rpt_monthly_sales where user_id = @p_user_id)
		begin
				insert into dbo.rpt_monthly_sales
				(
				    user_id
				    ,year
				    ,month
				    ,report_company
				    ,report_image
				    ,report_title
				    ,nomor_skd
				    ,nomor_kontrak
				    ,customer
				    ,total_unit
				    ,merk
				    ,type
				    ,product
				    ,tahun
				    ,tenor
				    ,value_date
				    ,lr_pct
				    ,roa_pct
				    ,rv_pct
				    ,otr_price
				    ,cost_price
				    ,net_investasi
				    ,rv_amount
				    ,rental_fee
				    ,total_profit
				    ,rent_to_own
				    ,condition
				    ,skema_maintenance
				    ,maintenance_cost
				    ,supplier
				    ,mo
				    ,section
				    ,keterangan
				    ,mits
				    ,branch_code
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
				    ,@p_year
				    ,@p_month
				    ,@report_company
				    ,@report_image
				    ,@report_title
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
				    ,@p_branch_code
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
