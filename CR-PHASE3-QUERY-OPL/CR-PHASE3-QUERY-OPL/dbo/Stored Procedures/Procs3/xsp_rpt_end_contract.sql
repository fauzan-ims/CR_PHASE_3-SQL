--created by, Rian at 21/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_end_contract
(
	@p_user_id			nvarchar(max)
	,@p_from_date		datetime
	,@p_to_date			datetime
	,@p_branch_code		nvarchar(50)
	,@p_branch_name		nvarchar(250)
	,@p_is_condition	nvarchar(1)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin

	delete	dbo.rpt_end_contract
	where user_id	= @p_user_id

	declare	@msg					nvarchar(max)
			,@report_company		nvarchar(250)
			,@report_image			nvarchar(250)
			,@report_title			nvarchar(250)
			,@customer				nvarchar(250)
			,@nomor_kontrak			nvarchar(50)
			,@asset_no				nvarchar(50)
			,@plat_no				nvarchar(50)
			,@merk					nvarchar(50)
			,@type					nvarchar(250)
			,@product				nvarchar(50)
			,@asset_year			nvarchar(4)
			,@contract_end_date		datetime
			,@rv_amount				decimal(18,2)
			,@branch_name			nvarchar(250)

	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'Report End Contract'

		insert into dbo.rpt_end_contract
		(
			user_id
			,report_company
			,report_image
			,report_title
			,from_date
			,to_date
			,customer
			,nomor_kontrak
			,asset_no
			,plat_no
			,merk
			,type
			,product
			,asset_year
			,contract_end_date
			,contract_agreement_date
			,rv_amount
			,branch_code
			,branch_name
			,is_condition
			,last_status
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company
				,@report_image
				,@report_title
				,@p_from_date
				,@p_to_date
				,am.client_name
				,am.agreement_external_no
				,aa.asset_no
				,left(aa.fa_reff_no_01,10)
				,case aa.asset_type_code 
					when 'VHCL' then vhclm.description
					else aa.asset_type_code
				end
				,aa.asset_name
				--case aa.asset_type_code 
				--when 'VHCL' then vhclt.description
				--else aa.asset_type_code
				--end
				,sgs.description
				--case aa.asset_type_code 
				--	when 'VHCL' then vhclc.description
				--	else aa.asset_type_code
				--end
				,aa.asset_year
				--,agass.due_date
				,am.termination_date
				,agi.maturity_date
				,aa.asset_rv_amount 
				,@p_branch_code
				,@p_branch_name
				,@p_is_condition
				,am.termination_status
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.agreement_main am 
				left join dbo.agreement_asset aa on (aa.agreement_no = am.agreement_no)
				left join dbo.agreement_asset_vehicle aav on (aav.asset_no = aa.asset_no)
				left join dbo.agreement_information agi on (agi.agreement_no = am.agreement_no)
				left join ifinams.dbo.asset ass on (ass.asset_no = aa.asset_no)
				left join ifinbam.dbo.master_item mi on (mi.code = ass.item_code)
				left join ifinbam.dbo.sys_general_subcode sgs on (sgs.code = mi.class_type_code)
				outer apply (
								select	mvc.description
								from	dbo.application_asset_vehicle aav
										left join dbo.master_vehicle_category mvc on (mvc.code = aav.vehicle_category_code)
								where	aa.asset_no = aav.asset_no
							)vhclc
				outer apply (
								select	mvm.description
								from	dbo.application_asset_vehicle aav
										left join dbo.master_vehicle_merk mvm on (mvm.code = aav.vehicle_merk_code)
								where	aa.asset_no = aav.asset_no
							)vhclm
				outer apply (
								select	mvt.description
								from	dbo.application_asset_vehicle aav
										left join dbo.master_vehicle_type mvt on (mvt.code = aav.vehicle_unit_code)
								where	aa.asset_no = aav.asset_no
							)vhclt
				outer apply(
								select	max(aaam.due_date) 'due_date'
								from	agreement_asset_amortization aaam
								where	aaam.asset_no		  = aa.asset_no
										and aaam.agreement_no = aa.agreement_no
							)agass
		where	am.branch_code = case @p_branch_code
									when 'ALL' then am.branch_code
									else @p_branch_code
								end	
				and cast(agi.maturity_date as date) between cast(@p_from_date as date) and cast(@p_to_date as date)

		if not exists (select * from dbo.rpt_end_contract where user_id = @p_user_id)
		begin
				insert into dbo.rpt_end_contract
				(
				    user_id
				    ,report_company
				    ,report_image
				    ,report_title
				    ,from_date
					,to_date
				    ,customer
				    ,nomor_kontrak
				    ,asset_no
				    ,plat_no
				    ,merk
				    ,type
				    ,product
				    ,asset_year
				    ,contract_end_date
				    ,rv_amount
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
				    ,@report_company
				    ,@report_image
				    ,@report_title
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

	--	values
	--	(	
	--		@p_user_id
	--		,@report_image		
	--		,@report_title	
	--		,@p_as_of_date	
	--		,@customer			
	--		,@nomor_kontrak		
	--		,@asset_no			
	--		,@plat_no			
	--		,@merk				
	--		,@type				
	--		,@product			
	--		,@asset_year		
	--		,@contract_end_date	
	--		,@rv_amount		
	--		--
	--		,@p_cre_date		
	--		,@p_cre_by			
	--		,@p_cre_ip_address	
	--		,@p_mod_date		
	--		,@p_mod_by			
	--		,@p_mod_ip_address		
	--	) 
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
END
