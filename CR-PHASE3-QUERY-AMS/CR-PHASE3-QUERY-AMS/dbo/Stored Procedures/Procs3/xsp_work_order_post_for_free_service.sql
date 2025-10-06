CREATE PROCEDURE [dbo].[xsp_work_order_post_for_free_service]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@status						nvarchar(20)
			,@company_code					nvarchar(50)
			,@maintenance_code				nvarchar(50)
			,@remarks						nvarchar(4000)
			,@asset_code					nvarchar(50)
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@code_interface				nvarchar(50)
			,@payment_amount				decimal(18, 2)
			,@sp_name						nvarchar(250)
			,@debet_or_credit				nvarchar(10)
			,@gl_link_code					nvarchar(50)
			,@transaction_name				nvarchar(250)
			,@orig_amount_cr				decimal(18, 2)
			,@orig_amount_db				decimal(18, 2)
			,@amount						decimal(18, 2)
			,@return_value					decimal(18, 2)
			,@year							nvarchar(4)
			,@month							nvarchar(2)
			,@code							nvarchar(50)
			,@vendor_name					nvarchar(250)
			,@requestor_name				nvarchar(250)
			,@adress						nvarchar(4000)
			,@phone_no						nvarchar(15)
			,@service_code					nvarchar(50)
			,@service_name					nvarchar(250)
			,@actual_km						bigint
			,@service_type					nvarchar(50)
			,@date							datetime
			,@reff_remark					nvarchar(4000)
			,@item_name						nvarchar(250)
			,@work_date						datetime
			,@hour_meter					int
			,@id_asset_maintenance_schedule bigint
			,@trx_no						nvarchar(50)
			,@is_maintenance				nvarchar(1)
			,@code_payment_request			nvarchar(50)
			,@pph_amount_payment			decimal(18, 2)
			,@ppn_amount_payment			decimal(18, 2)
			,@payment_amount_payment		decimal(18, 2)
			,@total_amount_payment			decimal(18, 2)
			,@payment_remark				nvarchar(4000)
			,@base_amount					decimal(18, 2)
			,@base_amount_db				decimal(18, 2)
			,@base_amount_cr				decimal(18, 2)
			,@reff_source_name				nvarchar(250)
			,@gllink_trx_code				nvarchar(50)
			,@debit_or_credit				nvarchar(50)
			,@category_code					nvarchar(50)
			,@purchase_price				decimal(18, 2)
			,@is_valid						int
			,@x_code						nvarchar(50)
			,@exch_rate						decimal(18, 2) = 1
			,@detail_remark					nvarchar(250)
			,@id_detail						int
			,@vendor_code					nvarchar(50)
			,@vendor_bank_name				nvarchar(250)
			,@vendor_bank_account_no		nvarchar(50)
			,@vendor_bank_account_name		nvarchar(250)
			,@is_reimburse					nvarchar(1)
			,@ppn_amount					decimal(18, 2)
			,@pph_amount					decimal(18, 2)
			,@agreement_no					nvarchar(50)
			,@asset_no						nvarchar(50)
			,@client_no						nvarchar(50)
			,@client_name					nvarchar(250)
			,@description_request			nvarchar(250)
			,@wod_id						bigint
			,@quantity						int
			,@remark						nvarchar(4000)
			,@process_code					nvarchar(50)
			,@maintenance_type				nvarchar(50)
			,@plat_no						nvarchar(50)
			,@invoice_no					nvarchar(50)
			,@faktur_no						nvarchar(50)
			,@vendor_npwp					nvarchar(20)
			,@income_type					nvarchar(250)
			,@income_bruto_amount			decimal(18, 2)
			,@tax_rate						decimal(5, 2)
			,@ppn_pph_amount				decimal(18, 2)
			,@transaction_code				nvarchar(50)
			,@ppn_pct						decimal(9, 6)
			,@pph_pct						decimal(9, 6)
			,@vendor_type					nvarchar(25)
			,@pph_type						nvarchar(20)
			,@total_amount					decimal(18, 2)
			,@remarks_tax					nvarchar(4000)
			,@spk_no						nvarchar(50)
			,@bank_name						nvarchar(250)
			,@bank_account_no				nvarchar(50)
			,@bank_account_name				nvarchar(250)
			,@maintenance_by				nvarchar(50)
			,@branch_code_asset				nvarchar(50)
			,@branch_name_asset				nvarchar(250)
			,@agreement_external_no			nvarchar(50)
			,@faktur_no_invoice				nvarchar(50)	-- (+) Ari 2023-12-18
			,@faktur_date					datetime
			,@faktur_date_source			datetime
			,@invoice_name					nvarchar(250) ;

	begin try
		select	@status					   = wo.status
				,@company_code			   = wo.company_code
				,@maintenance_code		   = wo.maintenance_code
				,@asset_code			   = wo.asset_code
				,@branch_code			   = mnt.branch_code
				,@branch_name			   = mnt.branch_name
				,@vendor_code			   = mnt.vendor_code
				,@vendor_name			   = mnt.vendor_name
				,@requestor_name		   = ass.requestor_name
				,@adress				   = mnt.vendor_address
				,@phone_no				   = mnt.vendor_phone
				,@date					   = mnt.transaction_date
				,@item_name				   = ass.item_name
				,@hour_meter			   = mnt.hour_meter
				,@actual_km				   = wo.actual_km
				,@service_type			   = mnt.service_type
				,@work_date				   = wo.work_date
				,@vendor_bank_name		   = mnt.vendor_bank_name
				,@vendor_bank_account_no   = mnt.vendor_bank_account_no
				,@vendor_bank_account_name = mnt.vendor_bank_account_name
				,@vendor_npwp			   = mnt.vendor_npwp
				,@is_reimburse			   = mnt.is_reimburse
				,@payment_amount		   = wo.payment_amount
				,@ppn_amount			   = wo.total_ppn_amount
				,@pph_amount			   = wo.total_pph_amount
				,@agreement_no			   = ass.agreement_no
				,@asset_no				   = ass.asset_no
				,@client_no				   = ass.client_no
				,@client_name			   = ass.client_name
				,@remark				   = wo.remark
				,@maintenance_type		   = mnt.service_type
				,@plat_no				   = avh.plat_no
				,@invoice_no			   = wo.invoice_no
				,@vendor_type			   = mnt.vendor_type
				,@spk_no				   = mnt.spk_no
				,@bank_name				   = mnt.bank_name
				,@bank_account_no		   = mnt.bank_account_no
				,@bank_account_name		   = mnt.bank_account_name
				,@maintenance_by		   = wo.maintenance_by
				,@branch_code_asset		   = ass.branch_code
				,@branch_name_asset		   = ass.branch_name
				,@agreement_external_no	   = isnull(ass.agreement_external_no, '')
				,@faktur_date_source	   = wo.faktur_date
		from	dbo.work_order						wo
				left join dbo.maintenance			mnt on (mnt.code	   = wo.maintenance_code)
				left join ifinbam.dbo.master_vendor mv on (mnt.vendor_code = mv.code)
				left join dbo.asset					ass on (ass.code	   = mnt.asset_code)
				left join dbo.asset_vehicle			avh on (avh.asset_code = ass.code)
		where	wo.code = @p_code ;

			if (@service_type = 'ROUTINE')
			begin
				-- Cursor untuk update schedule maintenance di asset yang tidak dilakukan maintenance yang kurang dari work date
				if exists
				(
					select	1
					from	dbo.asset_maintenance_schedule
					where	asset_code			   = @asset_code
							and
							(
								maintenance_date   <= @work_date
								or	miles		   <= @actual_km
								or	hour		   <= @hour_meter
							)
							and maintenance_status = 'SCHEDULE PENDING'
							and reff_trx_no		   = ''
							and id not in
								(
									select	asset_maintenance_schedule_id
									from	dbo.maintenance_detail
									where	maintenance_code = @maintenance_code
								)
				)
				begin
					declare curr_asset_non_main cursor fast_forward read_only for
					select	id
					from	dbo.asset_maintenance_schedule
					where	asset_code			   = @asset_code
							and
							(
								maintenance_date   <= @work_date
								or	miles		   <= @actual_km
								or	hour		   <= @hour_meter
							)
							and maintenance_status = 'SCHEDULE PENDING'
							and reff_trx_no		   = ''
							and id not in
								(
									select	asset_maintenance_schedule_id
									from	dbo.maintenance_detail
									where	maintenance_code = @maintenance_code
								) ;

					open curr_asset_non_main ;

					fetch next from curr_asset_non_main
					into @id_asset_maintenance_schedule ;

					while @@fetch_status = 0
					begin
						update	dbo.asset_maintenance_schedule
						set		maintenance_status	= 'SERVICE SKIPED'
								,last_status_date	= @p_mod_date
								,reff_trx_no		= '-'
								--
								,mod_date			= @p_mod_date
								,mod_by				= @p_mod_by
								,mod_ip_address		= @p_mod_ip_address
						where	asset_code = @asset_code
								and id	   = @id_asset_maintenance_schedule ;

						fetch next from curr_asset_non_main
						into @id_asset_maintenance_schedule ;
					end ;

					close curr_asset_non_main ;
					deallocate curr_asset_non_main ;
				end ;

				-- Cursor untuk update schedule maintenance di asset yang dilakukan maintenance
				declare curr_asset_main cursor fast_forward read_only for
				select	asset_maintenance_schedule_id
				from	dbo.maintenance_detail
				where	maintenance_code = @maintenance_code ;

				open curr_asset_main ;

				fetch next from curr_asset_main
				into @trx_no ;

				while @@fetch_status = 0
				begin
					update	dbo.asset_maintenance_schedule
					set		maintenance_status	= 'SCHEDULE DONE'
							,last_status_date	= @p_mod_date
							,reff_trx_no		= @maintenance_code
							,service_date		= @work_date
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	asset_code = @asset_code
							and id	   = @trx_no ;

					fetch next from curr_asset_main
					into @trx_no ;
				end ;

				close curr_asset_main ;
				deallocate curr_asset_main ;

				-- Cursor untuk insert schedule baru diluar schedule asli dengan service type routin
				if exists
				(
					select	1
					from	dbo.work_order_detail
					where	work_order_code					  = @p_code
							and asset_maintenance_schedule_id = 0
				)
				begin
					declare curr_main_not_schedule cursor fast_forward read_only for
					select	service_code
							,service_name
					from	dbo.work_order_detail
					where	work_order_code					  = @p_code
							and asset_maintenance_schedule_id = 0 ;

					open curr_main_not_schedule ;

					fetch next from curr_main_not_schedule
					into @service_code
						 ,@service_name ;

					while @@fetch_status = 0
					begin
						exec dbo.xsp_asset_maintenance_schedule_insert @p_id						= 0
																	   ,@p_asset_code				= @asset_code
																	   ,@p_maintenance_no			= ''
																	   ,@p_maintenance_date			= @p_mod_date
																	   ,@p_maintenance_status		= 'AD HOC DONE'
																	   ,@p_last_status_date			= @p_mod_date
																	   ,@p_reff_trx_no				= @maintenance_code
																	   ,@p_miles					= @actual_km
																	   ,@p_month					= null
																	   ,@p_hour						= null
																	   ,@p_service_code				= @service_code
																	   ,@p_service_name				= @service_name
																	   ,@p_service_type				= @service_type
																	   ,@p_service_date				= @work_date
																	   ,@p_cre_by					= @p_mod_by
																	   ,@p_cre_date					= @p_mod_date
																	   ,@p_cre_ip_address			= @p_mod_ip_address
																	   ,@p_mod_by					= @p_mod_by
																	   ,@p_mod_date					= @p_mod_date
																	   ,@p_mod_ip_address			= @p_mod_ip_address ;

						fetch next from curr_main_not_schedule
						into @service_code
							 ,@service_name ;
					end ;

					close curr_main_not_schedule ;
					deallocate curr_main_not_schedule ;
				end ;

				--cek apakah di asset withmaintenance routin nya 1 apa 0
				select	@is_maintenance = is_maintenance
				from	dbo.asset
				where	code = @asset_code ;

				--jika 0 maka update jadi 1 untuk menampilkan jadwal maintenance yang diinput manual di menu maintenance
				if (@is_maintenance = '0')
				begin
					update	dbo.asset
					set		is_maintenance		= '1'
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address
					where	code				= @asset_code ;
				end ;
			end ;
			else
			begin
				--cek apakah di asset withmaintenance routin nya 1 apa 0
				select	@is_maintenance = is_maintenance
				from	dbo.asset
				where	code = @asset_code ;

				--jika 0 maka update jadi 1 untuk menampilkan jadwal maintenance yang diinput manual di menu maintenance
				if (@is_maintenance = '0')
				begin
					update	dbo.asset
					set		is_maintenance			= '1'
							--
							,mod_date				= @p_mod_date
							,mod_by					= @p_mod_by
							,mod_ip_address			= @p_mod_ip_address
					where	code = @asset_code ;
				end ;

				declare curr_non_routin cursor fast_forward read_only for
				select	mnt.asset_code
						,wo.actual_km
						,mnt.hour_meter
						,mnd.service_code
						,mnd.service_name
						,mnd.service_type
				from	dbo.maintenance_detail	   mnd
						inner join dbo.maintenance mnt on (mnt.code = mnd.maintenance_code)
						inner join dbo.work_order wo on wo.maintenance_code = mnt.code
				where	mnt.code = @maintenance_code ;

				open curr_non_routin ;

				fetch next from curr_non_routin
				into @asset_code
					 ,@actual_km
					 ,@hour_meter
					 ,@service_code
					 ,@service_name
					 ,@service_type ;

				while @@fetch_status = 0
				begin
					exec dbo.xsp_asset_maintenance_schedule_insert @p_id						= 0
																   ,@p_asset_code				= @asset_code
																   ,@p_maintenance_no			= ''
																   ,@p_maintenance_date			= @p_mod_date
																   ,@p_maintenance_status		= 'AD HOC DONE'
																   ,@p_last_status_date			= @p_mod_date
																   ,@p_reff_trx_no				= @maintenance_code
																   ,@p_miles					= @actual_km
																   ,@p_month					= null
																   ,@p_hour						= @hour_meter
																   ,@p_service_code				= @service_code
																   ,@p_service_name				= @service_name
																   ,@p_service_type				= @service_type
																   ,@p_service_date				= @work_date
																   ,@p_cre_by					= @p_mod_by
																   ,@p_cre_date					= @p_mod_date
																   ,@p_cre_ip_address			= @p_mod_ip_address
																   ,@p_mod_by					= @p_mod_by
																   ,@p_mod_date					= @p_mod_date
																   ,@p_mod_ip_address			= @p_mod_ip_address ;

					fetch next from curr_non_routin
					into @asset_code
						 ,@actual_km
						 ,@hour_meter
						 ,@service_code
						 ,@service_name
						 ,@service_type ;
				end ;

				close curr_non_routin ;
				deallocate curr_non_routin ;
			end ;

			--Update status WO jadi POST
			update	dbo.work_order
			set		status				= 'POST'
					,proced_by			= @p_mod_by
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;

			if (@maintenance_by = 'INT')
			begin
				update	dbo.work_order
				set		status			= 'PAID'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address
				where	code			= @p_code ;
			end ;

			--kosongkan nomor work order
			update	dbo.asset
			set		wo_no				= null
					,wo_status			= 'DONE'
					,last_meter			= @actual_km
					,last_service_date	= @work_date
					,last_km_service	= @actual_km
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @asset_code ;
		
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
