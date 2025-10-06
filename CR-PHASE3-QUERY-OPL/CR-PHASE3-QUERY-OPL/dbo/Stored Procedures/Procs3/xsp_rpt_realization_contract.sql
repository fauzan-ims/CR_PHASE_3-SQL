CREATE PROCEDURE dbo.xsp_rpt_realization_contract
(
	@p_user_id				nvarchar(15)
	,@p_realization_code	nvarchar(50)
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
	declare @msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@report_company_address	nvarchar(250)
			,@employee_name				nvarchar(250)
			,@employee_position			nvarchar(250)
			,@application_no			nvarchar(50)
			,@lease_rounded_amount		decimal(18,2)

	begin try
		delete dbo.rpt_contract
		where	user_id = @p_user_id ;

		delete dbo.rpt_contract_lampiran_i
		where user_id = @p_user_id

		delete dbo.rpt_contract_lampiran_ii
		where user_id = @p_user_id

		delete dbo.rpt_contract_lampiran_iii
		where user_id = @p_user_id

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2';

		select @report_company_address = value 
		from dbo.sys_global_param
		where CODE = 'INVADD'

		select @employee_name		= sem.name
				,@employee_position = sp.description
		from ifinsys.dbo.sys_employee_main sem
		left join ifinsys.dbo.sys_employee_position sep on (sep.emp_code = sem.code)
		left join ifinsys.dbo.sys_position sp on (sp.code = sep.position_code)
		where sem.code = @p_user_id
		
		select @application_no = application_no 
		from dbo.realization 
		where code = @p_realization_code


		select top 1 
				@lease_rounded_amount = sum(aa.lease_rounded_amount) 
		from dbo.application_asset aa
		inner join dbo.application_amortization aam on (aam.asset_no = aa.asset_no)
		where aa.application_no = @application_no
		group by aam.installment_no

		set @report_title = 'Report Realization Contract' ;

		insert into dbo.rpt_contract
		(
			user_id
			,report_image
			,report_company_name
			,report_title
			,agreement_no
			,agreement_date
			,contract_no
			,contract_date
			,employee_name
			,employee_position
			,client_name
			,client_employee
			,delivery_address
			,pickup_address
			,periode
			,start_date
			,end_date
			,unit_type
			,total_unit
			,asset_year
			,rental_amount
			,total_rental_amount
			,payment_date
			,start_payment_date
			,next_payment_date
			,end_payment_date
			,total_miles
			,additional_cost
			,effective_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select top 1 
				@p_user_id
				,@report_image
				,@report_company
				,@report_title
				,rlz.agreement_no
				,rlz.agreement_date
				,rlz.agreement_external_no
				,rlz.date
				,@employee_name
				,@employee_position
				,am.client_name
				,am.client_name
				,aa.deliver_to_address
				,aa.pickup_address
				,0
				,aa.bast_date
				,amo.due_date
				,''
				,0
				,aa.asset_year
				,@lease_rounded_amount
				,am.rental_amount
				,day(aa.bast_date)
				,aa.bast_date
				,null
				--,max(amo.due_date)
				,null
				,0
				,0
				,null
				--
			    ,@p_cre_date	   
			    ,@p_cre_by		   
			    ,@p_cre_ip_address 
			    ,@p_mod_date	   
			    ,@p_mod_by		   
			    ,@p_mod_ip_address 
		from	dbo.realization						   rlz
		left join dbo.realization_detail	   rd on (rd.realization_code = rlz.code)
		left join dbo.application_asset		   aa on (aa.asset_no = rd.asset_no)
		left join dbo.application_amortization amo on (amo.asset_no = rd.asset_no)
		left join dbo.application_main		   am on (am.application_no = rlz.application_no)
		where	rlz.code = @p_realization_code ;

		insert into dbo.rpt_contract_lampiran_i
		(
			user_id
			,report_company_name
			,report_title_lampiran_i
			,nomor_perjanjian_induk
			,nomor_perjanjian_pelaksana
			,tanggal_perjanjian
			,client_name
			,asset_name
			,asset_year
			,chassis_no
			,engine_no
			,sfesifikasi_and_accessories
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select distinct 
				@p_user_id
				,@report_company
				,@report_title
				,rlz.agreement_external_no
				,rlz.agreement_external_no
				,aa.bast_date
				,am.client_name
				,ass.item_name
				,aa.asset_year
				,av.chassis_no
				,av.engine_no
				,order_detail.spesification
				--
				,@p_cre_date	  
				,@p_cre_by		  
				,@p_cre_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
		from dbo.realization rlz
		left join dbo.realization_detail rld on (rld.realization_code = rlz.code)
		left join dbo.application_asset		   aa on (aa.asset_no = rld.asset_no)
		left join dbo.application_main		   am on (am.application_no =rlz.application_no)
		left join ifinams.dbo.asset ass on (ass.code = aa.fa_code)
		left join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code)
		left join ifinproc.dbo.eproc_interface_asset eia on (eia.code =  ass.code)
		outer apply(select top 1 pod.spesification from ifinproc.dbo.purchase_order_detail pod where pod.po_code = eia.po_no) order_detail
		where rlz.code = @p_realization_code

		insert into dbo.rpt_contract_lampiran_ii
		(
			user_id
			,report_company_name
			,report_company_address
			,report_title_lampiran_ii
			,day
			,date
			,month
			,year
			,contract_date
			,employee_name
			,client_name
			,client_employee_name
			,client_address
			,induk_sewa_operasi_no
			,induk_sewa_operasi_date
			,pelaksanaan_sewa_operasi_no
			,pelaksanaan_sewa_operasi_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select @p_user_id 
				,@report_company
				,@report_company_address
				,'BERITA ACARA SERAH TERIMA KENDARAAN'
				,day(dbo.xfn_get_system_date())
				,day(dbo.xfn_get_system_date())
				,month(dbo.xfn_get_system_date())
				,year(dbo.xfn_get_system_date())
				,rlz.agreement_date
				,@employee_name
				,am.client_name
				,@employee_name
				,am.client_address
				,rlz.agreement_external_no
				,rlz.date
				,rlz.agreement_external_no
				,rlz.date
				--
				,@p_cre_date	  
				,@p_cre_by		  
				,@p_cre_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
		from dbo.realization rlz
		left join dbo.application_main am on (am.application_external_no = rlz.agreement_external_no)
		where rlz.code = @p_realization_code

		insert into dbo.rpt_contract_lampiran_iii
		(
			user_id
			,report_company_name
			,report_title_lampiran_iii
			,nomor_perjanjian_induk
			,nomor_perjanjian_pelaksana
			,tanggal_perjanjian
			,client_name
			,asset_name
			,asset_year
			,chassis_no
			,engine_no
			,sfesifikasi_and_accessories
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select distinct 
				@p_user_id
				,@report_company
				,@report_title
				,rlz.agreement_external_no
				,rlz.agreement_external_no
				,aa.bast_date
				,am.client_name
				,ass.item_name
				,aa.asset_year
				,av.chassis_no
				,av.engine_no
				,order_detail.spesification
				--
				,@p_cre_date	  
				,@p_cre_by		  
				,@p_cre_ip_address
				,@p_mod_date	  
				,@p_mod_by		  
				,@p_mod_ip_address
		from dbo.realization rlz
		left join dbo.realization_detail rld on (rld.realization_code = rlz.code)
		left join dbo.application_asset		   aa on (aa.asset_no = rld.asset_no)
		left join dbo.application_main		   am on (am.application_no =rlz.application_no)
		left join ifinams.dbo.asset ass on (ass.code = aa.fa_code)
		left join ifinams.dbo.asset_vehicle av on (av.asset_code = ass.code)
		left join ifinproc.dbo.eproc_interface_asset eia on (eia.code =  ass.code)
		outer apply(select top 1 pod.spesification from ifinproc.dbo.purchase_order_detail pod where pod.po_code = eia.po_no) order_detail
		where rlz.code = @p_realization_code
		
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
