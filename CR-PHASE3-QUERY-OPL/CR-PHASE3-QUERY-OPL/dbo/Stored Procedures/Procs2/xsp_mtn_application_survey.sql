CREATE PROCEDURE dbo.xsp_mtn_application_survey
(
	@p_application_no		nvarchar(50)
	 --
   ,@p_mtn_remark		nvarchar(4000)
   ,@p_mtn_cre_by		nvarchar(250)
)
as
begin
	begin try
		begin transaction ;

			declare @agreement_no				nvarchar(50) = replace(@p_application_no,'/','.')
					,@client_code				nvarchar(50)
					,@client_name				nvarchar(250)
					,@year						nvarchar(4)
					,@month						nvarchar(2)
					,@msg						nvarchar(max)
					,@client_no					nvarchar(50)
					,@asset_no					nvarchar(50)
					,@fa_code					nvarchar(50)
					,@client_address_usaha		nvarchar(4000)
					,@client_city_usaha			nvarchar(250)
					,@client_province_usaha		nvarchar(250)
					,@client_address_kantor		nvarchar(4000)
					,@client_city_kantor		nvarchar(250)
					,@client_province_kantor	nvarchar(250) 
					,@apk_date					datetime -- (+) Ari 2023-10-13 ket : get apk date
					,@client_type				nvarchar(50)
					,@est_date					datetime
					,@mod_date					datetime = dbo.xfn_get_system_date()
					,@mod_by					nvarchar(50) = 'MAINTENANCE'
					,@mod_ip_address			nvarchar(50) = '127.0.0.1'
					,@get_client_code			nvarchar(50)
					,@get_application_no		nvarchar(50)
					,@get_application_date		datetime
					,@interval_day				int
					,@group_name				nvarchar(250)
					,@komoditi					nvarchar(250)
					,@tujuan_pengadaan			nvarchar(250)
					,@as_of_date				datetime
					,@monthly_sales				decimal(18,2)
					,@total_monthly_exp			decimal(18,2)
					,@total_monthly_ins			decimal(18,2)
					,@total_monthly_oth			decimal(18,2)
					,@net_income				decimal(18,2)
					,@overall_assessment		nvarchar(50)
					,@notes						nvarchar(500)
					,@economic_se				nvarchar(250)
					,@pemberi_kerja				nvarchar(250)
					,@kelas_pemberi_kerja		nvarchar(250)
					,@management_style			nvarchar(250)
					,@lokasi_area_kerja			nvarchar(500)
					,@no_of_client				nvarchar(50)
					,@no_of_emp					nvarchar(50)
					,@credit_lob				nvarchar(50)
					,@business_exp				nvarchar(250)
					,@mo_summary				nvarchar(500)
					,@capacity					nvarchar(250)
					,@character					nvarchar(250)
					,@strength					nvarchar(250)
					,@weakness					nvarchar(250)
					,@date_of_visit				datetime
					,@time						nvarchar(250)
					,@surv_method				nvarchar(250)
					,@venue1					nvarchar(250)
					,@venue2					nvarchar(250)
					,@project					nvarchar(250)
					,@category					nvarchar(250)
					,@trade_check				datetime
					,@interview_name			nvarchar(250)
					,@area_phone				nvarchar(50)
					,@phone_number				nvarchar(50)
					,@trade_check_rslt			nvarchar(250)
					,@trade_check_notes			nvarchar(250)
					,@getdate_can_RO			datetime
					,@supplier_code				nvarchar(50)
					,@desc						nvarchar(4000)
					,@ni_amount					decimal(18,2)
					,@total_ni_amount			decimal(18,2)
					,@name						nvarchar(250)
					,@business					nvarchar(250)
					,@business_location			nvarchar(250)
					,@unit						int
					,@additional_info			nvarchar(4000)
					,@project_name				nvarchar(250)
					,@project_owner				nvarchar(250)
					,@main_kontraktor			nvarchar(250)
					,@sub_kontraktor			nvarchar(250)
					,@sub_sub_kontraktor		nvarchar(250)
					,@main_kompetitor			nvarchar(250)
					,@sub_kompetitor			nvarchar(250)
					,@sub_sub_kompetitor		nvarchar(250)
					,@location					nvarchar(4000)
					,@remark					nvarchar(4000)
					,@file_name					nvarchar(250)
					,@path						nvarchar(250)
					,@bank_id					int
					,@bank_id_copy				int
					,@company					nvarchar(250)
					,@monthly_amount			decimal(18,2)
					,@average					decimal(18,2)
					,@mutation_month			nvarchar(250)
					,@mutation_year				nvarchar(4)
					,@rental_company			nvarchar(250)
					,@unit_kendaraan			int
					,@jenis_kendaraan			nvarchar(250)
					,@os_period					int
					,@nilai_pinjaman			decimal(18,2)

			select		@client_name			 = isnull(cm.client_name,'')
						,@client_address_kantor	 = isnull(ca1.address,'')
						,@client_city_kantor	 = isnull(ca1.city_name,'')
						,@client_province_kantor = isnull(ca1.province_name,'')
						,@client_address_usaha	 = isnull(ca2.address,'')
						,@client_city_usaha		 = isnull(ca2.city_name,'')
						,@client_province_usaha	 = isnull(ca2.province_name,'')
						,@client_type			 = isnull(cm.client_type,'')
						,@client_code			 = isnull(am.client_code,'')
						,@apk_date				 = am.application_date -- (+) Ari 2023-10-12 ket : get application date
			from		dbo.application_main am
			inner join	dbo.client_main cm on (cm.code = am.client_code)
			left join	dbo.client_address ca1 on (ca1.client_code = cm.code and ca1.is_legal = '1')
			left join	dbo.client_address ca2 on (ca2.client_code = cm.code and ca2.is_residence = '1')
			where		application_no = @p_application_no

			select	@est_date = est_date
			from	dbo.client_corporate_info
			where	client_code = @client_code ;

			select	@client_no = client_no
			from	dbo.client_main 
			where	code = @client_code

			select	top 1 
					@get_application_no = am.application_no 
					,@get_application_date = am.application_date
			from	dbo.client_main cm
			inner	join dbo.application_main am on (am.client_code = cm.code)
			where	cm.client_no = @client_no
			and		am.application_no <> @p_application_no
			and		am.application_status <> 'CANCEL'
			order	by am.application_date desc

			select	@interval_day = value
			from	dbo.sys_global_param 
			where	code = 'SVYVLDT'
			
			set	@interval_day = -1 * @interval_day
			
			set @getdate_can_RO  = dateadd(day, @interval_day, @apk_date)
			
			if((isnull(@p_mtn_remark, '') = '' or isnull(@p_mtn_cre_by,'') = ''))
			begin
				set @msg = 'MTN Remark/Cre by harus Terisi Sesuai yang di Maintenance';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists
			(
				select	1
				from	dbo.application_survey
				where	application_no		   = @p_application_no
			)
			begin
				set @msg = 'Application Survey sudah terdaftar harap dihapus terlebih dahulu';
				raiserror(@msg, 16, 1) ;
				return
			end ;

			if exists
			(
				select	1 
				from	dbo.application_main 
				where	application_no = @p_application_no
				and		application_status <> 'HOLD'
			)
			begin
				set @msg = 'Application sudah di proses.';
				raiserror(@msg, 16, 1) ;
				return
			end

			if not exists(select 1 from dbo.application_survey where application_no = @p_application_no)
			begin 
				--if( @get_application_date  between @getdate_can_RO and @apk_date) -- (+) Ari 2023-10-13 ket : jika tanggal dari applikasi client yg existing ada pada jangkauan settingan (interval day 90 settingan default dari parameter) maka inject survey, copy dengan yg existing
				if(@get_application_date >= @getdate_can_RO) -- (+) Ari 2024-02-01 ket : jika tanggal applikasi lama lebih besar dengan maximal tanggal Repeat Order nya maka generate data existing
				begin 
						select	@group_name = group_name
								,@komoditi = komoditi
								,@tujuan_pengadaan = tujuan_pengadaan_unit
								,@as_of_date = as_of_date
								,@monthly_sales = monthly_sales
								,@total_monthly_exp = total_monthly_expense
								,@total_monthly_ins = total_monthly_installment
								,@total_monthly_oth = total_monthly_installment_other
								,@net_income = net_income
								,@overall_assessment = overall_assessment
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
								,@mo_summary = mo_summary
								,@capacity = capacity
								,@character = character
								,@strength = strength
								,@weakness = weakness
								,@date_of_visit = date_of_visit
								,@time = time
								,@surv_method = survey_method
								,@venue1 = venue_1
								,@venue2 = venue_2
								,@project = project
								,@category = category
								,@trade_check = trade_checking_date
								,@interview_name = interview_name
								,@area_phone = area_phone_number
								,@phone_number = phone_number
								,@trade_check_rslt = trade_checking_result
								,@trade_check_notes = trade_checking_notes
								,@supplier_code = code
						from	dbo.application_survey 
						where	application_no = @get_application_no

						declare @p_code nvarchar(50) ;
						
						exec dbo.xsp_application_survey_insert @p_code								= @p_code
																,@p_application_no					= @p_application_no
																,@p_nama							= @client_name
																,@p_application_type				= N'RO'
																,@p_group_name						= @group_name
																,@p_alamat_kantor					= @client_address_kantor	
																,@p_alamat_kantor_kota				= @client_city_kantor	
																,@p_alamat_kantor_provinsi			= @client_province_kantor
																,@p_alamat_usaha					= @client_address_usaha	
																,@p_alamat_usaha_kota				= @client_city_usaha		
																,@p_alamat_usaha_provinsi			= @client_province_usaha
																,@p_alamat_sejak_usaha				= @est_date
																,@p_komoditi						= @komoditi
																,@p_tujuan_pengadaan_unit			= @tujuan_pengadaan
																,@p_as_of_date						= @as_of_date
																,@p_monthly_sales					= @monthly_sales
																,@p_total_monthly_expense			= @total_monthly_exp 
																,@p_total_monthly_installment		= @total_monthly_ins
																,@p_total_monthly_installment_other	= @total_monthly_oth
																,@p_net_income						= @net_income
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
																,@p_mo_summary						= @mo_summary
																,@p_capacity						= @capacity
																,@p_character						= @character
																,@p_strength						= @strength
																,@p_weakness						= @weakness
																,@p_date_of_visit					= @date_of_visit
																,@p_time							= @time
																,@p_survey_method					= @surv_method
																,@p_venue_1							= @venue1
																,@p_venue_2							= @venue2
																,@p_project							= @project
																,@p_category						= @category
																,@p_trade_checking_date				= @trade_check
																,@p_interview_name					= @interview_name
																,@p_area_phone_number				= @area_phone
																,@p_phone_number					= @phone_number
																,@p_trade_checking_result			= @trade_check_rslt
																,@p_trade_checking_notes			= @trade_check_notes
																,@p_cre_date						= @mod_date
																,@p_cre_by							= @mod_by
																,@p_cre_ip_address					= @mod_ip_address 
																,@p_mod_date						= @mod_date
																,@p_mod_by							= @mod_by
																,@p_mod_ip_address					= @mod_ip_address
					
						select	@p_code = code
						from	dbo.application_survey
						where	application_no = @p_application_no

					

						-- application_survey_plan
						declare curr_surv_plan cursor fast_forward read_only for 
						select	description
								,ni_amount
								,total_ni_amount
						from	dbo.application_survey_plan
						where	application_survey_code = @supplier_code
						open curr_surv_plan
						
						fetch next from curr_surv_plan 
						into	@desc
								,@ni_amount
								,@total_ni_amount
						
						while @@fetch_status = 0
						begin
								declare @p_id bigint ;
						
								exec dbo.xsp_application_survey_plan_insert @p_id = @p_id output 
																			,@p_application_survey_code = @p_code
																			,@p_description = @desc
																			,@p_ni_amount = @ni_amount
																			,@p_total_ni_amount = @total_ni_amount
																			,@p_cre_date = @mod_date
																			,@p_cre_by = @mod_by
																			,@p_cre_ip_address = @mod_ip_address
																			,@p_mod_date = @mod_date
																			,@p_mod_by = @mod_by
																			,@p_mod_ip_address = @mod_ip_address
						
						    fetch next from curr_surv_plan 
							into	@desc
									,@ni_amount
									,@total_ni_amount
						end
						
						close curr_surv_plan
						deallocate curr_surv_plan

						

						-- application_survey_customer
						declare curr_surv_cust cursor fast_forward read_only for 
						select	name
							   ,business
							   ,business_location
							   ,unit
							   ,additional_info 
						from	dbo.application_survey_customer
						where	application_survey_code = @supplier_code
						open curr_surv_cust
						
						fetch next from curr_surv_cust 
						into	@name
								,@business
								,@business_location
								,@unit
								,@additional_info
						
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
																				,@p_cre_date = @mod_date
																				,@p_cre_by = @mod_by
																				,@p_cre_ip_address = @mod_ip_address
																				,@p_mod_date = @mod_date
																				,@p_mod_by = @mod_by
																				,@p_mod_ip_address = @mod_ip_address
						
						    fetch next from curr_surv_cust 
							into	@name
									,@business
									,@business_location
									,@unit
									,@additional_info
						end
						
						close curr_surv_cust
						deallocate curr_surv_cust

						

						-- application_survey_project
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
						where	application_survey_code = @supplier_code
						open curr_surv_prj
						
						fetch next from curr_surv_prj 
						into	@project_name
								,@project_owner
								,@main_kontraktor
								,@sub_kontraktor
								,@sub_sub_kontraktor
								,@main_kompetitor
								,@sub_kompetitor
								,@sub_sub_kompetitor
						
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
																			   ,@p_cre_date = @mod_date
																			   ,@p_cre_by = @mod_by
																			   ,@p_cre_ip_address = @mod_ip_address
																			   ,@p_mod_date = @mod_date
																			   ,@p_mod_by = @mod_by
																			   ,@p_mod_ip_address = @mod_ip_address
						
						    fetch next from curr_surv_prj 
							into	@project_name
									,@project_owner
									,@main_kontraktor
									,@sub_kontraktor
									,@sub_sub_kontraktor
									,@main_kompetitor
									,@sub_kompetitor
									,@sub_sub_kompetitor
						end
						
						close curr_surv_prj
						deallocate curr_surv_prj

						
			
						-- application_survey_document
						declare curr_surv_doc cursor fast_forward read_only for
						select	location
							   ,remark
							   ,file_name
							   ,paths 
						from	dbo.application_survey_document
						where	application_survey_code = @supplier_code
						open curr_surv_doc
						
						fetch next from curr_surv_doc 
						into	@location
								,@remark
								,@file_name
								,@path
						
						while @@fetch_status = 0
						begin
								declare @p_id3 bigint ;
						
								exec dbo.xsp_application_survey_document_insert @p_id = @p_id3 output 
																				,@p_application_survey_code = @p_code
																				,@p_location = @location
																				,@p_remark = @remark
																				,@p_file_name = @file_name
																				,@p_paths = @path
																				,@p_cre_date = @mod_date
																				,@p_cre_by = @mod_by
																				,@p_cre_ip_address = @mod_ip_address
																				,@p_mod_date = @mod_date
																				,@p_mod_by = @mod_by
																				,@p_mod_ip_address = @mod_ip_address
						
						    fetch next from curr_surv_doc 
							into	@location
									,@remark
									,@file_name
									,@path
						end
						
						close curr_surv_doc
						deallocate curr_surv_doc

						

						

						select	@bank_id = id 
						from	dbo.application_survey_bank
						where	application_survey_code = @p_code

						select	@bank_id_copy = id 
						from	dbo.application_survey_bank
						where	application_survey_code = @supplier_code
						
						-- application_survey_bank_detail
						declare curr_surv_bank_d cursor fast_forward read_only for 
						select	company
							   ,monthly_amount
							   ,average
							   ,mutation_month
							   ,mutation_year
						from	dbo.application_survey_bank_detail
						where	application_survey_bank_id = @bank_id_copy
						open curr_surv_bank_d
						
						fetch next from curr_surv_bank_d 
						into	@company
								,@monthly_amount
								,@average
								,@mutation_month
								,@mutation_year
						
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
																				   ,@p_cre_date = @mod_date
																				   ,@p_cre_by = @mod_by
																				   ,@p_cre_ip_address = @mod_ip_address
																				   ,@p_mod_date = @mod_date
																				   ,@p_mod_by = @mod_by
																				   ,@p_mod_ip_address = @mod_ip_address
						
						    fetch next from curr_surv_bank_d 
							into	@company
									,@monthly_amount
									,@average
									,@mutation_month
									,@mutation_year
						end
						
						close curr_surv_bank_d
						deallocate curr_surv_bank_d

						--SELECT * FROM dbo.APPLICATION_SURVEY_BANK_DETAIL where b = @p_code

						-- application_survey_other_lease
						DECLARE curr_surv_otr_lease CURSOR FAST_FORWARD READ_ONLY FOR 
						select	rental_company
							   ,unit
							   ,jenis_kendaraan
							   ,os_periode
							   ,nilai_pinjaman 
						from	dbo.application_survey_other_lease
						where	application_survey_code = @supplier_code
						OPEN curr_surv_otr_lease
						
						FETCH NEXT FROM curr_surv_otr_lease 
						into	@rental_company
								,@unit_kendaraan
								,@jenis_kendaraan
								,@os_period
								,@nilai_pinjaman
						
						WHILE @@FETCH_STATUS = 0
						BEGIN
								declare @p_id5 bigint ;
						
								exec dbo.xsp_application_survey_other_lease_insert @p_id = @p_id5 output 
																				   ,@p_application_survey_code = @p_code
																				   ,@p_rental_company = @rental_company
																				   ,@p_unit = @unit_kendaraan
																				   ,@p_jenis_kendaraan = @jenis_kendaraan
																				   ,@p_os_periode = @os_period
																				   ,@p_nilai_pinjaman = @nilai_pinjaman
																				   ,@p_cre_date = @mod_date
																				   ,@p_cre_by = @mod_by
																				   ,@p_cre_ip_address = @mod_ip_address
																				   ,@p_mod_date = @mod_date
																				   ,@p_mod_by = @mod_by
																				   ,@p_mod_ip_address = @mod_ip_address
						
						    FETCH NEXT FROM curr_surv_otr_lease 
							into	@rental_company
									,@unit_kendaraan
									,@jenis_kendaraan
									,@os_period
									,@nilai_pinjaman
						END
						
						CLOSE curr_surv_otr_lease
						DEALLOCATE curr_surv_otr_lease

						
						
						
				end
				else
				begin -- default
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
															,@p_overall_assessment				= N'' 
															,@p_notes							= N'' 
															,@p_economic_sector_evaluation		= N'' 
															,@p_pemberi_kerja					= N'' 
															,@p_kelas_pemberi_kerja				= N'' 
															,@p_management_style				= N'' 
															,@p_lokasi_area_kerja				= N'' 
															,@p_no_of_client					= N'' 
															,@p_no_of_employee					= N'' 
															,@p_credit_line_of_bank				= N'' 
															,@p_business_expansion				= N'' 
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
															,@p_cre_date						= @mod_date
															,@p_cre_by							= @mod_by
															,@p_cre_ip_address					= @mod_ip_address 
															,@p_mod_date						= @mod_date
															,@p_mod_by							= @mod_by
															,@p_mod_ip_address					= @mod_ip_address
				end
			end


			INSERT INTO dbo.MTN_DATA_DSF_LOG
			(
				MAINTENANCE_NAME
				,REMARK
				,TABEL_UTAMA
				,REFF_1
				,REFF_2
				,REFF_3
				,CRE_DATE
				,CRE_BY
			)
			values
			(
				'MTN APPLICATION SURVEY'
				,@p_mtn_remark
				,'APPLICATION_SURVEY'
				,@p_application_no
				,@client_no -- REFF_2 - nvarchar(50)
				,null -- REFF_3 - nvarchar(50)
				,getdate()
				,@p_mtn_cre_by
			)
	
			if @@error = 0
			begin
				select 'SUCCESS'
				commit transaction ;
			end ;
			else
			begin
				select 'GAGAL PROCESS : ' + @msg
				rollback transaction ;
			end

		end try
		begin catch
			select 'GAGAL PROCESS : ' + @msg
			rollback transaction ;
		end catch ;    
end
