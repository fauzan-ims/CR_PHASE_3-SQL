--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_update
(
	@p_code							   nvarchar(50)
	,@p_application_no				   nvarchar(50)
	,@p_nama							nvarchar(250) = ''
	,@p_application_type				nvarchar(3)	  = ''
	,@p_group_name						nvarchar(250) = ''
	,@p_alamat_kantor					nvarchar(4000)= ''
	,@p_alamat_kantor_kota				nvarchar(250) = ''
	,@p_alamat_kantor_provinsi			nvarchar(250) = ''
	,@p_alamat_usaha					nvarchar(4000)= ''
	,@p_alamat_usaha_kota				nvarchar(250) = ''
	,@p_alamat_usaha_provinsi			nvarchar(250) = ''
	,@p_alamat_sejak_usaha				datetime	  = ''
	,@p_komoditi						nvarchar(4000)= ''
	,@p_tujuan_pengadaan_unit			nvarchar(4000)= ''
	,@p_as_of_date						DATETIME	= 0
	,@p_monthly_sales					decimal(18, 2) = 0
	,@p_total_monthly_expense			decimal(18, 2) = 0
	,@p_total_monthly_installment		decimal(18, 2) = 0
	,@p_total_monthly_installment_other decimal(18, 2) = 0
	,@p_net_income						decimal(18, 2) = 0
	,@p_overall_assessment				nvarchar(15)	= ''
	,@p_notes							nvarchar(4000)	= ''
	,@p_economic_sector_evaluation		nvarchar(30)	= ''
	,@p_pemberi_kerja					nvarchar(250)	= ''
	,@p_kelas_pemberi_kerja				nvarchar(30)	= ''
	,@p_management_style				nvarchar(30)	= ''
	,@p_lokasi_area_kerja				nvarchar(4000)	= ''
	,@p_no_of_client					nvarchar(30)	= ''
	,@p_no_of_employee					nvarchar(30)	= ''
	,@p_credit_line_of_bank				nvarchar(30)	= ''
	,@p_business_expansion				nvarchar(30)	= ''
	,@p_mo_summary						nvarchar(4000)	= ''
	,@p_capacity						nvarchar(4000)	= ''
	,@p_character						nvarchar(4000)	= ''
	,@p_strength						nvarchar(4000)	= ''
	,@p_weakness						nvarchar(4000)	= ''
	,@p_date_of_visit					datetime= 0
	,@p_time							nvarchar(15)	= ''
	,@p_survey_method					nvarchar(30)	= ''
	,@p_venue_1							nvarchar(4000)	= ''
	,@p_venue_2							nvarchar(4000)	= ''
	,@p_project							nvarchar(30)	= ''
	,@p_category						nvarchar(30)	= ''
	,@p_trade_checking_date				datetime= 0
	,@p_interview_name					nvarchar(250)  = ''
	,@p_area_phone_number				nvarchar(4)	   = ''
	,@p_phone_number					nvarchar(15)   = ''
	,@p_trade_checking_result			nvarchar(30)   = ''
	,@p_trade_checking_notes			nvarchar(4000) = ''
	--
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@rental_amount	decimal(18,2)
			-- (+) Ari 2024-02-16 ket : add client no for checking application progress
			,@client_no					nvarchar(50)
			,@client_code_check			nvarchar(50)
			,@amount_contract			decimal(18,2)
			,@amount_application		decimal(18,2)

	begin try

		--select	@rental_amount = rental_amount
		--from	dbo.application_main
		--where	application_no = @p_application_no ;
		 
		-- (+) Ari 2024-02-13 ket : change mengambil rental per bulan

		declare @table_temp	table
		(
			client				nvarchar(50)
		)

		declare @table_temp2 table
		(
			monthly_rental_rounded_amount	decimal(18,2)
			,agreement_no					nvarchar(50)
			,application_no					nvarchar(50)
			,asset_no						nvarchar(50)
		)

		declare @table_temp3 table
		(
			monthly_rental_rounded_amount	decimal(18,2)
			,application_no					nvarchar(50)
			,asset_no						nvarchar(50)
		)

		select	@client_no = cm.client_no		 
		from	dbo.application_main am
		inner	join dbo.client_main cm on (cm.code = am.client_code)
		where	am.application_no = @p_application_no

		insert into @table_temp
		(
			client
		)
		select	code 
		from	dbo.client_main
		where	client_no = @client_no

		-- check monthly_rental_rounded_amount kontrak aktif
		insert into @table_temp2
		(
			monthly_rental_rounded_amount
			,agreement_no
			,application_no
			,asset_no
		)
		select	cast(
					case	apm.billing_type
							when 'MNT'
							then isnull(aas.lease_rounded_amount,0)
							when 'BIM'
							then isnull(aas.lease_rounded_amount,0) / 2
							when 'QRT'
							then isnull(aas.lease_rounded_amount,0) / 3
							when 'SMA'
							then isnull(aas.lease_rounded_amount,0) / 6
							else isnull(aas.lease_rounded_amount,0) / 12
					end 
					as decimal(18,2)
					)
				,aas.agreement_no
				,agm.application_no
				,aas.asset_no
		from	@table_temp temp
		inner	join dbo.application_main	apm on (apm.client_code = temp.client)
		inner	join dbo.agreement_main		agm on (agm.application_no = apm.application_no)
		inner	join dbo.agreement_asset	aas on (aas.agreement_no = agm.agreement_no)
		where	aas.asset_status = 'RENTED'

		-- check monthly_rental_rounded_amount application on progress
		insert into @table_temp3
		(
			monthly_rental_rounded_amount
			,application_no
			,asset_no
		)
		select	cast(
					case	apm.billing_type
							when 'MNT'
							then isnull(aas.lease_rounded_amount,0)
							when 'BIM'
							then isnull(aas.lease_rounded_amount,0) / 2
							when 'QRT'
							then isnull(aas.lease_rounded_amount,0) / 3
							when 'SMA'
							then isnull(aas.lease_rounded_amount,0) / 6
							else isnull(aas.lease_rounded_amount,0) / 12
					end 
					as decimal(18,2)
					)
				,apm.application_no
				,aas.asset_no
		from	@table_temp temp
		inner	join dbo.application_main	apm on (apm.client_code = temp.client)
		inner	join dbo.application_asset	aas on (aas.application_no = apm.application_no)
		where	apm.application_status not in ('CANCEL','REJECT')
		and		apm.application_no not in (select am.application_no from dbo.agreement_main am where am.application_no = apm.application_no)

		declare @monthly_rental_rounded_amount	decimal(18,2)
				,@agreement_no					nvarchar(50)
				,@application_no				nvarchar(50)
				,@asset_no						nvarchar(50)

		-- looping for checking contract active monthly_rental_rounded_amount
		declare curr_upd_monthly_rental_rounded_amount cursor fast_forward read_only for 
		select	monthly_rental_rounded_amount
				,agreement_no
				,application_no
				,asset_no 
		from	@table_temp2
		open curr_upd_monthly_rental_rounded_amount
		
		fetch next from curr_upd_monthly_rental_rounded_amount 
		into	@monthly_rental_rounded_amount
				,@agreement_no
				,@application_no
				,@asset_no
		
		while @@fetch_status = 0
		begin
		    
			if exists (select 1 from dbo.agreement_asset aas where aas.agreement_no = @agreement_no and aas.asset_no = @asset_no and isnull(aas.monthly_rental_rounded_amount,0) = 0)
			begin
				update	dbo.agreement_asset
				set		monthly_rental_rounded_amount = @monthly_rental_rounded_amount
				where	agreement_no = @agreement_no
				and		asset_no = @asset_no
			end
			
			if exists (select 1 from dbo.application_asset aas where aas.application_no = @application_no and aas.asset_no = @asset_no and isnull(aas.monthly_rental_rounded_amount,0) = 0)
			begin  
				update	dbo.application_asset 
				set		monthly_rental_rounded_amount = @monthly_rental_rounded_amount
				where	application_no = @application_no
				and		asset_no = @asset_no
			end

		    fetch next from curr_upd_monthly_rental_rounded_amount 
			into	@monthly_rental_rounded_amount
					,@agreement_no
					,@application_no
					,@asset_no
		end
		
		close curr_upd_monthly_rental_rounded_amount
		deallocate curr_upd_monthly_rental_rounded_amount


		-- looping for checking application onprogress monthly_rental_rounded_amount
		declare curr_upd_monthly_rental_rounded_amount2 cursor fast_forward read_only for 
		select	monthly_rental_rounded_amount
				,application_no
				,asset_no 
		from	@table_temp3
		open curr_upd_monthly_rental_rounded_amount2
		
		fetch next from curr_upd_monthly_rental_rounded_amount2 
		into	@monthly_rental_rounded_amount
				,@application_no
				,@asset_no
		
		while @@fetch_status = 0
		begin
			
			if exists (select 1 from dbo.application_asset aas where aas.application_no = @application_no and aas.asset_no = @asset_no and isnull(aas.monthly_rental_rounded_amount,0) = 0)
			begin  
				update	dbo.application_asset 
				set		monthly_rental_rounded_amount = @monthly_rental_rounded_amount
				where	application_no = @application_no
				and		asset_no = @asset_no
			end

		    fetch next from curr_upd_monthly_rental_rounded_amount2 
			into	@monthly_rental_rounded_amount
					,@application_no
					,@asset_no
		end
		
		close curr_upd_monthly_rental_rounded_amount2
		deallocate curr_upd_monthly_rental_rounded_amount2

		-- kontrak aktif berdasarkan client
		select	@amount_contract = sum(ast.monthly_rental_rounded_amount) 
		from	dbo.agreement_asset ast
		outer	apply (
						select	distinct
								aas.asset_no
						from	@table_temp temp
						inner	join dbo.client_main					cm  on (cm.code = temp.client)
						outer	apply (
										select	aas.asset_no
										from	dbo.agreement_asset		aas
										inner	join dbo.agreement_main am on (am.agreement_no = aas.agreement_no and am.client_no = cm.client_no)
										where	aas.asset_status = 'RENTED'
									  ) aas
					  ) asset
		where	ast.asset_no = asset.asset_no


		-- application aktif berdasarkan client
		select	@amount_application = sum(aas.monthly_rental_rounded_amount)
		from	@table_temp temp
		inner	join dbo.application_main				apm on (apm.client_code = temp.client)
		inner	join dbo.application_asset				aas on (aas.application_no = apm.application_no)
		where	apm.application_status not in ('CANCEL','REJECT')
		and		apm.application_no not in (select am.application_no from dbo.agreement_main am where am.application_no = apm.application_no)

		-- amount kontrak aktif + amount applikasi aktif per bulan nya
		set @rental_amount = isnull(@amount_contract,0) + isnull(@amount_application,0)
		-- (+) Ari 2024-02-13 ket : add net income rumus = monthly sales - (total monthly expense + total monthly ins DSF + total monthly ins other)
		set @p_net_income = isnull(@p_monthly_sales,0) - (isnull(@p_total_monthly_expense,0) + isnull(isnull(@p_total_monthly_installment,@rental_amount),0) + isnull(@p_total_monthly_installment_other,0))


		-- (+) Ari 2024-01-02 ket : mandatory
		if(isnull(@p_application_type,'') = '')
		begin
			set @msg = 'Please choose application type'
			raiserror (@msg, 16, -1);
		end

		update	dbo.application_survey
		set		--nama							= @p_nama
				application_type				= @p_application_type
				--,group_name					= @p_group_name
				--,alamat_kantor				= @p_alamat_kantor
				--,alamat_kantor_kota			= @p_alamat_kantor_kota
				--,alamat_kantor_provinsi		= @p_alamat_kantor_provinsi
				--,alamat_usaha					= @p_alamat_usaha
				--,alamat_usaha_kota			= @p_alamat_usaha_kota
				--,alamat_usaha_provinsi		= @p_alamat_usaha_provinsi
				--,alamat_sejak_usaha			= @p_alamat_sejak_usaha
				,komoditi						= @p_komoditi
				,tujuan_pengadaan_unit			= @p_tujuan_pengadaan_unit
				,as_of_date						= @p_as_of_date
				,monthly_sales					= @p_monthly_sales
				,total_monthly_expense			= @p_total_monthly_expense
				,total_monthly_installment		= @rental_amount
				,total_monthly_installment_other = @p_total_monthly_installment_other
				,net_income						= @p_net_income
				,overall_assessment				= @p_overall_assessment
				,notes							= @p_notes
				,economic_sector_evaluation		= @p_economic_sector_evaluation
				,pemberi_kerja					= @p_pemberi_kerja
				,kelas_pemberi_kerja			= @p_kelas_pemberi_kerja
				,management_style				= @p_management_style
				,lokasi_area_kerja				= @p_lokasi_area_kerja
				,no_of_client					= @p_no_of_client
				,no_of_employee					= @p_no_of_employee
				,credit_line_of_bank			= @p_credit_line_of_bank
				,business_expansion				= @p_business_expansion
				,mo_summary						= @p_mo_summary
				,capacity						= @p_capacity
				,character						= @p_character
				,strength						= @p_strength
				,weakness						= @p_weakness
				,date_of_visit					= @p_date_of_visit
				,time							= @p_time
				,survey_method					= @p_survey_method
				,venue_1						= @p_venue_1
				,venue_2						= @p_venue_2
				,project						= @p_project
				,category						= @p_category
				,trade_checking_date			= @p_trade_checking_date
				,interview_name					= @p_interview_name
				,area_phone_number				= @p_area_phone_number
				,phone_number					= @p_phone_number
				,trade_checking_result			= @p_trade_checking_result
				,trade_checking_notes			= @p_trade_checking_notes
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	application_no					= @p_application_no
				and code						= @p_code ;
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
