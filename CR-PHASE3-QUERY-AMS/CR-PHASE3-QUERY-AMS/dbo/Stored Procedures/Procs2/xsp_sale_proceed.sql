CREATE PROCEDURE dbo.xsp_sale_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg								nvarchar(max)
			,@status							nvarchar(20)
			,@asset_code						nvarchar(50)
			,@is_valid							int 
			,@max_day							int
			,@sale_date							datetime
			,@company_code						nvarchar(50)
			,@description_detail				nvarchar(4000)
			,@sell_request_amount				decimal(18,2)
			,@asset_code_detail					nvarchar(50)
			,@sale_amount						decimal(18,2)
			,@item_name							nvarchar(250)
			,@interface_remarks					nvarchar(4000)
			,@req_date							datetime
			,@reff_approval_category_code		nvarchar(50)
			,@request_code						nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@table_name						nvarchar(50)
			,@primary_column					nvarchar(50)
			,@dim_value							nvarchar(50)
			,@reff_dimension_code				nvarchar(50)
			,@reff_dimension_name				nvarchar(250)
			,@approval_code						nvarchar(50)
			,@dimension_code					nvarchar(50)
			,@value_approval					nvarchar(250)
			,@path								nvarchar(250)
			,@url_path							nvarchar(250)
			,@approval_path						nvarchar(4000)
			,@gain_loss_apv						decimal(18,2)
			,@requestor_code					nvarchar(50)
			,@requestor_name					nvarchar(250)
			,@date								datetime		= dbo.xfn_get_system_date()
			,@is_gps							nvarchar(1)
			,@gps_status						nvarchar(20)
			,@remark							nvarchar(4000)

	begin try -- 
		select	@status						= dor.status
				,@asset_code				= sd.asset_code
				,@sale_date					= dor.sale_date
				,@company_code				= dor.company_code
				,@description_detail		= sd.description
				,@branch_code				= dor.branch_code
				,@branch_name				= dor.branch_name
		from	dbo.sale dor
				left join dbo.sale_detail sd on (sd.sale_code = dor.code)
		where	dor.code = @p_code
		


		if exists
		(
			select	1
			from	dbo.sale_detail sd 
			inner join dbo.sale s on s.code = sd.sale_code
			where	sale_code = @p_code
					and isnull(condition,'')=''
					and isnull(auction_location,'')=''
					and isnull(auction_base_price, 0) = 0
                    and isnull(asset_selling_price, 0) = 0
					and s.sell_type = 'AUCTION'
		)
		begin
			set @msg = N'Please Fill a Mandatory Field Condition, Auction Location, Auction Base Price, Asset Selling Price';
			raiserror(@msg, 16, -1);
		end;

		if exists
		(
			select	1
			from	dbo.sale_detail sd 
			inner join dbo.sale s on s.code = sd.sale_code
			where	sale_code = @p_code
					and isnull(sd.claim_amount,0)=0
					and s.sell_type = 'CLAIM'
		)
		begin
			set @msg = N'Please Fill a Mandatory Field Claim Amount';
			raiserror(@msg, 16, -1);
		end;

		if exists
		(
			select	1
			from	dbo.sale_detail sd 
			inner join dbo.sale s on s.code = sd.sale_code
			where	sale_code = @p_code
					and isnull(sd.sell_request_amount,0)=0
					and s.sell_type in ('AUCTION','COP', 'DSSM')
		)
		begin
			set @msg = N'Please Fill a Mandatory Field Asset Selling Price';
			raiserror(@msg, 16, -1);
		end;

		if exists
		(
			select	1
			from	dbo.sale_detail sd 
			inner join dbo.sale s on s.code = sd.sale_code
			where	sale_code = @p_code
					and isnull(sd.sell_request_amount,0)=0
					and s.sell_type in ('AUCTION')
		)
		begin
			set @msg = N'Please Fill a Mandatory Field Auction Base Price';
			raiserror(@msg, 16, -1);
		end;
		--print 1111
		if (@status <> 'HOLD')
		begin
			set @msg = 'Data Already Proceed.';
			raiserror(@msg ,16,-1);
		end

		if exists(select 1 from dbo.sale_attachement_group where sale_code = @p_code and is_required = '1' and isnull(file_name,'') = '')
		begin
			set @msg = 'Please Input Value Or File In Tab Attachment For Description Required.';
			raiserror(@msg ,16,-1);
		end

		--if(isnull(@description_detail,'') = '')
		--begin
		--	set @msg = 'Please insert description in asset first.';
		--	raiserror(@msg ,16,-1);	
		--end

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@sale_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		if @is_valid = 0
		begin
			set @msg = 'Maximum back date input transaction date ' + cast(@max_day as char(2)) + ' every month';
			raiserror(@msg ,16,-1);	    
		end
		
		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@sale_date,dbo.xfn_get_system_date()) > 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			raiserror(@msg ,16,-1);	 
		end
		-- End of additional control ===================================================

		if(@sale_amount = 0)
		begin
			set @msg = 'Sale Value must be greater than 0';
			raiserror(@msg ,16,-1);

			-- send mail attachment based on setting ================================================
			--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
			--                                                ,@p_doc_code		= @p_code
			--                                                ,@p_attachment_flag = 0
			--                                                ,@p_attachment_file = ''
			--                                                ,@p_attachment_path = ''
			--                                                ,@p_company_code	= @company_code
			--                                                ,@p_trx_no			= @p_code
			--												,@p_trx_type		= 'SELL'
			-- End of send mail attachment based on setting ================================================

		end

		if (@status = 'HOLD' and @asset_code is null)
		begin
			set @msg = 'Please fill in Sale Asset';
			raiserror(@msg ,16,-1);
		end
		
		update	dbo.sale
		set		status			= 'ON PROCESS'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;

		--update sell request amount di asset
		declare curr_sale_detail cursor fast_forward read_only for

		select asset_code
				,sell_request_amount
				,sale_remark
		from dbo.sale_detail
		where sale_code = @p_code
		
		open curr_sale_detail
		
		fetch next from curr_sale_detail 
		into @asset_code
			,@sell_request_amount
			,@remark
		
		while @@fetch_status = 0
		BEGIN
			-- Ambil data IS_GPS, GPS_STATUS, BRANCH dari ASSET
			SELECT 
				@is_gps = is_gps,
				@gps_status = gps_status,
				@branch_code = branch_code,
				@branch_name = branch_name
			FROM dbo.asset
			WHERE code = @asset_code;

			--update sell request di asset
		    update	dbo.asset
			set		sell_request_amount			= @sell_request_amount
					--
					,mod_date					= @p_mod_date
					,mod_by						= @p_mod_by
					,mod_ip_address				= @p_mod_ip_address
			where	code						= @asset_code ;

			-- Jika IS_GPS = 1 dan GPS_STATUS = 'SUBCRIBE', insert ke GPS_UNSUBCRIBE_REQUEST
			if @is_gps = '1' and @gps_status = 'SUBCRIBE'
			begin
				declare @p_request_no nvarchar(50);
				exec dbo.xsp_gps_unsubcribe_request_insert @p_request_no = @p_request_no output,        
				                                           @p_code = @asset_code,                        
				                                           --@p_remark = N'Auto request unsubcribe from Sell Request Approval',
				                                           @p_source_reff_name = N'SELL REQUEST',             
				                                           @p_unsubscribe_date = @p_mod_date,			
				                                           @p_branch_code = @branch_code,               
				                                           @p_branch_name = @branch_name,               
				                                           @p_cre_date = @p_mod_date,					
				                                           @p_cre_by = @p_mod_by,                       
				                                           @p_cre_ip_address = @p_mod_ip_address,       
				                                           @p_mod_date = @p_mod_date,					
				                                           @p_mod_by = @p_mod_by,                       
				                                           @p_mod_ip_address = @p_mod_ip_address ,
														   @p_source_reff_no	= @p_code,
														   @p_remark	= @remark
			end

		    fetch next from curr_sale_detail 
			into @asset_code
			,@sell_request_amount
			,@remark

		end
		
		close curr_sale_detail
		deallocate curr_sale_detail 


		begin --push ke approval
			select @gain_loss_apv = sum(gain_loss) --* -1
			from dbo.sale_detail
			where sale_code = @p_code

			set @interface_remarks = 'Approval Sell Request For ' + @p_code + ' - ' + format (@gain_loss_apv, '#,###.00', 'DE-de') ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'SLRQ' ;

			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'PATHSRIA'

			--set approval path
			set	@approval_path = @path + @p_code

			select	@requestor_name = name
			from	ifinsys.dbo.sys_employee_main
			where	code = @p_mod_by ;

			exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
															   ,@p_branch_code				= @branch_code
																,@p_branch_name				= @branch_name
																,@p_request_status			= N'HOLD'
																,@p_request_date			= @date
																,@p_request_amount			= @gain_loss_apv
																,@p_request_remarks			= @interface_remarks
																,@p_reff_module_code		= N'IFINAMS'
																,@p_reff_no					= @p_code
																,@p_reff_name				= N'SELL REQUEST APPROVAL'
																,@p_paths					= @approval_path
																,@p_approval_category_code	= @reff_approval_category_code
																,@p_approval_status			= N'HOLD'
																,@p_expired_date			= @req_date
																,@p_requestor_code			= @p_mod_by
																,@p_requestor_name			= @requestor_name
																,@p_cre_date				= @p_mod_date
																,@p_cre_by					= @p_mod_by
																,@p_cre_ip_address			= @p_mod_ip_address
																,@p_mod_date				= @p_mod_date
																,@p_mod_by					= @p_mod_by
																,@p_mod_ip_address			= @p_mod_ip_address


			declare curr_appv cursor fast_forward read_only for
			select 	approval_code
					,reff_dimension_code
					,reff_dimension_name
					,dimension_code
			from	dbo.master_approval_dimension
			where	approval_code = 'SLRQ'
			
			open curr_appv
			
			fetch next from curr_appv 
			into @approval_code
				,@reff_dimension_code
				,@reff_dimension_name
				,@dimension_code
			
			while @@fetch_status = 0
			begin
				select	@table_name					 = table_name
						,@primary_column			 = primary_column
				from	dbo.sys_dimension
				where	code						 = @dimension_code

				exec dbo.xsp_get_table_value_by_dimension @p_dim_code		= @dimension_code
															,@p_reff_code	= @p_code
															,@p_reff_table	= 'SALE'
															,@p_output		= @dim_value output ;
				
				exec dbo.xsp_ams_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address ;
				
			
			    fetch next from curr_appv 
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code
			end
			
			close curr_appv
			deallocate curr_appv
		end


		

	end try
	begin catch
        DECLARE @error INT = @@ERROR;

        IF (@error = 2627)
        BEGIN
            SET @msg = dbo.xfn_get_msg_err_code_already_exist();
        END;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'V;' + @msg;
        END
        ELSE IF (LEFT(ERROR_MESSAGE(), 2) = 'V;')
        BEGIN
            SET @msg = ERROR_MESSAGE();
        END
        ELSE
        BEGIN
            SET @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
        END

        RAISERROR(@msg, 16, -1);
        RETURN;
	end catch ;	
end ;
