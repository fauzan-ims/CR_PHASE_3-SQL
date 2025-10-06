CREATE PROCEDURE [dbo].[xsp_asset_post]
(
	@p_code					nvarchar(50)
	,@p_cover_note			nvarchar(50)	= null
	,@p_cover_note_date		datetime		= null
	,@p_cover_exp_date		datetime		= null
	,@p_cover_file_name		nvarchar(250)	= ''
	,@p_cover_file_path		nvarchar(250)	= ''
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@branch_code			nvarchar(50)
			,@company_code			nvarchar(50)
			,@status				nvarchar(20)
			,@date					datetime = getdate()
			,@branch_name			nvarchar(250)
			,@location_code			nvarchar(50)
			,@pic_code				nvarchar(50)
			,@division_code			nvarchar(50)
			,@division_name			nvarchar(250)
			,@departement_code		nvarchar(50)
			,@departement_name		nvarchar(250)
			,@sub_departement_code	nvarchar(50)
			,@sub_departement_name	nvarchar(250)
			,@unit_code				nvarchar(50)
			,@unit_name				nvarchar(250)
			,@is_valid				int
			,@category_code			nvarchar(50)
			,@purchase_price		decimal(18,2)
			,@purchase_date			datetime
			,@depre_date_comm		datetime
			,@depre_date_fiscal		datetime
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@max_day				int
			,@model_code_vhcl		nvarchar(50)
			,@unit_from				nvarchar(50)
			,@pic_name				nvarchar(250)
			,@code_spaf				nvarchar(50)
			,@spaf_pct				decimal(9,6)
			,@spaf_amount			decimal(18,2)
			,@subvention_amount		decimal(18,2)
			,@rental_reff_no		nvarchar(50)
			,@bpkb_no				nvarchar(50)
			,@document_no			nvarchar(50)
			,@is_final_all			nvarchar(1)
			,@is_gps				nvarchar(1)
			,@gps_vendor_code		nvarchar(50)
			,@gps_vendor_name		nvarchar(250)
			,@gps_received_date		datetime

	begin try -- 
		select	@status					= dor.status
				,@branch_code			= dor.branch_code
				,@branch_name			= dor.branch_name
				,@company_code			= dor.company_code
				,@pic_code				= isnull(dor.pic_code, '')
				,@division_code			= isnull(dor.division_code, '')
				,@division_name			= isnull(dor.division_name, '')
				,@departement_code		= isnull(dor.department_code, '')
				,@departement_name		= isnull(dor.department_name, '')
				,@category_code			= dor.category_code
				,@purchase_price		= dor.purchase_price
				,@purchase_date			= dor.purchase_date
				,@model_code_vhcl		= vhcl.model_code
				,@unit_from				= dor.asset_from
				,@pic_name				= isnull(dor.pic_name, '')
				,@spaf_pct				= isnull(dor.spaf_pct, 0)
				,@spaf_amount			= dor.spaf_amount
				,@subvention_amount		= dor.subvention_amount
				,@rental_reff_no		= dor.rental_reff_no
				,@bpkb_no				= vhcl.bpkb_no
				,@is_final_all			= dor.is_final_grn
				,@is_gps				= is_gps			
				,@gps_vendor_code		= gps_vendor_code	
				,@gps_vendor_name		= gps_vendor_name	
				,@gps_received_date		= gps_received_date	
		from	dbo.asset dor
		left join dbo.asset_vehicle vhcl on (vhcl.asset_code = dor.code)
		where	dor.code = @p_code ;

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@purchase_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'
		 
		if (@status = 'ON PROCESS')
		begin
				if(@unit_from = 'BUY')
				begin
					if (@rental_reff_no is not null)
					begin
						if(@pic_code = '' and @pic_name = '')
						begin
							update	dbo.asset
							set		status			= 'STOCK'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= 'RESERVED'
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
						else
						begin
							update	dbo.asset
							set		status			= 'STOCK'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= 'COMPLIMENT'
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
					end
					else
					begin
						if(@pic_code = '' and @pic_name = '')
						begin
							update	dbo.asset
							set		status			= 'STOCK'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= ''
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
						else
						begin
							update	dbo.asset
							set		status			= 'STOCK'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= 'COMPLIMENT'
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
					end
				end
				else
				begin
					if (@rental_reff_no is not null)
					begin
						if(@pic_code = '' and @pic_name = '')
						begin
							update	dbo.asset
							set		status			= 'REPLACEMENT'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= 'RESERVED'
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
						else
						begin
							update	dbo.asset
							set		status			= 'REPLACEMENT'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= 'COMPLIMENT'
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
					end
					else
					begin
						if(@pic_code = '' and @pic_name = '')
						begin
							update	dbo.asset
							set		status			= 'REPLACEMENT'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= ''
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
						else
						begin
							update	dbo.asset
							set		status			= 'REPLACEMENT'
									,is_lock		= '1'
									,fisical_status = 'ON HAND'
									,rental_status	= ''
									--
									,mod_date		= @p_mod_date
									,mod_by			= @p_mod_by
									,mod_ip_address = @p_mod_ip_address
							where	code			= @p_code ;
						end
					end
				end
			    

				-- Jika asset yang tidak RENT yang ter depre
				if(@unit_from = 'BUY' and isnull(@is_final_all,'0') = '1')--cr priority sepria 09092025: tambah kondisi jika dari proc asset sudah final +invoice sudah paid semua, generate depre. jika blem generate depre by job
				begin
					-- Arga 19-Oct-2022 ket : additional control for WOM (+)
					select @is_valid = dbo.xfn_depre_threshold_validation(@company_code, @category_code, @purchase_price)

					if @is_valid = 1
					begin
						exec dbo.xsp_asset_depreciation_schedule_commercial_generate @p_code			 = @p_code
																					 ,@p_mod_date		 = @p_mod_date	  
																					 ,@p_mod_by			 = @p_mod_by		  
																					 ,@p_mod_ip_address	 = @p_mod_ip_address

						exec dbo.xsp_asset_depreciation_schedule_fiscal_generate @p_code			 = @p_code
																				 ,@p_mod_date		 = @p_mod_date	  
																				 ,@p_mod_by			 = @p_mod_by		
																				 ,@p_mod_ip_address	 = @p_mod_ip_address

						select @depre_date_comm =  min(depreciation_date) 
						from dbo.asset_depreciation_schedule_commercial
						where asset_code = @p_code

						select @depre_date_fiscal =  min(depreciation_date) 
						from dbo.asset_depreciation_schedule_fiscal
						where asset_code = @p_code

						if(@depre_date_comm <> @depre_date_fiscal)
						begin
							set @msg = 'The start date of depreciation between Commercial and Fiscal must be the same';
							raiserror(@msg ,16,-1);	
						end

					end
				end

				exec dbo.xsp_asset_mutation_history_insert @p_id						 = 0
														   ,@p_asset_code				 = @p_code
														   ,@p_date						 = @purchase_date -- Arga 02-Nov-2022 ket : request for wom (-/+) --@date
														   ,@p_document_refference_no	 = @p_code
														   ,@p_document_refference_type	 = 'MNE'
														   ,@p_usage_duration			 = 0
														   ,@p_from_branch_code			 = @branch_code
														   ,@p_from_branch_name			 = @branch_name
														   ,@p_to_branch_code			 = ''
														   ,@p_to_branch_name			 = ''
														   ,@p_from_location_code		 = ''
														   ,@p_to_location_code			 = ''
														   ,@p_from_pic_code			 = @pic_code
														   ,@p_to_pic_code				 = ''
														   ,@p_from_division_code		 = @division_code
														   ,@p_from_division_name		 = @division_name
														   ,@p_to_division_code			 = ''
														   ,@p_to_division_name			 = ''
														   ,@p_from_department_code		 = @departement_code
														   ,@p_from_department_name		 = @departement_name
														   ,@p_to_department_code		 = ''
														   ,@p_to_department_name		 = ''
														   ,@p_from_sub_department_code	 = ''
														   ,@p_from_sub_department_name	 = ''
														   ,@p_to_sub_department_code	 = ''
														   ,@p_to_sub_department_name	 = ''
														   ,@p_from_unit_code			 = ''
														   ,@p_from_unit_name			 = ''
														   ,@p_to_unit_code				 = ''
														   ,@p_to_unit_name				 = ''
														   ,@p_cre_date					 = @p_mod_date	  
														   ,@p_cre_by					 = @p_mod_by		
														   ,@p_cre_ip_address			 = @p_mod_ip_address
														   ,@p_mod_date					 = @p_mod_date	  
														   ,@p_mod_by					 = @p_mod_by		
														   ,@p_mod_ip_address			 = @p_mod_ip_address
				
			-- insert into asset document pending & asset
			--set @document_no = isnull(@p_cover_note, @bpkb_no)
			--exec dbo.xsp_asset_to_interface_insert @p_asset_code		= @p_code
			--									   ,@p_cover_note		= @document_no	
			--									   ,@p_cover_note_date	= @p_cover_note_date	
			--									   ,@p_cover_exp_date	= @p_cover_exp_date	
			--									   ,@p_cover_file_name	= @p_cover_file_name
			--									   ,@p_cover_file_path	= @p_cover_file_path	
			--									   ,@p_cre_date			= @p_mod_date	  
			--									   ,@p_cre_by			= @p_mod_by		
			--									   ,@p_cre_ip_address	= @p_mod_ip_address
			--									   ,@p_mod_date			= @p_mod_date	  
			--									   ,@p_mod_by			= @p_mod_by		
			--									   ,@p_mod_ip_address	= @p_mod_ip_address
			

			-- update barcode number
			--exec dbo.xsp_asset_generate_barcode_number @p_asset_code	= @p_code
			--											,@p_user_id		= @p_mod_by ;

														
			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'PSRQTR'
			--												,@p_doc_code		= @p_code
			--												,@p_attachment_flag = 0
			--												,@p_attachment_file = ''
			--												,@p_attachment_path = ''
			--												,@p_company_code	= @company_code
			--												,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'ASET'
			-- End of send mail attachment based on setting ================================================

			-- insert ke SPAF ASSET
			--set @spaf_amount = @purchase_price * isnull(@spaf_pct, 0)
			--jika spaf atau subvention amount tidak 0

			-- hari - 06.jul.2023 08:17 pm --	jika asset nya memiliki reff no ( dari opl ) maka insert
			--if exists (select 1 from dbo.asset where code = @p_code and rental_reff_no <> '')
			begin
				if(@spaf_amount <> 0 or @subvention_amount <> 0)
				begin
					exec dbo.xsp_spaf_asset_insert @p_code					= @code_spaf
												   ,@p_date					= @purchase_date
												   ,@p_fa_code				= @p_code
												   ,@p_spaf_pct				= @spaf_pct
												   ,@p_spaf_amount			= @spaf_amount
												   ,@p_subvention_amount	= @subvention_amount
												   ,@p_validation_status	= 'HOLD'
												   ,@p_validation_date		= null
												   ,@p_validation_remark	= null
												   ,@p_claim_code			= null
												   ,@p_cre_date				= @p_mod_date	  
												   ,@p_cre_by				= @p_mod_by		
												   ,@p_cre_ip_address		= @p_mod_ip_address
												   ,@p_mod_date				= @p_mod_date	  
												   ,@p_mod_by				= @p_mod_by		
												   ,@p_mod_ip_address		= @p_mod_ip_address
				end
			end


			--masuk ke xsp_monitoring_gps_insert jika is_gps =1
			if (isnull(@is_gps,'0') = '1')
			begin
				exec dbo.xsp_monitoring_gps_insert @p_id = 0,                        -- bigint
												   @p_fa_code = @p_code,                            -- nvarchar(50)
												   @p_vendor_code = @gps_vendor_code,                        -- nvarchar(50)
												   @p_vendor_name = @gps_vendor_name,                        -- nvarchar(250)
												   @p_total_paid = 0,                        -- decimal(18, 2)
												   @p_status = N'SUBSCRIBE',                             -- nvarchar(50)
												   @p_unsubscribe_date = NULL, -- datetime
												   @p_grn_date = @gps_received_date,         -- datetime
												   @p_cre_date = @p_mod_date,         -- datetime
												   @p_cre_by = @p_mod_by,                             -- nvarchar(15)
												   @p_cre_ip_address =  @p_mod_ip_address,                     -- nvarchar(15)
												   @p_mod_date = @p_mod_date,         -- datetime
												   @p_mod_by = @p_mod_by,                             -- nvarchar(15)
												   @p_mod_ip_address =  @p_mod_ip_address                      -- nvarchar(15)
			end
			--Auto generate schedule maintenance
			--exec dbo.xsp_schedule_maintenance_asset_generate_master @p_code					= @p_code
			--														,@p_model_code			= @model_code_vhcl
			--														,@p_cre_by				= @p_mod_by	  
			--														,@p_cre_date			= @p_mod_date		
			--														,@p_cre_ip_address		= @p_mod_ip_address
			--														,@p_mod_by				= @p_mod_by	  
			--														,@p_mod_date			= @p_mod_date		
			--														,@p_mod_ip_address		= @p_mod_ip_address


			--
			
		end
		else
		begin
			set @msg = 'Data Already Proceed.';
			raiserror(@msg ,16,-1);
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
