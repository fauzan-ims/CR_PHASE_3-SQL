-- Louis Selasa, 02 April 2024 17.07.45 --
CREATE PROCEDURE [dbo].[xsp_application_survey_copy_without_limitation]
(
	@p_client_no	   nvarchar(50)
	,@p_application_no nvarchar(50)
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
	declare @msg					 nvarchar(max)
			,@get_application_no	 nvarchar(50)	= ''
			,@overall_assessment	 nvarchar(50)	= ''
			,@notes					 nvarchar(500)	= ''
			,@economic_se			 nvarchar(250)	= ''
			,@pemberi_kerja			 nvarchar(250)	= ''
			,@kelas_pemberi_kerja	 nvarchar(250)	= ''
			,@management_style		 nvarchar(250)	= ''
			,@lokasi_area_kerja		 nvarchar(500)	= ''
			,@no_of_client			 nvarchar(50)	= ''
			,@no_of_emp				 nvarchar(50)	= ''
			,@credit_lob			 nvarchar(50)	= ''
			,@business_exp			 nvarchar(250)	= ''
			,@supplier_code			 nvarchar(50)	= ''
			,@desc					 nvarchar(4000)	= ''
			,@ni_amount				 decimal(18, 2)	= 0
			,@total_ni_amount		 decimal(18, 2)	= 0
			,@name					 nvarchar(250)	= ''
			,@business				 nvarchar(250)	= ''
			,@business_location		 nvarchar(250)	= ''
			,@unit					 bigint			= 0
			,@additional_info		 nvarchar(4000)	= ''
			,@project_name			 nvarchar(250)	= ''
			,@project_owner			 nvarchar(250)	= ''
			,@main_kontraktor		 nvarchar(250)	= ''
			,@sub_kontraktor		 nvarchar(250)	= ''
			,@sub_sub_kontraktor	 nvarchar(250)	= ''
			,@main_kompetitor		 nvarchar(250)	= ''
			,@sub_kompetitor		 nvarchar(250)	= ''
			,@sub_sub_kompetitor	 nvarchar(250)	= ''
			,@bank_id				 int		    = 0
			,@bank_id_copy			 int		    = 0
			,@company				 nvarchar(250)	= ''
			,@monthly_amount		 decimal(18, 2)	= 0
			,@average				 decimal(18, 2)	= 0
			,@mutation_month		 nvarchar(250)	= ''
			,@mutation_year			 nvarchar(4)	= ''
			,@client_code			 nvarchar(50)	= ''
			,@client_name			 nvarchar(250)	= ''
			,@client_address_usaha	 nvarchar(4000)	= ''
			,@client_city_usaha		 nvarchar(250)	= ''
			,@client_province_usaha	 nvarchar(250)	= ''
			,@client_address_kantor	 nvarchar(4000)	= ''
			,@client_city_kantor	 nvarchar(250)	= ''
			,@client_province_kantor nvarchar(250)	= ''
			,@est_date				 datetime 
			,@p_code				 nvarchar(50)	= ''

	begin try
						
		-- get application no & application date latest dengan client yg sama (existing)
		select	top 1 
				@get_application_no = am.application_no 
		from	dbo.client_main cm
		inner	join dbo.application_main am on (am.client_code = cm.code)
		where	cm.client_no = @p_client_no
		and		am.application_no <> @p_application_no
		and		am.application_status = 'GO LIVE'
		order	by am.golive_date desc, am.cre_date   desc

		select	@client_name = isnull(cm.client_name, '')
				,@client_address_kantor = isnull(ca1.address, '')
				,@client_city_kantor = isnull(ca1.city_name, '')
				,@client_province_kantor = isnull(ca1.province_name, '')
				,@client_address_usaha = isnull(ca2.address, '')
				,@client_city_usaha = isnull(ca2.city_name, '')
				,@client_province_usaha = isnull(ca2.province_name, '')
				,@client_code = isnull(am.client_code, '')
		from	dbo.application_main am
				inner join dbo.client_main cm on (cm.code					 = am.client_code)
				left join dbo.client_address ca1 on (
														ca1.client_code		 = cm.code
														and ca1.is_legal	 = '1'
													)
				left join dbo.client_address ca2 on (
														ca2.client_code		 = cm.code
														and ca2.is_residence = '1'
													)
		where	application_no = @p_application_no ;

		select	@est_date = est_date
		from	dbo.client_corporate_info
		where	client_code = @client_code ;

		select	@overall_assessment = isnull(overall_assessment, '')
				,@notes = notes
				,@economic_se = economic_sector_evaluation
				,@pemberi_kerja = pemberi_kerja
				,@kelas_pemberi_kerja = kelas_pemberi_kerja
				,@management_style = management_style
				,@lokasi_area_kerja = lokasi_area_kerja
				,@no_of_client = no_of_client
				,@no_of_emp = no_of_employee
				,@credit_lob = credit_line_of_bank
				,@business_exp = business_expansion
				,@supplier_code = code
		from	dbo.application_survey
		where	application_no = @get_application_no ;
		 

		exec dbo.xsp_application_survey_insert @p_code								= ''
												,@p_application_no					= @p_application_no
												,@p_nama							= @client_name
												,@p_application_type				= N''
												,@p_group_name						= N''
												,@p_alamat_kantor					= @client_address_kantor	
												,@p_alamat_kantor_kota				= @client_city_kantor	
												,@p_alamat_kantor_provinsi			= @client_province_kantor
												,@p_alamat_usaha					= @client_address_usaha	
												,@p_alamat_usaha_kota				= @client_city_usaha		
												,@p_alamat_usaha_provinsi			= @client_province_usaha
												,@p_alamat_sejak_usaha				= @est_date
												,@p_komoditi						= N'' 
												,@p_tujuan_pengadaan_unit			= N'' 
												,@p_as_of_date						= ''
												,@p_monthly_sales					= 0 
												,@p_total_monthly_expense			= 0 
												,@p_total_monthly_installment		= 0 
												,@p_total_monthly_installment_other	= 0 
												,@p_net_income						= 0 
												,@p_overall_assessment				= @overall_assessment
												,@p_notes							= @notes
												,@p_economic_sector_evaluation		= @economic_se
												,@p_pemberi_kerja					= @pemberi_kerja
												,@p_kelas_pemberi_kerja				= @kelas_pemberi_kerja
												,@p_management_style				= @management_style
												,@p_lokasi_area_kerja				= @lokasi_area_kerja
												,@p_no_of_client					= @no_of_client
												,@p_no_of_employee					= @no_of_emp
												,@p_credit_line_of_bank				= @credit_lob
												,@p_business_expansion				= @business_exp
												,@p_mo_summary						= N'' 
												,@p_capacity						= N''
												,@p_character						= N''
												,@p_strength						= N'' 
												,@p_weakness						= N'' 
												,@p_date_of_visit					= ''
												,@p_time							= N'' 
												,@p_survey_method					= N'' 
												,@p_venue_1							= N'' 
												,@p_venue_2							= N'' 
												,@p_project							= N'' 
												,@p_category						= N'' 
												,@p_trade_checking_date				= ''
												,@p_interview_name					= N'' 
												,@p_area_phone_number				= N''
												,@p_phone_number					= N'' 
												,@p_trade_checking_result			= N'' 
												,@p_trade_checking_notes			= N'' 
												,@p_cre_date						= @p_cre_date
												,@p_cre_by							= @p_cre_by
												,@p_cre_ip_address					= @p_cre_ip_address 
												,@p_mod_date						= @p_mod_date
												,@p_mod_by							= @p_mod_by
												,@p_mod_ip_address					= @p_mod_ip_address

		select	@p_code = code
		from	dbo.application_survey
		where	application_no = @p_application_no ;
		select 1
		-- application_survey_plan
		begin
			declare curr_surv_plan cursor fast_forward read_only for
			select	description
					,ni_amount
					,total_ni_amount
			from	dbo.application_survey_plan
			where	application_survey_code = @supplier_code ;

			open curr_surv_plan ;

			fetch next from curr_surv_plan
			into @desc
				 ,@ni_amount
				 ,@total_ni_amount ;

			while @@fetch_status = 0
			begin
				declare @p_id bigint ;

				exec dbo.xsp_application_survey_plan_insert @p_id = @p_id output
															,@p_application_survey_code = @p_code
															,@p_description = @desc
															,@p_ni_amount = @ni_amount
															,@p_total_ni_amount = @total_ni_amount
															,@p_cre_date = @p_cre_date
															,@p_cre_by = @p_cre_by
															,@p_cre_ip_address = @p_cre_ip_address
															,@p_mod_date = @p_mod_date
															,@p_mod_by = @p_mod_by
															,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_surv_plan
				into @desc
					 ,@ni_amount
					 ,@total_ni_amount ;
			end ;

			close curr_surv_plan ;
			deallocate curr_surv_plan ;
		end
		select 2
		--Top Customer Lease
		begin
			declare curr_surv_cust cursor fast_forward read_only for
			select	name
					,business
					,business_location
					,unit
					,additional_info
			from	dbo.application_survey_customer
			where	application_survey_code = @supplier_code ;

			open curr_surv_cust ;

			fetch next from curr_surv_cust
			into @name
				 ,@business
				 ,@business_location
				 ,@unit
				 ,@additional_info ;

			while @@fetch_status = 0
			begin
				declare @p_id1 bigint ;

				exec dbo.xsp_application_survey_customer_insert @p_id = @p_id1 output
																,@p_application_survey_code = @p_code
																,@p_name = @name
																,@p_business = @business
																,@p_business_location = @business_location
																,@p_unit = @unit
																,@p_additional_info = @additional_info
																,@p_cre_date = @p_cre_date
																,@p_cre_by = @p_cre_by
																,@p_cre_ip_address = @p_cre_ip_address
																,@p_mod_date = @p_mod_date
																,@p_mod_by = @p_mod_by
																,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_surv_cust
				into @name
					 ,@business
					 ,@business_location
					 ,@unit
					 ,@additional_info ;
			end ;

			close curr_surv_cust ;
			deallocate curr_surv_cust ;
		end
		select 3
		-- application_survey_project
		begin
			declare curr_surv_prj cursor fast_forward read_only for
			select	project_name
					,project_owner
					,main_kontraktor
					,sub_kontraktor
					,sub_sub_kontraktor
					,main_kompetitor
					,sub_kompetitor
					,sub_sub_kompetitor
			from	dbo.application_survey_project
			where	application_survey_code = @supplier_code ;

			open curr_surv_prj ;

			fetch next from curr_surv_prj
			into @project_name
				 ,@project_owner
				 ,@main_kontraktor
				 ,@sub_kontraktor
				 ,@sub_sub_kontraktor
				 ,@main_kompetitor
				 ,@sub_kompetitor
				 ,@sub_sub_kompetitor ;

			while @@fetch_status = 0
			begin
				declare @p_id2 bigint ;

				exec dbo.xsp_application_survey_project_insert @p_id = @p_id2 output
															   ,@p_application_survey_code = @p_code
															   ,@p_project_name = @project_name
															   ,@p_project_owner = @project_owner
															   ,@p_main_kontraktor = @main_kontraktor
															   ,@p_sub_kontraktor = @sub_kontraktor
															   ,@p_sub_sub_kontraktor = @sub_sub_kontraktor
															   ,@p_main_kompetitor = @main_kompetitor
															   ,@p_sub_kompetitor = @sub_kompetitor
															   ,@p_sub_sub_kompetitor = @sub_sub_kompetitor
															   ,@p_cre_date = @p_cre_date
															   ,@p_cre_by = @p_cre_by
															   ,@p_cre_ip_address = @p_cre_ip_address
															   ,@p_mod_date = @p_mod_date
															   ,@p_mod_by = @p_mod_by
															   ,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_surv_prj
				into @project_name
					 ,@project_owner
					 ,@main_kontraktor
					 ,@sub_kontraktor
					 ,@sub_sub_kontraktor
					 ,@main_kompetitor
					 ,@sub_kompetitor
					 ,@sub_sub_kompetitor ;
			end ;

			close curr_surv_prj ;
			deallocate curr_surv_prj ;
		end

		-- application_survey_bank_detail
		begin
			select	@bank_id = id
			from	dbo.application_survey_bank
			where	application_survey_code = @p_code ;

			select	@bank_id_copy = id
			from	dbo.application_survey_bank
			where	application_survey_code = @supplier_code ;

			declare curr_surv_bank_d cursor fast_forward read_only for
			select	company
					,monthly_amount
					,average
					,mutation_month
					,mutation_year
			from	dbo.application_survey_bank_detail
			where	application_survey_bank_id = @bank_id_copy ;

			open curr_surv_bank_d ;

			fetch next from curr_surv_bank_d
			into @company
				 ,@monthly_amount
				 ,@average
				 ,@mutation_month
				 ,@mutation_year ;

			while @@fetch_status = 0
			begin
				declare @p_id4 bigint ;

				exec dbo.xsp_application_survey_bank_detail_insert @p_id = @p_id4 output
																   ,@p_application_survey_bank_id = @bank_id
																   ,@p_company = @company
																   ,@p_monthly_amount = @monthly_amount
																   ,@p_average = @average
																   ,@p_mutation_month = @mutation_month
																   ,@p_mutation_year = @mutation_year
																   ,@p_cre_date = @p_cre_date
																   ,@p_cre_by = @p_cre_by
																   ,@p_cre_ip_address = @p_cre_ip_address
																   ,@p_mod_date = @p_mod_date
																   ,@p_mod_by = @p_mod_by
																   ,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_surv_bank_d
				into @company
					 ,@monthly_amount
					 ,@average
					 ,@mutation_month
					 ,@mutation_year ;
			end ;

			close curr_surv_bank_d ;
			deallocate curr_surv_bank_d ;
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
			set @msg = N'V' + N';' + @msg ;
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
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
