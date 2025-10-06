CREATE PROCEDURE [dbo].[xsp_maintenance_update]	
(
	@p_code							nvarchar(50)
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
	,@p_remark						nvarchar(4000)	= ''
	,@p_vendor_code					nvarchar(50)	= ''
	,@p_vendor_name					nvarchar(250)	= ''
	,@p_actual_km					int				= 0
	,@p_work_date					datetime		= null
	,@p_hour_meter					int				= 0
	,@p_vendor_city_name 			nvarchar(250)	= ''
	,@p_vendor_province_name 		nvarchar(250)	= ''
	,@p_vendor_address 				nvarchar(4000)	= ''
	,@p_vendor_phone				nvarchar(250)	= ''
	,@p_vendor_bank_name			nvarchar(250)	= ''
	,@p_vendor_bank_account_no		nvarchar(50)	= ''
	,@p_vendor_bank_account_name	nvarchar(250)	= ''
	,@p_vendor_npwp					nvarchar(20)	= ''
	,@p_vendor_type					nvarchar(25)	= ''
	,@p_is_reimburse				nvarchar(1)		= ''
	,@p_bank_code					nvarchar(50)	= ''
	,@p_bank_name					nvarchar(50)	= ''
	,@p_bank_account_no				nvarchar(50)	= ''
	,@p_bank_account_name			nvarchar(50)	= ''
	,@p_sa_vendor_name				nvarchar(50)	= ''
	,@p_sa_vendor_area_phone		nvarchar(5)		= ''
	,@p_sa_vendor_phone_no			nvarchar(20)	= ''
	,@p_free_service				nvarchar(1)		= ''
	,@p_estimated_start_date		datetime
	,@p_estimated_finish_date		datetime
	,@p_call_center_ticket_no		nvarchar(50)	= null
	,@p_is_request_replacement		nvarchar(1)	
	,@p_delivery_address			nvarchar(4000)	= null
	,@p_contact_name				nvarchar(250)	= null
	,@p_contact_phone_no			nvarchar(50)	= null
	,@p_reason_code					nvarchar(50)	= null
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(50)
)
as
begin
	declare @msg					nvarchar(max)
			,@service_code			nvarchar(50)
			,@service_name			nvarchar(250)
			,@id					bigint
			,@service_type			nvarchar(50)
			,@transaction_date		datetime
			,@vendor_type			nvarchar(50)
			,@budget_replacement	decimal(18,2)

	begin TRY
		IF (@p_estimated_start_date < dbo.xfn_get_system_date())
		BEGIN
		    	set @msg = 'Estimated Start Date must be greather than System Date';
				raiserror(@msg, 16, -1) ;
		END
		IF (@p_estimated_finish_date < dbo.xfn_get_system_date())
		BEGIN
		    	set @msg = 'Estimated Finish Date must be greather than System Date';
				raiserror(@msg, 16, -1) ;
		END
		IF (@p_estimated_finish_date < @p_estimated_start_date)
		BEGIN
		    	set @msg = 'Estimated Finish Date must be greather than Estimated Start Date';
				raiserror(@msg, 16, -1) ;
		END



		--validasi jika tidak ada npwp atau ktp vendor
		IF(@p_vendor_code <> '')
		BEGIN
			SELECT @vendor_type = vendor_type 
			FROM ifinbam.dbo.master_vendor
			WHERE code = @p_vendor_code

			IF(@vendor_type = 'P')
			BEGIN
				IF EXISTS(SELECT 1 FROM ifinbam.dbo.master_vendor WHERE ISNULL(id_no,'') = '' AND code = @p_vendor_code)
				BEGIN
					SET @msg = 'Please input KTP in Vendor.';
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

		if @p_is_reimburse = '1'
		begin
			if exists
			(
				select	1
				from	dbo.asset
				where	code						 = @p_asset_code
						and isnull(agreement_no, '') = ''
						and isnull(CLIENT_NO, '')	 = ''
						and isnull(client_name, '')	 = ''
			)
			begin
				set @msg = N'Cannot used this asset. Check again whether the agreement no, client no, client name has been input.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		update	maintenance
		set		company_code				= @p_company_code
				,asset_code					= @p_asset_code
				,transaction_date			= @p_transaction_date
				,transaction_amount			= @p_transaction_amount
				,branch_name				= @p_branch_name
				,requestor_code				= @p_requestor_code
				,requestor_name				= @p_requestor_name
				,division_code				= @p_division_code
				,division_name				= @p_division_name
				,department_code			= @p_department_code
				,department_name			= @p_department_name
				,status						= @p_status
				,maintenance_by				= @p_maintenance_by
				,remark						= @p_remark
				,vendor_code				= @p_vendor_code
				,vendor_name				= @p_vendor_name
				,actual_km					= @p_actual_km
				,work_date					= @p_work_date
				,hour_meter					= @p_hour_meter
				,vendor_city_name			= @p_vendor_city_name 		
				,vendor_province_name		= @p_vendor_province_name 	
				,vendor_address				= @p_vendor_address 			
				,vendor_phone				= @p_vendor_phone			
				,vendor_bank_name			= @p_vendor_bank_name		
				,vendor_bank_account_no		= @p_vendor_bank_account_no	
				,vendor_bank_account_name	= @p_vendor_bank_account_name
				,vendor_npwp				= @p_vendor_npwp
				,vendor_type				= @p_vendor_type
				,is_reimburse				= @p_is_reimburse	
				,bank_code					= @p_bank_code		
				,bank_name					= @p_bank_name		
				,bank_account_no			= @p_bank_account_no	
				,bank_account_name			= @p_bank_account_name
				,sa_vendor_name				= @p_sa_vendor_name		
				,sa_vendor_area_phone		= @p_sa_vendor_area_phone
				,sa_vendor_phone_no			= @p_sa_vendor_phone_no
				,free_service				= @p_free_service
				,estimated_start_date		= @p_estimated_start_date
				,estimated_finish_date		= @p_estimated_finish_date
				,call_center_ticket_no		= @p_call_center_ticket_no
				,is_request_replacement		= @p_is_request_replacement
				,delivery_address			= @p_delivery_address
				,contact_name				= @p_contact_name
				,contact_phone_no			= @p_contact_phone_no
				,reason_code				= @p_reason_code
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code = @p_code ;

			--Ketika merubah tanggal transaksi juga merubah maintenance yang di detail list
			select	@transaction_date = transaction_date
			from	dbo.maintenance
			where	code = @p_code ;

			if (@p_transaction_date <> @transaction_date )
			begin
				delete dbo.maintenance_detail
				where maintenance_code =  @p_code

				declare curr_maintenance cursor fast_forward read_only for

				select	distinct
						service_code
						,service_name
						,id
						,service_type
				from	dbo.asset_maintenance_schedule
				where	id in
						(
							select		max(id)
							from		dbo.asset_maintenance_schedule
							where		asset_code					= @p_asset_code
										and isnull(reff_trx_no,'')	= ''
										and maintenance_status		= 'SCHEDULE PENDING'
										and
										(
											maintenance_date   <= @p_work_date
											or	miles		   <= @p_actual_km
											or	hour		   <= @p_hour_meter
										)
							group by	service_code,service_name
						) ;
				
				open curr_maintenance
				
				fetch next from curr_maintenance 
				into @service_code
					,@service_name
					,@id
					,@service_type
				
				while @@fetch_status = 0
				begin
				    exec dbo.xsp_maintenance_detail_insert @p_id								= 0
															,@p_maintenance_code				= @p_code
															,@p_service_code					= @service_code
															,@p_service_name					= @service_name
															,@p_file_name						= null
															,@p_path							= null
															,@p_quantity						= 0
															,@p_pph_amount						= 0
															,@p_ppn_amount						= 0
															,@p_service_amount					= 0
															,@p_asset_maintenance_schedule_id	= @id
															,@p_service_type					= @service_type
															,@p_cre_date						= @p_mod_date
															,@p_cre_by							= @p_mod_by
															,@p_cre_ip_address					= @p_mod_ip_address
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
