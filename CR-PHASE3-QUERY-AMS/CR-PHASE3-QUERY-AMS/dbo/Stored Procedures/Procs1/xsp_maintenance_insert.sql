CREATE PROCEDURE [dbo].[xsp_maintenance_insert]
(
	@p_code							nvarchar(50) output
	,@p_company_code				nvarchar(50)
	,@p_asset_code					nvarchar(50)
	,@p_transaction_date			datetime
	,@p_transaction_amount			decimal(18, 2)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_requestor_code				nvarchar(50)
	,@p_requestor_name				nvarchar(250)
	,@p_division_code				nvarchar(50)	= ''
	,@p_division_name				nvarchar(250)	= ''
	,@p_department_code				nvarchar(50)	= ''
	,@p_department_name				nvarchar(250)	= ''
	,@p_status						nvarchar(20)
	,@p_maintenance_by				nvarchar(50)
	,@p_vendor_code					nvarchar(50)	= ''
	,@p_vendor_name					nvarchar(250)	= ''
	,@p_remark						nvarchar(4000)	= ''
	,@p_actual_km					int				= 0
	,@p_work_date					datetime		--= null
	,@p_service_type				nvarchar(20)	= ''
	,@p_hour_meter					int				= null
	,@p_vendor_city_name 			nvarchar(250)	= ''
	,@p_vendor_province_name 		nvarchar(250)	= ''
	,@p_vendor_address 				nvarchar(4000)	= ''
	,@p_vendor_phone				nvarchar(50)	= ''
	,@p_vendor_bank_name			nvarchar(250)	= ''
	,@p_vendor_bank_account_no		nvarchar(50)	= ''
	,@p_vendor_bank_account_name	nvarchar(250)	= ''
	,@p_vendor_npwp					nvarchar(20)	= ''
	,@p_is_reimburse				nvarchar(1)		= ''
	,@p_bank_code					nvarchar(50)	= ''
	,@p_bank_name					nvarchar(50)	= ''
	,@p_bank_account_no				nvarchar(50)	= ''
	,@p_bank_account_name			nvarchar(50)	= ''
	,@p_vendor_type					nvarchar(25)	= ''
	,@p_sa_vendor_name				nvarchar(50)	= ''
	,@p_sa_vendor_area_phone		nvarchar(5)		= ''
	,@p_sa_vendor_phone_no			nvarchar(20)	= ''
	,@p_free_service				nvarchar(1)		= ''
	,@p_file_name					nvarchar(250)	= ''
	,@p_file_path					nvarchar(250)	= ''
	,@p_estimated_start_date		datetime		= null
	,@p_estimated_finish_date		datetime		= null
	,@p_call_center_ticket_no		nvarchar(50)	= null
	,@p_is_request_replacement		nvarchar(1)
	,@p_delivery_address			nvarchar(4000)	= null
	,@p_contact_name				nvarchar(250)	= null
	,@p_contact_phone_no			nvarchar(50)	= null
	,@p_reason_code					nvarchar(50)	= null
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(50)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(50)
)
as
begin
	declare @msg				nvarchar(max)
			,@year				nvarchar(4) 
			,@month				nvarchar(2)
			,@code				nvarchar(50)
			,@service_code		nvarchar(50)
			,@service_name		nvarchar(250)
			,@id				bigint
			,@service_type		nvarchar(50)
			,@vendor_type		nvarchar(50)
			,@last_km_service	int

	begin try

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;


	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			 = @code output
												,@p_branch_code			 = @p_branch_code
												,@p_sys_document_code	 = ''
												,@p_custom_prefix		 = 'MN'
												,@p_year				 = @year
												,@p_month				 = @month
												,@p_table_name			 = 'MAINTENANCE'
												,@p_run_number_length	 = 5
												,@p_delimiter			= '.'
												,@p_run_number_only		 = '0' ;


		--validasi jika tidak ada npwp atau ktp vendor
		if(@p_vendor_code <> '')
		begin
			select @vendor_type = vendor_type 
			from ifinbam.dbo.master_vendor
			where code = @p_vendor_code

			if(@vendor_type = 'P')
			begin
				if exists(select 1 from ifinbam.dbo.master_vendor where isnull(id_no,'') = '' and code = @p_vendor_code)
				begin
					set @msg = 'Please input KTP in Vendor.';
					raiserror(@msg ,16,-1);	   
				end
			end
			else
			begin
				if exists(select 1 from ifinbam.dbo.master_vendor where isnull(npwp,'') = '' and code = @p_vendor_code)
				begin
					set @msg = 'Please input NPWP in Vendor.';
					raiserror(@msg ,16,-1);	 
				end
			end
		end

		-- Hari - 19.Jun.2023 03:08 PM --	validasi harus ada agreement no jika maintenence by client
		if (@p_maintenance_by ='CST')
		begin
			if  not exists(select 1 from dbo.asset where code = @p_asset_code and isnull(agreement_no,'') <> '') 
			begin
				set @msg = 'Please change Maintenance By, this asset is not currently rented.';
				raiserror(@msg ,16,-1);	   
			end 	
		end 	
		-- Hari - 19.Jun.2023 03:08 PM --	validasi harus ada agreement no jika reimburse ti client
		if (@p_maintenance_by ='EXT' and  @p_is_reimburse = 'T' )
		begin
			if not exists (select 1 from dbo.asset where code = @p_asset_code and isnull(agreement_no,'') <> '') 
				begin
				set @msg = 'This asset cannot reimburse to customer, this asset is not currently rented.';
				raiserror(@msg ,16,-1);	   
			end 
		end 

		if @p_is_reimburse = 'T'
			set @p_is_reimburse = '1' ;
		else
			set @p_is_reimburse = '0' ;

		if @p_free_service = 'T'
			set @p_free_service = '1' ;
		else
			set @p_free_service = '0' ;

		if @p_is_request_replacement = 'T'
			set @p_is_request_replacement = '1' ;
		else
			set @p_is_request_replacement = '0' ;

		if @p_is_reimburse='1'
		begin
			if exists (select 1 from dbo.asset where code = @p_asset_code and isnull(agreement_no,'') = '')
			begin
					--set @msg = 'Cannot used this asset. Check again whether the agreement no, client no, client name has been input.';
					set @msg = 'Cannot used this asset, because Agreement No is empty.';
					raiserror(@msg ,16,-1);	   
			end
			else if exists (select 1 from dbo.asset where code = @p_asset_code and isnull(CLIENT_NO,'')='' )
			begin
				set @msg = 'Cannot used this asset, because Client No is empty.';
				raiserror(@msg ,16,-1);	
			end
			else if exists (select 1 from dbo.asset where code = @p_asset_code and isnull(client_name,'')='')
			begin
				set @msg = 'Cannot used this asset, because Client Name is empty.';
				raiserror(@msg ,16,-1);	
			end
		end ;

		select	@p_division_code		= isnull(division_code,'')
				,@p_division_name		= isnull(division_name,'')
				,@p_department_code		= isnull(department_code,'')
				,@p_department_name		= isnull(department_name,'')
				,@last_km_service		= last_km_service
		from	dbo.asset
		where	code = @p_asset_code

		-- (+) Ari 2024-02-01 ket : nama , alamat vendor ambil dari npwp | 2024-02-12 ket : di isi memang nama vendor bukan npwp
		--declare @npwp_name		nvarchar(50)
		--		,@npwp_address	nvarchar(250)

		--select	@npwp_name = npwp_name
		--		,@npwp_address = npwp_address 
		--from	ifinbam.dbo.master_vendor
		--where	code = @p_vendor_code

		--if(isnull(@npwp_name,'') = '')
		--begin
		--	set @npwp_name = @p_vendor_name
		--end
		--else if(isnull(@npwp_address,'') = '')
		--begin
		--	set @npwp_address = @p_vendor_address
		--end

		-- (+) Ari 2024-02-01
	 
		insert into maintenance
		(
			code
			,company_code
			,asset_code
			,transaction_date
			,transaction_amount
			,branch_code
			,branch_name
			,requestor_code
			,requestor_name
			,division_code
			,division_name
			,department_code
			,department_name
			,status
			,maintenance_by
			,vendor_code
			,vendor_name
			,remark
			,actual_km
			,work_date
			,service_type
			,hour_meter
			,vendor_city_name	
			,vendor_province_name
			,vendor_address	
			,vendor_phone	
			,vendor_bank_name
			,vendor_bank_account_no
			,vendor_bank_account_name
			,vendor_npwp
			,vendor_type
			,is_reimburse	
			,bank_code		
			,bank_name		
			,bank_account_no	
			,bank_account_name
			,sa_vendor_name
			,sa_vendor_area_phone
			,sa_vendor_phone_no
			,free_service
			,last_km_service
			,file_name
			,file_path
			,estimated_start_date
			,estimated_finish_date
			,call_center_ticket_no
			,is_request_replacement
			,delivery_address
			,contact_name
			,contact_phone_no
			,reason_code
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_company_code
			,@p_asset_code
			,@p_transaction_date
			,@p_transaction_amount
			,@p_branch_code
			,@p_branch_name
			,@p_requestor_code
			,@p_requestor_name
			,@p_division_code
			,@p_division_name
			,@p_department_code
			,@p_department_name
			,@p_status
			,@p_maintenance_by
			,@p_vendor_code
			,@p_vendor_name
			--,@npwp_name -- (+) Ari 2024-02-01
			,@p_remark
			,@p_actual_km
			,@p_work_date
			,@p_service_type
			,@p_hour_meter
			,@p_vendor_city_name 		
			,@p_vendor_province_name 	
			,@p_vendor_address 			
			--,@npwp_address --(+) Ari 2024-02-01
			,@p_vendor_phone			
			,@p_vendor_bank_name
			,@p_vendor_bank_account_no	
			,@p_vendor_bank_account_name
			,@p_vendor_npwp
			,@p_vendor_type
			,@p_is_reimburse	
			,@p_bank_code		
			,@p_bank_name		
			,@p_bank_account_no	
			,@p_bank_account_name
			,@p_sa_vendor_name		
			,@p_sa_vendor_area_phone
			,@p_sa_vendor_phone_no
			,@p_free_service
			,@last_km_service
			,@p_file_name
			,@p_file_path
			,@p_estimated_start_date
			,@p_estimated_finish_date
			,@p_call_center_ticket_no
			,@p_is_request_replacement
			,@p_delivery_address
			,@p_contact_name
			,@p_contact_phone_no
			,@p_reason_code
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		)set @p_code = @code ;

		--Langsung insert ke detail ambil dari asset maintenance schedule yang kurang dari work date atau KM/Hour Meter
		if(@p_service_type = 'ROUTINE')
		begin
			declare curr_maintenance cursor fast_forward read_only for

			select	distinct
					service_code
					,service_name
					,id
					,service_type
			from	dbo.asset_maintenance_schedule
			where	id in
					(
						--select		max(id)
						--from		dbo.asset_maintenance_schedule
						--where		asset_code						= @p_asset_code
						--			and isnull(reff_trx_no,'')		= ''
						--			and maintenance_status			= 'SCHEDULE PENDING'
						--			and
						--			(
						--				maintenance_date   <= @p_work_date
						--				or	miles		   <= @p_actual_km
						--				or	hour		   <= @p_hour_meter
						--			)
						--group by	service_code,service_name
						select		top 1
									ID
						from		dbo.asset_maintenance_schedule
						where		asset_code					= @p_asset_code
									and isnull(reff_trx_no, '') = ''
									and maintenance_status		= 'SCHEDULE PENDING'
									and
									(
										maintenance_date		<= @p_work_date
										or	miles				<= @p_actual_km
										or	hour				<= @p_hour_meter
									)
						order by	MAINTENANCE_DATE desc
					); ;
			
			open curr_maintenance
			
			fetch next from curr_maintenance 
			into @service_code
				,@service_name
				,@id
				,@service_type
			
			while @@fetch_status = 0
			begin
			    exec dbo.xsp_maintenance_detail_insert @p_id								= 0
														,@p_maintenance_code				= @code
														,@p_service_code					= @service_code
														,@p_service_name					= @service_name
														,@p_file_name						= null
														,@p_path							= null
														,@p_quantity						= 0
														,@p_pph_amount						= 0
														,@p_ppn_amount						= 0
														,@p_service_amount					= 0
														,@p_service_type					= @service_type
														,@p_asset_maintenance_schedule_id	= @id
														,@p_cre_date						= @p_cre_date
														,@p_cre_by							= @p_cre_by
														,@p_cre_ip_address					= @p_cre_ip_address
														,@p_mod_date						= @p_mod_date
														,@p_mod_by							= @p_mod_by
														,@p_mod_ip_address					= @p_mod_ip_address
			
			    fetch next from curr_maintenance 
				into @service_code
					,@service_name
					,@id
					,@service_type
			end
			
			close curr_maintenance
			deallocate curr_maintenance
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
end ;
