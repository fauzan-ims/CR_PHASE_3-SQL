-- Louis Selasa, 02 April 2024 17.07.45 --
CREATE PROCEDURE [dbo].[xsp_application_survey_copy_with_limitation]
(
	@p_client_no			nvarchar(50)
	,@p_application_no		nvarchar(50)
	,@p_old_application_no	nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg					 nvarchar(max)
			,@group_name			 nvarchar(250)	 = ''
			,@komoditi				 nvarchar(250)	 = ''
			,@tujuan_pengadaan		 nvarchar(250)	 = ''
			,@as_of_date			 datetime
			,@monthly_sales			 decimal(18, 2)	 = 0
			,@total_monthly_exp		 decimal(18, 2)	 = 0
			,@total_monthly_ins		 decimal(18, 2)	 = 0
			,@total_monthly_oth		 decimal(18, 2)	 = 0
			,@net_income			 decimal(18, 2)  = 0
			,@mo_summary			 nvarchar(500)	 = ''
			,@capacity				 nvarchar(250)	 = ''
			,@character				 nvarchar(250)	 = ''
			,@strength				 nvarchar(250)	 = ''
			,@weakness				 nvarchar(250)	 = ''
			,@date_of_visit			 datetime
			,@time					 nvarchar(250)	 = ''
			,@surv_method			 nvarchar(250)	 = ''
			,@venue1				 nvarchar(250)	 = ''
			,@venue2				 nvarchar(250)	 = ''
			,@project				 nvarchar(250)	 = ''
			,@category				 nvarchar(250)	 = ''
			,@trade_check			 datetime
			,@interview_name		 nvarchar(250)	 = ''
			,@area_phone			 nvarchar(50)	 = ''
			,@phone_number			 nvarchar(50)	 = ''
			,@trade_check_rslt		 nvarchar(250)	 = ''
			,@trade_check_notes		 nvarchar(250) 	 = ''
			,@location				 nvarchar(4000)	 = ''
			,@remark				 nvarchar(4000)	 = ''
			,@file_name				 nvarchar(250)	 = ''
			,@path					 nvarchar(250) 	 = ''
			,@rental_company		 nvarchar(250)	 = ''
			,@unit_kendaraan		 int			 = 0
			,@jenis_kendaraan		 nvarchar(250)	 = ''
			,@os_period				 int			 = 0
			,@nilai_pinjaman		 decimal(18, 2)	 = 0
			,@client_code			 nvarchar(50) 	 = ''
			,@p_code				 nvarchar(50)	 = ''
			,@supplier_code			 nvarchar(50)	 = ''

	begin try 

		select	@group_name = group_name
				,@komoditi = komoditi
				,@tujuan_pengadaan = tujuan_pengadaan_unit
				,@as_of_date = as_of_date
				,@monthly_sales = monthly_sales
				,@total_monthly_exp = total_monthly_expense
				,@total_monthly_ins = total_monthly_installment
				,@total_monthly_oth = total_monthly_installment_other
				,@net_income = net_income 
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
		where	application_no = @p_old_application_no ;
		
		select	@p_code = code
		from	dbo.application_survey
		where	application_no = @p_application_no ;
		 
		update dbo.application_survey 
		set	   application_type					= N'RO'
			   ,group_name						= @group_name
			   ,komoditi						= @komoditi						
			   ,tujuan_pengadaan_unit			= @tujuan_pengadaan			
			   ,as_of_date						= @as_of_date						
			   ,monthly_sales					= @monthly_sales					
			   ,total_monthly_expense			= @total_monthly_exp			
			   ,total_monthly_installment		= @total_monthly_ins		
			   ,total_monthly_installment_other	= @total_monthly_oth	
			   ,net_income						= @net_income						
			   ,mo_summary						= @mo_summary			
			   ,capacity						= @capacity				
			   ,character						= @character			
			   ,strength						= @strength				
			   ,weakness						= @weakness				
			   ,date_of_visit					= @date_of_visit		
			   ,time							= @time					
			   ,survey_method					= @surv_method		
			   ,venue_1							= @venue1				
			   ,venue_2							= @venue2				
			   ,project							= @project				
			   ,category						= @category				
			   ,trade_checking_date				= @trade_check
			   ,interview_name					= @interview_name		
			   ,area_phone_number				= @area_phone
			   ,phone_number					= @phone_number			
			   ,trade_checking_result			= @trade_check_rslt
			   ,trade_checking_notes			= @trade_check_notes
			   --
				,@p_mod_date					= @p_mod_date
				,@p_mod_by						= @p_mod_by
				,@p_mod_ip_address				= @p_mod_ip_address
		where code								= @p_code
		 
		-- application_survey_document
		begin
			declare curr_surv_doc cursor fast_forward read_only for
			select	location
					,remark
					,file_name
					,paths
			from	dbo.application_survey_document
			where	application_survey_code = @supplier_code ;

			open curr_surv_doc ;

			fetch next from curr_surv_doc
			into @location
				 ,@remark
				 ,@file_name
				 ,@path ;

			while @@fetch_status = 0
			begin
				declare @p_id3 bigint ;

				exec dbo.xsp_application_survey_document_insert @p_id = @p_id3 output
																,@p_application_survey_code = @p_code
																,@p_location = @location
																,@p_remark = @remark
																,@p_file_name = @file_name
																,@p_paths = @path
																,@p_cre_date = @p_cre_date
																,@p_cre_by = @p_cre_by
																,@p_cre_ip_address = @p_cre_ip_address
																,@p_mod_date = @p_mod_date
																,@p_mod_by = @p_mod_by
																,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_surv_doc
				into @location
					 ,@remark
					 ,@file_name
					 ,@path ;
			end ;

			close curr_surv_doc ;
			deallocate curr_surv_doc ;
		end
		 
		---- application_survey_other_lease
		begin
			declare curr_surv_otr_lease cursor fast_forward read_only for
			select	rental_company
					,unit
					,jenis_kendaraan
					,os_periode
					,nilai_pinjaman
			from	dbo.application_survey_other_lease
			where	application_survey_code = @supplier_code ;

			open curr_surv_otr_lease ;

			fetch next from curr_surv_otr_lease
			into @rental_company
				 ,@unit_kendaraan
				 ,@jenis_kendaraan
				 ,@os_period
				 ,@nilai_pinjaman ;

			while @@fetch_status = 0
			begin
				declare @p_id5 bigint ;

				exec dbo.xsp_application_survey_other_lease_insert @p_id = @p_id5 output
																   ,@p_application_survey_code = @p_code
																   ,@p_rental_company = @rental_company
																   ,@p_unit = @unit_kendaraan
																   ,@p_jenis_kendaraan = @jenis_kendaraan
																   ,@p_os_periode = @os_period
																   ,@p_nilai_pinjaman = @nilai_pinjaman
																   ,@p_cre_date = @p_cre_date
																   ,@p_cre_by = @p_cre_by
																   ,@p_cre_ip_address = @p_cre_ip_address
																   ,@p_mod_date = @p_mod_date
																   ,@p_mod_by = @p_mod_by
																   ,@p_mod_ip_address = @p_mod_ip_address ;

				fetch next from curr_surv_otr_lease
				into @rental_company
					 ,@unit_kendaraan
					 ,@jenis_kendaraan
					 ,@os_period
					 ,@nilai_pinjaman ;
			end ;

			close curr_surv_otr_lease ;
			deallocate curr_surv_otr_lease ;
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
