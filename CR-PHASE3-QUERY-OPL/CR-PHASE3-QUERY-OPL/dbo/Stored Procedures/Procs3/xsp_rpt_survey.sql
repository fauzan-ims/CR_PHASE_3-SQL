
CREATE PROCEDURE dbo.xsp_rpt_survey
(
	@p_user_id				nvarchar(max)
	,@p_survey_request_no	nvarchar(50)
)
as
begin

	delete dbo.rpt_survey
	where user_id = @p_user_id 

	--(+)Untuk Data Looping
	delete dbo.rpt_survey_rencana_pengadaan
	where user_id = @p_user_id 

	delete dbo.rpt_survey_top_customer
	where user_id = @p_user_id 

	delete dbo.rpt_survey_other_lessee
	where user_id = @p_user_id 

	delete dbo.rpt_survey_rekening
	where user_id = @p_user_id 

	delete dbo.rpt_survey_project_lessee
	where user_id = @p_user_id 

	delete dbo.rpt_survey_foto_and_document
	where user_id = @p_user_id 
	
	delete dbo.rpt_survey_bank_mutation
	where user_id = @p_user_id 

	declare	@msg						nvarchar(max)
			,@report_company			nvarchar(250)
			,@report_image				nvarchar(250)
			,@report_title				nvarchar(250)
			,@client_code				nvarchar(50)
			-- NAMA - nvarchar(250)
			-- APPLICATION_TYPE - nvarchar(50)
			-- GROUP_NAME - nvarchar(250)
			-- ALAMAT_KANTOR - nvarchar(4000)
			-- KOTA - nvarchar(50)
			-- PROVISI - nvarchar(50)
			-- ALAMAT_USAHA - nvarchar(4000)
			-- KOTA_USAHA - nvarchar(50)
			-- PROVISI_USAHA - nvarchar(50)
			-- USAHA_SEJAK - datetime
			-- AS_OF_DATE - datetime
			-- MONTHLY_SALES_OR_REVENUE - decimal(18, 2)
			-- TOTAL_MONTHLY_EXPENSE - decimal(18, 2)
			-- TOTAL_MONTHLY_INSTALLMENT_DSF - decimal(18, 2)
			-- TOTAL_MONTHLY_INSTALLMENT_OTHER - decimal(18, 2)
			-- NET_INCOME_AMOUNT - decimal(18, 2)
			-- OVERAL_ASSESSMENT - nvarchar(50)
			-- NOTES - nvarchar(250)
			-- ECONOMIC_SEKTOR - nvarchar(50)
			-- PEMBELI_KERJA - nvarchar(250)
			-- KELAS_PEMBERI_KERJA - nvarchar(50)
			-- MANAGEMENT_STYLE - nvarchar(50)
			-- LOKASI_OR_AREA_KERJA - nvarchar(4000)
			-- NO_OF_CLIENT - nvarchar(50)
			-- NO_OF_EMPLOYEE - nvarchar(50)
			-- CREDIT_LINE_OF_BANK - nvarchar(50)
			-- BUSINESS_EXPANSION - nvarchar(50)
			-- MO_SUMMARY - nvarchar(4000)
			-- CAPACITY - nvarchar(4000)
			-- CHARACTER - nvarchar(4000)
			-- WEAKNESS - nvarchar(4000)
			-- STRENGHT - nvarchar(4000)
			-- DATE_OF_VISIT - datetime
			-- TIME - nvarchar(50)
			-- SURVEY_METHOD - nvarchar(50)
			-- VENUE_1 - nvarchar(4000)
			-- VENUE_2 - nvarchar(4000)
			-- PROJECT - nvarchar(50)
			-- CATEGORY - nvarchar(50)
			-- DATE - datetime
			-- INTERVIEW_NAME - nvarchar(50)
			-- PHONE_NUMBER - nvarchar(20)
			-- RESULT - nvarchar(50)
			-- NOTES_SURVEY - nvarchar(4000)


	begin try

		select	@report_image = value
		from	dbo.sys_global_param
		where	code = 'IMGDSF' ;

		select	@report_company = value
		from	dbo.sys_global_param
		where	code = 'COMP2' ;

		set	@report_title = 'APPLICATION ANALYSIS AND RECOMENDATION'

		select	@client_code = am.client_code
		from	dbo.application_survey aps
				inner join application_main am on am.APPLICATION_NO = aps.APPLICATION_NO ;

		insert into dbo.rpt_survey
		(
		    user_id
		    ,survey_request_no
		    ,report_company
		    ,report_title
		    ,report_image
		    ,nama
		    ,application_type
		    ,group_name
		    ,alamat_kantor
		    ,kota
		    ,provisi
		    ,alamat_usaha
		    ,kota_usaha
		    ,provisi_usaha
		    ,usaha_sejak
		    ,as_of_date
		    ,monthly_sales_or_revenue
		    ,total_monthly_expense
		    ,total_monthly_installment_dsf
		    ,total_monthly_installment_other
		    ,net_income_amount
		    ,overal_assessment
		    ,notes
		    ,economic_sektor
		    ,pembeli_kerja
		    ,kelas_pemberi_kerja
		    ,management_style
		    ,lokasi_or_area_kerja
		    ,no_of_client
		    ,no_of_employee
		    ,credit_line_of_bank
		    ,business_expansion
		    ,mo_summary
		    ,capacity
		    ,character
		    ,weakness
		    ,strenght
		    ,date_of_visit
		    ,time
		    ,survey_method
		    ,venue_1
		    ,venue_2
		    ,project
		    ,category
		    ,date
		    ,interview_name
		    ,phone_number
		    ,result
		    ,notes_survey
		)
			select	@p_user_id
					,@p_survey_request_no
					,@report_company
					,@report_title
					,@report_image
					,nama
					,application_type
					,group_name
					,alamat_kantor
					,alamat_kantor_kota
					,alamat_kantor_provinsi
					,alamat_usaha
					,alamat_usaha_kota
					,alamat_usaha_provinsi
					,alamat_sejak_usaha
					,as_of_date
					,monthly_sales
					,total_monthly_expense
					,total_monthly_installment
					,total_monthly_installment_other
					,net_income
					,overall_assessment
					,notes
					,economic_sector_evaluation
					,pemberi_kerja
					,kelas_pemberi_kerja
					,management_style
					,lokasi_area_kerja
					,case 
							when no_of_client = '1' then '1 MAIN CLIENT'
							when no_of_client = '2-3' then '2-3 CLIENT'
							when no_of_client = 'MORE THAN 3' then '>3 CLIENT / RETAIL'
							else null
					end
					,case
						when no_of_employee = 'LESS THAN 25' then '<25'
						when no_of_employee = '25-100' then '25 - 100'
						when no_of_employee = 'GREATER THAN 25' then '>100'
					end
					,credit_line_of_bank
					,business_expansion
					,mo_summary
					,''
					,''
					,''
					,''
					,date_of_visit
					,time
					,survey_method
					,venue_1
					,venue_2
					,project
					,category
					,trade_checking_date
					,interview_name
					,area_phone_number + phone_number
					,trade_checking_result
					,trade_checking_notes
			from	dbo.application_survey
			where	code = @p_survey_request_no

			insert into dbo.rpt_survey_rencana_pengadaan
			(
				user_id
				,description
				,ni_amount
				,komoditi
				,tujuan_pengadaan_unit
			)
			select	@p_user_id
					,asp.description
					,asp.ni_amount
					,''
					,aps.tujuan_pengadaan_unit
			from	dbo.application_survey aps
					--left join dbo.application_survey_plan asp on (asp.application_survey_code = aps.code)
					outer apply
					(
						select	*
						from	application_survey_plan
						where	application_survey_code = aps.code
					)asp
			where	aps.code = @p_survey_request_no ;

			insert into dbo.rpt_survey_top_customer
			(
				user_id
				,nama
				,business
				,business_location
				,unit_or_omzet
				,additional_info
			)
			select	@p_user_id
					,apsc.name
					,apsc.business
					,apsc.business_location
					,apsc.unit
					,apsc.additional_info
			from	dbo.application_survey aps
					--inner join dbo.application_survey_customer apsc on (apsc.application_survey_code = aps.code) 
					outer apply (
						select	*
						from	dbo.application_survey_customer
						where	application_survey_code = aps.code
					) apsc
					where	aps.code = @p_survey_request_no ;

			insert into dbo.rpt_survey_other_lessee
			(
				user_id
				,rental_company
				,jumlah_unit
				,jenis_kendaraan
				,os_periode
				,nilai_pinjaman
			)
			select	@p_user_id
					,asol.rental_company
					,asol.unit
					,asol.jenis_kendaraan
					,asol.os_periode
					,asol.nilai_pinjaman
			from	dbo.application_survey aps
					--inner join dbo.application_survey_other_lease asol on (asol.application_survey_code = aps.code)
					outer apply
						(
							select	*
							from	dbo.application_survey_other_lease asol
							where	asol.application_survey_code = aps.code
						) asol
			where	aps.code = @p_survey_request_no ;

			insert into dbo.rpt_survey_rekening
			(
				user_id
				,company_name
				,month
				,year
				,monthly_amount
			)
			select	@p_user_id
					,asbd.company
					,asbd.mutation_month
					,asbd.mutation_year
					,asbd.monthly_amount
			from	dbo.application_survey aps
					--inner join dbo.application_survey_bank asb on (asb.application_survey_code			   = aps.code)
					--inner join dbo.application_survey_bank_detail asbd on (asbd.application_survey_bank_id = asb.id)
					outer apply
						(
							select	*
							from	dbo.application_survey_bank asb
							where	asb.application_survey_code = aps.code
						) asb
					outer apply
						(
							select	*
							from	dbo.application_survey_bank_detail asbd
							where	asbd.application_survey_bank_id = asb.id
						) asbd
			where	aps.code = @p_survey_request_no ;

			insert into dbo.rpt_survey_bank_mutation
			(
				user_id
				,client_code
				,client_bank_code
				,month
				,year
				,debit_transaction_count
				,debit_amount
				,credit_transaction_count
				,credit_amount
				,balance_amount
			)
			select	@p_user_id
					,client_code
					,client_bank_code
					,month
					,year
					,debit_transaction_count
					,debit_amount
					,credit_transaction_count
					,credit_amount
					,balance_amount
			from	dbo.client_bank_mutation
			where	client_code = @client_code ;

			insert into dbo.rpt_survey_project_lessee
			(
				user_id
				,project_name
				,pemilik_name
				,main_kontraktor
				,kompetitor_main
				,sub_kontraktor
				,kompetitor_sub
				,sub_sub_kontraktor
				,kompetitor_sub_sub
			)
			select	@p_user_id
					,asp.project_name
					,asp.project_owner
					,asp.main_kontraktor
					,asp.main_kompetitor
					,asp.sub_kontraktor
					,asp.sub_kompetitor
					,asp.sub_sub_kontraktor
					,asp.sub_sub_kompetitor
			from	dbo.application_survey aps
					--inner join dbo.application_survey_project asp on (asp.application_survey_code = aps.code)
					outer apply
						(
							select	*
							from	dbo.application_survey_project
							where	application_survey_code = aps.code
						) asp
			where	aps.code = @p_survey_request_no ;

			insert into dbo.rpt_survey_foto_and_document
			(
				user_id
				,location
				,remarks
				,file_name
			)
			select	@p_user_id
					,asd.location
					,asd.remark
					,asd.file_name
			from	dbo.application_survey aps
					--inner join dbo.application_survey_document asd on (asd.application_survey_code = aps.code)
					outer apply
						(
							select	*
							from	dbo.application_survey_document asd
							where	asd.application_survey_code = aps.code
						) asd
			where	aps.code = @p_survey_request_no ;

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
