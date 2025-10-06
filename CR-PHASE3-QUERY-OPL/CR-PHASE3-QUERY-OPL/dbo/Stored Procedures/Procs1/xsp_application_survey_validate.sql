CREATE PROCEDURE dbo.xsp_application_survey_validate
(
	@p_application_no  nvarchar(50)
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
	declare @msg		  nvarchar(max)
			,@survey_code nvarchar(25) ;

	begin try
		select	@survey_code = code
		from	dbo.application_survey
		where	application_no = @p_application_no ;

		-- survey profile customer

		-- survey rencana pengadaan dalam 1 tahun
		if not exists
		(
			select	1
			from	dbo.application_survey_plan
			where	application_survey_code = @survey_code
		)
		begin
			set @msg = N'Please input Survey Rencana Pengadaan' ;

			raiserror(@msg, 16, -1) ;
		end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.application_survey
		--	where	application_no			 = @p_application_no
		--			and isnull(komoditi, '') = ''
		--)
		--begin
		--	set @msg = N'Please input Komoditi in Rencana Pengadaan' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no						  = @p_application_no
					and isnull(tujuan_pengadaan_unit, '') = ''
		)
		begin
			set @msg = N'Please input Tujuan Pengadaan Unit in Rencana Pengadaan' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey_plan
			where	application_survey_code		= @survey_code
					and isnull(description, '') = ''
		)
		begin
			set @msg = N'Please input Description in Rencana Pengadaan' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey_plan
			where	application_survey_code	 = @survey_code
					and isnull(ni_amount, 0) = 0
		)
		begin
			set @msg = N'Please input NI (Rp) in Rencana Pengadaan' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey top customer lease
		if not exists
		(
			select	1
			from	dbo.application_survey_customer
			where	application_survey_code = @survey_code
		)
		begin
			set @msg = N'Please input Survey Top Customer Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	application_survey_customer
			where	application_survey_code = @survey_code
					and isnull(name, '')	= ''
		)
		begin
			set @msg = N'Please input Name in Survey Top Customer Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	application_survey_customer
			where	application_survey_code	 = @survey_code
					and isnull(business, '') = ''
		)
		begin
			set @msg = N'Please input Business in Survey Top Customer Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	application_survey_customer
			where	application_survey_code			  = @survey_code
					and isnull(business_location, '') = ''
		)
		begin
			set @msg = N'Please input Business Location in Survey Top Customer Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	application_survey_customer
			where	application_survey_code = @survey_code
					and
					(
						isnull(unit, 0)		= 0
						or	unit			< 0
					)
		)
		begin
			set @msg = N'Please input Unit/Omzet in Survey Top Customer Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	application_survey_customer
			where	application_survey_code			= @survey_code
					and isnull(additional_info, '') = ''
		)
		begin
			set @msg = N'Please input Additional Info in Survey Top Customer Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey other lessee
		--if not exists
		--(
		--	select	1
		--	from	dbo.application_survey_other_lease
		--	where	application_survey_code = @survey_code
		--)
		--begin
		--	set @msg = N'Please input Survey Other Lessee' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.application_survey_other_lease
		--	where	application_survey_code		   = @survey_code
		--			and isnull(rental_company, '') = ''
		--)
		--begin
		--	set @msg = N'Please input Rental Company in Survey Other Lessee' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.application_survey_other_lease
		--	where	application_survey_code = @survey_code
		--			and
		--			(
		--				isnull(unit, 0)		= 0
		--				or	unit			< 0
		--			)
		--)
		--begin
		--	set @msg = N'Please input Jumlah Unit in Survey Other Lessee' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.application_survey_other_lease
		--	where	application_survey_code			= @survey_code
		--			and isnull(jenis_kendaraan, '') = ''
		--)
		--begin
		--	set @msg = N'Please input Jenis Kendaraan in Survey Other Lessee' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.application_survey_other_lease
		--	where	application_survey_code	  = @survey_code
		--			and
		--			(
		--				isnull(os_periode, 0) = 0
		--				or	os_periode		  < 0
		--			)
		--)
		--begin
		--	set @msg = N'Please input O/S Periode in Survey Other Lessee' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;
		--else if exists
		--(
		--	select	1
		--	from	dbo.application_survey_other_lease
		--	where	application_survey_code		  = @survey_code
		--			and
		--			(
		--				isnull(nilai_pinjaman, 0) = 0
		--				or	nilai_pinjaman		  < 0
		--			)
		--)
		--begin
		--	set @msg = N'Please input Nilai Pinjaman in Survey Other Lessee' ;

		--	raiserror(@msg, 16, -1) ;
		--end ;

		-- survey financial data
		if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no				 = @p_application_no
					and
					(
						isnull(monthly_sales, 0) = 0
						or	monthly_sales		 < 0
					)
		)
		begin
			set @msg = N'Please input Monthly Sales/Revenue in Survey Financial Data' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no						 = @p_application_no
					and
					(
						isnull(total_monthly_expense, 0) = 0
						or	total_monthly_expense		 < 0
					)
		)
		begin
			set @msg = N'Please input Total Monthly Expense in Survey Financial Data' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no								   = @p_application_no
					and
					(
						isnull(total_monthly_installment_other, 0) = 0
						or	total_monthly_installment_other		   < 0
					)
		)
		begin
			set @msg = N'Please input Total Monthly Installment Other in Survey Financial Data' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no			  = @p_application_no
					and
					(
						isnull(net_income, 0) = 0
						or	net_income		  < 0
					)
		)
		begin
			set @msg = N'Please input Net Income Amount in Survey Financial Data' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey rekening

		-- survey bussiness information
		if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no					   = @p_application_no
					and isnull(overall_assessment, '') = ''
		)
		begin
			set @msg = N'Please Choose Overal Assessment in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no		  = @p_application_no
					and isnull(notes, '') = ''
		)
		begin
			set @msg = N'Please input Notes in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no							   = @p_application_no
					and isnull(economic_sector_evaluation, '') = ''
		)
		begin
			set @msg = N'Please input Economic Sector Evolution in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no				  = @p_application_no
					and isnull(pemberi_kerja, '') = ''
		)
		begin
			set @msg = N'Please input Pemberi Kerja in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no						= @p_application_no
					and isnull(kelas_pemberi_kerja, '') = ''
		)
		begin
			set @msg = N'Please input Kelas Pemberi Kerja in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no					 = @p_application_no
					and isnull(management_style, '') = ''
		)
		begin
			set @msg = N'Please input Management Style in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no					  = @p_application_no
					and isnull(lokasi_area_kerja, '') = ''
		)
		begin
			set @msg = N'Please input Lokasi Area Kerja in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no				 = @p_application_no
					and isnull(no_of_client, '') = ''
		)
		begin
			set @msg = N'Please input No Of Client in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no				   = @p_application_no
					and isnull(no_of_employee, '') = ''
		)
		begin
			set @msg = N'Please input No Of Employee in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no					   = @p_application_no
					and isnull(business_expansion, '') = ''
		)
		begin
			set @msg = N'Please input Business Expansion in Survey Business/Office Information' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey MO
		if exists
		(
			select	1
			from	dbo.application_survey
			where	application_no			   = @p_application_no
					and isnull(mo_summary, '') = ''
		)
		begin
			set @msg = N'Please input Strength Point & Recomendation in Survey MO Summary' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey project lesse
		if not exists
		(
			select	1
			from	dbo.application_survey_project
			where	application_survey_code = @survey_code
		)
		begin
			set @msg = N'Please input Project Lessee in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey_project
			where	application_survey_code		 = @survey_code
					and isnull(project_name, '') = ''
		)
		begin
			set @msg = N'Please input Project Name in Survey Project Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey_project
			where	application_survey_code		  = @survey_code
					and isnull(project_owner, '') = ''
		)
		begin
			set @msg = N'Please input Pemilik Tambang/ Kebun/ Project/ Produsen in Project Lessee' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey credit review analyt

		-- survey
		if exists
		(
			select	1
			from	dbo.application_survey
			where	code						  = @survey_code
					and isnull(date_of_visit, '') = ''
		)
		begin
			set @msg = N'Please input Date Of Visit in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	code				 = @survey_code
					and isnull(time, '') = ''
		)
		begin
			set @msg = N'Please input Survey Time in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	code						  = @survey_code
					and isnull(survey_method, '') = ''
		)
		begin
			set @msg = N'Please input Survey Method in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	code					= @survey_code
					and isnull(venue_1, '') = ''
		)
		begin
			set @msg = N'Please input Venue 1 in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	code					= @survey_code
					and isnull(venue_2, '') = ''
		)
		begin
			set @msg = N'Please input Venue 2 in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey
			where	code					= @survey_code
					and isnull(project, '') = ''
		)
		begin
			set @msg = N'Please Choose Project in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- survey trade checking
		if exists
		(
			select	1
			from	dbo.application_survey
			where	code					 = @survey_code
					and isnull(category, '') = ''
		)
		begin
			set @msg = N'Please Choose Category in Survey Trade Checking' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if not exists
		(
			select	1
			from	dbo.application_survey
			where	code					 = @survey_code
					and isnull(category, '') = 'RO'
		)
		begin
			if exists
			(
				select	1
				from	dbo.application_survey
				where	code								= @survey_code
						and isnull(trade_checking_date, '') = ''
			)
			begin
				set @msg = N'Please Input Date in Survey Trade Checking' ;

				raiserror(@msg, 16, -1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_survey
				where	code						   = @survey_code
						and isnull(interview_name, '') = ''
			)
			begin
				set @msg = N'Please Input Interview Name in Survey Trade Checking' ;

				raiserror(@msg, 16, -1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_survey
				where	code							  = @survey_code
						and
						(
							isnull(area_phone_number, '') = ''
							or	isnull(phone_number, '')  = ''
						)
			)
			begin
				set @msg = N'Please Input Phone Number in Survey Trade Checking' ;

				raiserror(@msg, 16, -1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_survey
				where	code								  = @survey_code
						and isnull(trade_checking_result, '') = ''
			)
			begin
				set @msg = N'Please Choose Result in Survey Trade Checking' ;

				raiserror(@msg, 16, -1) ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_survey
				where	code								 = @survey_code
						and isnull(trade_checking_notes, '') = ''
			)
			begin
				set @msg = N'Please Input Notes in Survey Trade Checking' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		-- foto & doc
		if not exists
		(
			select	1
			from	dbo.application_survey_document
			where	application_survey_code = @survey_code
		)
		begin
			set @msg = N'Please input Foto and Document in Survey' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey_document
			where	application_survey_code	 = @survey_code
					and isnull(location, '') = ''
		)
		begin
			set @msg = N'Please input Location in Survey Foto and Document' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_survey_document
			where	application_survey_code = @survey_code
					and isnull(remark, '')	= ''
		)
		begin
			set @msg = N'Please input Remarks in Survey Foto and Document' ;

			raiserror(@msg, 16, -1) ;
		end ;
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
