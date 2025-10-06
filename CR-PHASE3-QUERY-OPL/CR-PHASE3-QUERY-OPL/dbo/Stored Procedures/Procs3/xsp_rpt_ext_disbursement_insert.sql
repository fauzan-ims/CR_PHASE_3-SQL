CREATE PROCEDURE dbo.xsp_rpt_ext_disbursement_insert

as
begin
	declare @code					nvarchar(50)
			,@year					nvarchar(4)
			,@month					nvarchar(2)
			,@msg					nvarchar(max) 
			,@system_date			datetime
            --,@p_cre_date			datetime = '2023-12-31'
            ,@p_cre_date			datetime = dbo.xfn_get_system_date()
			,@p_cre_by				nvarchar(15) = 'JOB'
			,@p_cre_ip_address		nvarchar(15) = 'JOB'


	if(@p_cre_date < eomonth(@p_cre_date)) -- (+) Ari 2024-02-05 ket : get last eom
	begin
		set @p_cre_date = dateadd(month, -1, @p_cre_date)
		set @p_cre_date = eomonth(@p_cre_date)
	end

	begin try
		
		set @system_date = dbo.xfn_get_system_date()
		--set @year = cast(datepart(year, @system_date) as nvarchar)
		--set @month = replace(str(cast(datepart(month, @system_date) as nvarchar), 2, 0), ' ', '0') ;

		set @year = cast(datepart(year, @p_cre_date) as nvarchar)
		set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

		delete dbo.rpt_ext_disbursement

		insert into rpt_ext_disbursement
		(
			year
			,month
			,contract_no
			,skdno
			,officeid
			,regional
			,branch
			,brand_category
			,asset_brand_id
			,brand
			,asset_condition
			,asset_category
			,asset_type_id
			,asset_type
			,asset_model
			,asset_model_name
			,modeltypeid
			,modeltypename
			,economicsectorid
			,disburse_date
			,businees_type
			,finance_type
			,purpose_of_finance
			,way_of_finance
			,campaign
			,campaign_type
			,tenor
			,payment_method_id
			,payment_method
			,supplier_group_id
			,group_of_supplier_company
			,supplier_id
			,supplier_company
			,currency
			,mo_name
			,mo_id
			,business_sub_category
			,payment_mode
			,insurance_type_id
			,insurance_type
			,insurance_coverage
			,supplier_company_branch
			,supplier_location
			,payment_type_id
			,payment_type
			,repeat_or_new
			,customer_id
			,customer_name
			,ni
			,interest_rate
			,cost_price
			,accounting_book_date
			---- raffy (+) 2025/08/06 imon 2508000017
			,fa_code
			,registration_class_type
			,asset_name
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	cast(datepart(year, agm.agreement_date) as nvarchar)
				,replace(str(cast(datepart(month, agm.agreement_date) as nvarchar), 2, 0), ' ', '0')
				,agm.agreement_external_no
				,agm.application_no
				,right(agm.branch_code,2)
				,sr.DESCRIPTION
				,agm.branch_name
				,case mvm.DESCRIPTION when 'MITSUBISHI' then 'MITSUBISHI' else 'NON MITSUBISHI' end
				,asv.VEHICLE_MERK_CODE
				,mvm.DESCRIPTION--case mvm.DESCRIPTION when 'MITSUBISHI' then 'MITSUBISHI' else 'NON MITSUBISHI' end
				,ags.ASSET_CONDITION
				,sgs.description
				,case ags.ASSET_TYPE_CODE 
					when 'VHCL' then '1'
					when 'HE' then '2'
					else 'NA'
				end
				,case ags.ASSET_TYPE_CODE 
					when 'VHCL' then 'VEHICLE'
					when 'HE' then 'HE'
					else 'NA'
				end
				--,right(asv.VEHICLE_type_CODE, len(asv.VEHICLE_type_CODE)-1-len(asv.VEHICLE_MODEL_CODE))
				,substring(substring(asv.VEHICLE_type_CODE,CHARINDEX('.', asv.VEHICLE_type_CODE)+1,len(asv.VEHICLE_type_CODE)),CHARINDEX('.', substring(asv.VEHICLE_type_CODE,CHARINDEX('.', asv.VEHICLE_type_CODE)+1,len(asv.VEHICLE_type_CODE)))+1,len(substring(asv.VEHICLE_type_CODE,CHARINDEX('.', asv.VEHICLE_type_CODE)+1,len(asv.VEHICLE_type_CODE)))) -- (+) Ari 2024-03-06 ket : diganti query dari pak ari dwh
				,ags.ASSET_NAME
				,asv.VEHICLE_MODEL_CODE
				,model.DESCRIPTION
				,null --economic_sector_code
				,agm.agreement_date --dishbursement
				,null --@p_bussiness_type_name
				,'OPL'
				,NULL --@p_purpose_of_finance
				,NULL --@p_way_of_financing_name	
				,'N' --@p_champaign_code	
				,'STD' --@p_type_of_package	
				,agm.periode
				,'3'--@p_payment_methode_id
				,'TRANSFER W/O STANDING INSTRACT' --@p_payment_methode_name	
				,null --@p_supplier_group_code								
				,null --@p_supplier_group_name								
				,ass.vendor_code
				,ass.vendor_name
				,agm.currency_code --@p_currency_code									
				,agm.marketing_name --@p_mo_name											
				,agm.marketing_code--@p_mo_code											
				,null --@p_business_cub_category_code	
				,CASE agm.first_payment_type	WHEN 'ARR' THEN 'ARREAR' ELSE 'ADVANCE' END
				,'D' --@p_insurance_type_code		
				,'DSF Policy' --@p_insurance_type_name		
				,LEFT(aid.main_coverage_description,50)
				,mv.name + ', ' + mv.city_name
				,left(mv.city_name,50)
				,'3' --@p_payment_type_code	
				,'TRANSFER' --@p_payment_type_name	
				,case clm.total_agreement when 1 then 'NEW'
					else 'REPEAT ORDER'
				end
				,agm.client_id		
				,agm.client_name	
				,ags.ASSET_AMOUNT--ass.net_book_value_comm	
				,ags.borrowing_interest_rate	
				,ags.lease_round_amount		
				,agm.agreement_date			
				,ags.fa_code
				,mi.registration_class_type
				,ags.fa_name
				--
				--,@p_cre_date
				,@system_date
				,@p_cre_by
				,@p_cre_ip_address
				--,@p_cre_date
				,@system_date
				,@p_cre_by
				,@p_cre_ip_address
		from	dbo.agreement_main agm
				inner join dbo.agreement_asset ags			on (ags.agreement_no					= agm.agreement_no)
				inner join dbo.AGREEMENT_ASSET_VEHICLE asv on ( asv.ASSET_NO = ags.ASSET_NO)
				left join dbo.MASTER_VEHICLE_MERK mvm on mvm.CODE = asv.VEHICLE_MERK_CODE
				left join dbo.MASTER_VEHICLE_MODEL model on model.CODE = asv.VEHICLE_MODEL_CODE
				--left join ifinams.dbo.asset_vehicle asv		on (asv.asset_code					  = ags.fa_code)
				inner join ifinsys.dbo.sys_branch sb		on (sb.code = agm.branch_code)
				inner join ifinsys.dbo.sys_region sr		on (sr.code = sb.region_code)
				left join dbo.application_main apm			on (apm.application_no					  = agm.application_no)
				left join dbo.asset_insurance_detail aid on (aid.asset_no = ags.asset_no)
				left join ifinams.dbo.asset ass on (ass.code								  = ags.fa_code)
				--left join ifinams.dbo.insurance_policy_asset ipa on (ipa.fa_code			  = ass.code)
				--left join ifinams.dbo.insurance_policy_main_period ipmp on (ipmp.policy_code = ipa.policy_code)
				left join ifinbam.dbo.master_vendor mv on (mv.code							  = ass.vendor_code)
				left join ifinbam.dbo.master_item mi on (mi.code = asv.vehicle_unit_code)
				left join ifinbam.dbo.sys_general_subcode sgs on (sgs.code = mi.class_type_code)
				outer apply
						(
							select	count(am.agreement_no) 'total_agreement'
							from	dbo.agreement_main am
							where	am.client_no = agm.client_no
							and am.agreement_no <> agm.agreement_no
						)clm
				
		 
		WHERE convert(varchar(6), agm.AGREEMENT_DATE , 112)  =   convert(varchar(6), @p_cre_date, 112)

		
		-- (+) Ari 2024-02-05 ket : add log
		if not exists (
						select	1 
						from	dbo.rpt_ext_disbursement_log lg
						where	lg.year = @year
						and		lg.month = @month
					  )
		begin
			insert into dbo.rpt_ext_disbursement_log
			(
				id
				,year
				,month
				,contract_no
				,skdno
				,officeid
				,regional
				,branch
				,brand_category
				,asset_brand_id
				,brand
				,asset_condition
				,asset_category
				,asset_type_id
				,asset_type
				,asset_model
				,asset_model_name
				,modeltypeid
				,modeltypename
				,economicsectorid
				,disburse_date
				,businees_type
				,finance_type
				,purpose_of_finance
				,way_of_finance
				,campaign
				,campaign_type
				,tenor
				,payment_method_id
				,payment_method
				,supplier_group_id
				,group_of_supplier_company
				,supplier_id
				,supplier_company
				,currency
				,mo_name
				,mo_id
				,business_sub_category
				,payment_mode
				,insurance_type_id
				,insurance_type
				,insurance_coverage
				,supplier_company_branch
				,supplier_location
				,payment_type_id
				,payment_type
				,repeat_or_new
				,customer_id
				,customer_name
				,ni
				,interest_rate
				,cost_price
				,accounting_book_date
				,cre_date
				,cre_by
				,cre_ip_address
				,mod_date
				,mod_by
				,mod_ip_address
			)
			select	id
				   ,year
				   ,month
				   ,contract_no
				   ,skdno
				   ,officeid
				   ,regional
				   ,branch
				   ,brand_category
				   ,asset_brand_id
				   ,brand
				   ,asset_condition
				   ,asset_category
				   ,asset_type_id
				   ,asset_type
				   ,asset_model
				   ,asset_model_name
				   ,modeltypeid
				   ,modeltypename
				   ,economicsectorid
				   ,disburse_date
				   ,businees_type
				   ,finance_type
				   ,purpose_of_finance
				   ,way_of_finance
				   ,campaign
				   ,campaign_type
				   ,tenor
				   ,payment_method_id
				   ,payment_method
				   ,supplier_group_id
				   ,group_of_supplier_company
				   ,supplier_id
				   ,supplier_company
				   ,currency
				   ,mo_name
				   ,mo_id
				   ,business_sub_category
				   ,payment_mode
				   ,insurance_type_id
				   ,insurance_type
				   ,insurance_coverage
				   ,supplier_company_branch
				   ,supplier_location
				   ,payment_type_id
				   ,payment_type
				   ,repeat_or_new
				   ,customer_id
				   ,customer_name
				   ,ni
				   ,interest_rate
				   ,cost_price
				   ,accounting_book_date
				   ,cre_date
				   ,cre_by
				   ,cre_ip_address
				   ,mod_date
				   ,mod_by
				   ,mod_ip_address 
			from	dbo.rpt_ext_disbursement
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
			set @msg = N'v' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%v;%'
				   or	error_message() like '%e;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'e;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_rpt_ext_disbursement_insert] TO [ims-raffyanda]
    AS [dbo];

