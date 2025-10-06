--Created by, Rian at 26/06/2023 

CREATE PROCEDURE dbo.xsp_rpt_skt
(
	@p_code				nvarchar(50)
	,@p_user_id			nvarchar(50)
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
	declare	@msg							nvarchar(max)
			,@report_company_name			nvarchar(250)
			,@report_image					nvarchar(250)
			,@report_title					nvarchar(250)
			,@letter_no						nvarchar(50)
			,@letter_date					datetime
			,@employee_delegator_name		nvarchar(250)
			,@employee_delegator_position	nvarchar(50)
			,@employee_name					nvarchar(250)
			,@employee_position				nvarchar(50)
			,@nama							nvarchar(50)
			,@jabatan						nvarchar(250)
			,@total_unit					int
			,@asset_name					nvarchar(250)
			,@client_name					nvarchar(250)
			,@client_address				nvarchar(4000)
			,@contract_no					nvarchar(50)
			,@agreement_no					nvarchar(50)
			,@unit							nvarchar(250)
			,@chassis_no					nvarchar(50)
			,@engine_no						nvarchar(50)
			,@plat_no						nvarchar(50)
			,@surat_no						nvarchar(50)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@branch_code					nvarchar(50)

	begin try

		delete	rpt_skt
		where	user_id = @p_user_id

		delete	dbo.rpt_skt_lampiran_i
		where	user_id = @p_user_id

		if exists
		(
			select	1
			from	dbo.repossession_letter
			where	code					 = @p_code
					and isnull(surat_no, '') = ''
		)
		begin
			set @year = (cast(datepart(year, @p_cre_date) as nvarchar)) ;
			set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

				exec dbo.xsp_generate_auto_surat_no @p_unique_code				= @surat_no output
													,@p_branch_code				= ''
													,@p_year					= @year
													,@p_month					= @month
													,@p_opl_code				= N'OPL/SK'
													,@p_run_number_length		= 5
													,@p_delimiter				= N'/'
													,@p_table_name				= N'REPOSSESSION_LETTER'
													,@p_column_name				= N'SURAT_NO' ;
				
				update	dbo.repossession_letter
				set		surat_no		= @surat_no
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code
		end

		select	@report_company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		select	@branch_code = branch_code
		from	dbo.repossession_letter
		where	code = @p_code ;

		select	@nama = sbs.signer_name 
				,@jabatan = spo.description
		from	ifinsys.dbo.sys_branch_signer sbs
		left join ifinsys.dbo.sys_employee_position sep on sep.emp_code = sbs.emp_code and sep.base_position='1'
		left join ifinsys.dbo.sys_position spo on spo.code = sep.position_code
		where	sbs.signer_type_code = 'HEADOPR'
				and sbs.branch_code = @branch_code ;

		set	@report_title = 'SURAT KUASA';

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		insert into dbo.rpt_skt
		(
			user_id
			,report_company_name
			,report_image
			,report_title
			,letter_no
			,letter_date
			,employee_delegator_name
			,employee_delegator_position
			,employee_name
			,employee_position
			,total_unit
			,asset_name
			,client_name
			,client_address
			,contract_no

			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,@report_company_name
				,@report_image
				,@report_title
				,rl.surat_no
				,rl.letter_date
				,@nama
				,@jabatan
				,rl.letter_collector_name
				,rl.letter_collector_position
				,rlco.count_asset
				,rlco.asset_name
				,am.client_name
				,rlco.pickup_address
				,am.agreement_external_no
				--
				,@p_cre_date		
				,@p_cre_by			
				,@p_cre_ip_address	
				,@p_mod_date		
				,@p_mod_by			
				,@p_mod_ip_address	
		from	dbo.repossession_letter rl 
				left join dbo.agreement_main am on (am.agreement_no = rl.agreement_no)
				outer apply
				(
					select	distinct
							count(ags.asset_name) 'count_asset'
							,ags.asset_name 'asset_name'
							,ags.pickup_name
							,ags.pickup_address
					from	dbo.repossession_letter_collateral rlc
							inner join dbo.agreement_asset ags on (ags.asset_no = rlc.asset_no)
					where	rlc.letter_code = @p_code
					group by ags.asset_name
							,ags.pickup_name
							,ags.pickup_address
				) rlco
		where	rl.code = @p_code

		insert into dbo.rpt_skt_lampiran_i
		(
			user_id
			,nomor_surat
			,MAIN_CONTRACT_NO
			,agreement_no
			,agreement_date
			,asset_name
			,VEHICLE_TYPE
			,BRAND
			,year
			,chassis_no
			,engine_no
			,plat_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		select	@p_user_id
				,rl.surat_no
				,aext.main_contract_no
				,am.agreement_external_no
				,am.agreement_date
				,aas.asset_name
				,mvu.class_type_name
				,mvm.description
				,aas.asset_year
				,isnull(aas.replacement_fa_reff_no_02, aas.fa_reff_no_02)
				,isnull(aas.replacement_fa_reff_no_03, aas.fa_reff_no_03)
				,isnull(aas.replacement_fa_reff_no_01, aas.fa_reff_no_01)
				--
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
		from	dbo.repossession_letter rl
				left join dbo.repossession_letter_collateral rlc on (rlc.letter_code = rl.code)
				left join dbo.agreement_asset aas on (aas.asset_no					 = rlc.asset_no)
				left join dbo.agreement_main am on (am.agreement_no					 = rl.agreement_no)
				left join dbo.application_extention aext on (aext.application_no	 = am.application_no)
				left join dbo.agreement_asset_vehicle aav on (aav.asset_no			 = aas.asset_no)
				left join dbo.master_vehicle_unit mvu on (mvu.code					 = aav.vehicle_unit_code)
				left join dbo.master_vehicle_merk mvm on (mvm.code					 = aav.vehicle_merk_code)
		where	rl.code = @p_code ;

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
end
