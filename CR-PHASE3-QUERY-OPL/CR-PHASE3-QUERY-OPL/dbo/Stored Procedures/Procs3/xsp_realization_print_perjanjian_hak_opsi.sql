--Created by, Rian at 18/01/2023 
CREATE PROCEDURE dbo.xsp_realization_print_perjanjian_hak_opsi
(
	@p_user_id	nvarchar(50)
	,@p_code	nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max)
			,@agreement_no				nvarchar(50)
			,@agreement_external_no		nvarchar(50)
			,@company_name				nvarchar(50)	
			,@company_city				nvarchar(250)
			,@company_address			nvarchar(250)
			,@company_npwp_no			nvarchar(50)
			,@employee_name				nvarchar(50)
			,@employee_position			nvarchar(50)
			,@company_area_phone_no		nvarchar(10)
			,@company_phone_no			nvarchar(15)
			,@company_phone				nvarchar(20)
			,@client_address			nvarchar(250)
			,@client_city				nvarchar(250)
			,@client_village			nvarchar(250)
			,@client_sub_distric		nvarchar(250)
			,@client_postal_code		nvarchar(50)
			,@siup_no					nvarchar(50)
			,@client_npwp_no			nvarchar(50)
			,@client_name				nvarchar(50)
			,@client_phone_no			nvarchar(50)
			,@asset_no					nvarchar(50)
			,@asset_type				nvarchar(50)
			,@asset_name				nvarchar(50)
			,@plat_no					nvarchar(50)
			,@asset_year				nvarchar(50)
			,@chasis_no					nvarchar(50)
			,@engine_no					nvarchar(50)
			,@periode					int
			,@billing_amount			decimal(18,2)
			,@payment_type				nvarchar(50)
			,@print_asset_no			nvarchar(50)
			,@print_asset_name			nvarchar(50)
			,@print_asset_type			nvarchar(50)
			,@print_plat_no				nvarchar(50)
			,@print_chasis_no			nvarchar(50)
			,@print_engine_no			nvarchar(50)
			,@print_periode				nvarchar(50)
			,@print_asset_year			nvarchar(50)
			,@print_no					nvarchar(3)
			,@no						int = 0
			,@temp_print_asset_no		nvarchar(4000) = ''
			,@temp_print_asset_name     nvarchar(4000) = ''
			,@temp_print_asset_type     nvarchar(4000) = ''
			,@temp_print_plat_no		nvarchar(4000) = ''	
			,@temp_print_chasis_no		nvarchar(4000) = ''	
			,@temp_print_engine_no		nvarchar(4000) = ''	
			,@temp_print_periode		nvarchar(4000) = ''	
			,@temp_print_asset_year		nvarchar(4000) = ''
			,@temp_no					nvarchar(4000) = ''
			,@system_date				datetime
			,@application_no			nvarchar(50)
			,@client_code				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@years						nvarchar(4)
			,@month						nvarchar(2)

			


	begin try

		set		@system_date = dbo.xfn_get_system_date()

		set @years = cast(datepart(year, @p_mod_date) as nvarchar)
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;
		
		select	@agreement_no				= rl.agreement_no
				,@employee_name				= rl.signer_name
				,@employee_position			= rl.signer_position
				,@client_code				= aa.client_code
				,@client_name				= cm.client_name
				,@client_address			= cad.address
				,@client_city				= cad.city_name
				,@client_sub_distric		= cad.sub_district
				,@client_village			= cad.village
				,@client_phone_no			= cad.area_phone_no + cad.phone_no
				,@client_postal_code		= cad.zip_code_code
				,@payment_type				= aa.first_payment_type
		from	dbo.realization rl
				left join dbo.realization_detail rld	on (rl.code = rld.realization_code)
				left join dbo.application_main aa		on (aa.application_no = rl.application_no)
				left join dbo.client_main cm			on (cm.code = aa.client_code)
				left join dbo.client_address cad		on (cm.code = cad.client_code)
				left join dbo.agreement_asset agr		on (agr.asset_no = rld.asset_no)
		where	rl.code = @p_code ;

		--set company name
		select	@company_name = value
		from	dbo.sys_global_param
		where	code = 'COMP'

		--set company address
		select	@company_address = value
		from	dbo.sys_global_param
		where	code = 'INVADD'

		--set company city
		select	@company_city = value
		from	dbo.sys_global_param
		where	code = 'INVCITY'

		--set company area phone no
		select	@company_area_phone_no = value 
		from	dbo.sys_global_param
		where	code = 'TELPAREA'

		--set company phone no
		select	@company_phone_no = value 
		from	dbo.sys_global_param
		where	code = 'TELP'

		set	@company_phone = @company_area_phone_no + @company_phone_no

		--set company NPWP no
		select	@company_npwp_no = value
		from	dbo.sys_global_param
		where	code = 'INVNPWP'

		--set siup code
		select	@siup_no = document_no
		from	dbo.client_doc
		where	client_code = @client_code
		and		doc_type_code = 'SIUP'

		--set client npwp no
		select	@client_npwp_no = document_no
		from	dbo.client_doc
		where	client_code = @client_code
		and		doc_type_code = 'TAXID'

		--set billing amount
		select		@billing_amount = sum(aaa.billing_amount)
		from		dbo.application_amortization aaa
		inner join	dbo.realization_detail rld on (rld.asset_no = aaa.asset_no)
		inner join	dbo.realization rl on (rl.code = rld.realization_code)
		where		rl.code = @p_code
		and			aaa.installment_no = 1

		if exists
		(
			select	1
			from	dbo.realization
			where	code						 = @p_code
					and isnull(agreement_no, '') = ''
		)
		begin 
			
			select	@client_code		= am.client_code
					,@branch_code		= am.branch_code
					,@application_no	= am.application_no
			from	dbo.realization rz
					inner join dbo.application_main am on (am.application_no = rz.application_no)
			where	code = @p_code ;

			-- get agreement no
			exec dbo.xsp_generate_application_no @p_unique_code			= @agreement_no output
												 ,@p_branch_code		= @branch_code
												 ,@p_year				= @years
												 ,@p_month				= @month
												 ,@p_opl_code			= N'4'
												 ,@p_run_number_length  = 7
												 ,@p_delimiter			= N'.' 
												 ,@p_type				= 'AGREEMENT'

			set @agreement_external_no = replace(@agreement_no, '.', '/')

			-- get agreement eexternal no
			--exec dbo.xsp_generate_application_no @p_unique_code			= @agreement_external_no output
			--									 ,@p_branch_code		= @branch_code
			--									 ,@p_year				= @years
			--									 ,@p_month				= @month
			--									 ,@p_opl_code			= N'4'
			--									 ,@p_run_number_length  = 7
			--									 ,@p_delimiter			= N'/' ;

	
			if (@agreement_no is null)
			begin
				set @msg = 'Failed generate Agreement No';
				raiserror(@msg, 16, 1) ;
			end ;
			
			-- update realization
			update	realization
			set		agreement_no			= @agreement_no
					,agreement_external_no  = @agreement_external_no
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ; 
		end


		--declare cursor
		declare c_asset cursor for
		select	rld.asset_no
				,ass.asset_name
				,ass.asset_year
				,ass.fa_reff_no_01
				,ass.fa_reff_no_02
				,ass.fa_reff_no_03
				,sgs.description
				,am.periode
		from	dbo.realization rl
				left join dbo.realization_detail rld	on (rl.code = rld.realization_code)
				left join dbo.agreement_asset agr		on (agr.asset_no = rld.asset_no)
				left join dbo.application_asset ass		on (ass.asset_no = rld.asset_no)
				left join dbo.application_main am		on (am.application_no = ass.application_no)
				left join dbo.sys_general_subcode sgs	on (sgs.code = ass.asset_type_code)
		where	rl.code = @p_code ;

		--open cursor
		open	c_asset

		--fetch cursor
		fetch	c_asset
		into	@asset_no
				,@asset_name
				,@asset_year
				,@plat_no
				,@chasis_no
				,@engine_no
				,@asset_type
				,@periode

		while	@@fetch_status = 0
		begin
			--set awal
			set @print_asset_no		= '' 
			set @print_asset_name	= ''
			set @print_asset_year	= ''
			set @print_plat_no		= '' 
			set @print_chasis_no	= '' 
			set @print_engine_no	= '' 
			set @print_asset_type	= '' 
			set @print_periode		= ''  
			set @print_no			= '' 
			set @no	+= 1

			--set dari fetch
			set @print_asset_no		= @asset_no
			set @print_asset_name	= @asset_name
			set @print_asset_year	= @asset_year
			set @print_plat_no		= @plat_no
			set @print_chasis_no	= @chasis_no
			set @print_engine_no	= @engine_no
			set @print_asset_type	= @asset_type
			set @print_periode		= @periode
			

			--set data loopingan 
			set @print_no					= cast(@no as nvarchar(3)) 
			set @temp_no					= @temp_no + @print_no + char(10) + char(13) 
			set @temp_print_asset_no		= @temp_print_asset_no + @print_asset_no + char(10) + char(13) 
			set @temp_print_asset_name		= @temp_print_asset_name + @print_asset_name + char(10) + char(13) 
			set @temp_print_asset_year		= @temp_print_asset_year + @print_asset_year + char(10) + char(13) 
			set @temp_print_plat_no			= @temp_print_plat_no + @print_plat_no + char(10) + char(13) 
			set @temp_print_chasis_no		= @temp_print_chasis_no + @print_chasis_no + char(10) + char(13) 
			set @temp_print_engine_no		= @temp_print_engine_no + @print_engine_no + char(10) + char(13) 
			set @temp_print_asset_type		= @temp_print_asset_type + @print_asset_type + char(10) + char(13) 
			set @temp_print_periode			= @temp_print_periode + @print_periode + char(10) + char(13) 
			

			--fetch cursor selanjutnya
			fetch	c_asset
			into	@asset_no
					,@asset_name
					,@asset_year
					,@plat_no
					,@chasis_no
					,@engine_no
					,@asset_type
					,@periode
		end

		--close and deallocate cursor
		close		c_asset
		deallocate	c_asset

		select	am.agreement_external_no								as 'AGREEMENT_EXTERNAL_NO'
				,@temp_print_asset_no									as 'ASSET_NO'
				,@client_code											as 'CLIENT_NO'
				,@temp_print_asset_name									as 'ASSET_NAME'
				,@temp_print_asset_year									as 'ASSET_YEAR'
				,@temp_print_asset_type									as 'ASSET_TYPE'
				,@client_name											as 'CLIENT_NAME'
				,@client_address										as 'CLIENT_ADDRESS'
				,@client_city											as 'CLIENT_CITY'
				,@client_sub_distric									as 'CLIENT_SUB_DISTRIC'
				,@client_village										as 'CLIENT_VILLAGE'
				,@client_phone_no										as 'CLIENT_PHONE_NO'
				,@client_postal_code									as 'CLIENT_POSTAL_CODE'
				,@siup_no												as 'SIUP_NO'
				,@client_npwp_no										as 'CLIENT_NPWP_NO'
				,@company_name											as 'COMPANY_NAME'
				,@company_city											as 'COMPANY_CITY'
				,@company_address										as 'COMPANY_ADDRESS'
				,@company_npwp_no										as 'COMPANY_NPWP_NO'
				,@company_phone											as 'COMPANY_PHONE_NO'
				,@employee_name											as 'EMPLOYEE_NAME'
				,@employee_position										as 'EMPLOYEE_POSITION'
				,@temp_print_plat_no									as 'PLAT_NO'
				,@temp_print_chasis_no									as 'CHASIS_NO'
				,@temp_print_engine_no									as 'ENGINE_NO'
				,@temp_print_periode									as 'PERIODE'
				,@temp_no												as 'NO'
				,(case
					when @payment_type = 'ADV' 
						then 'Dibayar di awal bulan'
					when @payment_type = 'ARR'
						then 'Dibayar di akhir bulan'
					else ''
				  end)													as 'PAYMENT_TYPE'
				,convert(varchar, cast(@billing_amount as money), 1)		as 'BILLING_AMOUNT'
				,convert(nvarchar(30), rl.date, 105)					as 'DATES'
				,(case
					  when datename(dw, rl.date) = 'Sunday'		then 'Minggu'
					  when datename(dw, rl.date) = 'Monday'		then 'Senin'
					  when datename(dw, rl.date) = 'Tuesday'	then 'Selasa'
					  when datename(dw, rl.date) = 'Wednesday'	then 'Rabu'
					  when datename(dw, rl.date) = 'Thursday'	then 'Kamis'
					  when datename(dw, rl.date) = 'Friday'		then 'Jumat'
					  else 'Sabtu'
				  end
				 )														as 'DAY'
				,dbo.Terbilang(day(rl.date))							as 'DATE'
				,datename(month, (rl.date))								as 'MONTH'
				,dbo.terbilang(year(rl.date))							as 'YEAR'
		from	dbo.realization rl
		left join dbo.application_main am on (am.application_no = rl.application_no)
		where	code = @p_code ;
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
