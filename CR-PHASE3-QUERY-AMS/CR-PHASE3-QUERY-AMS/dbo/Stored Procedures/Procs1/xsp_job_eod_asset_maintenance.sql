CREATE PROCEDURE dbo.xsp_job_eod_asset_maintenance
as
begin

	declare @msg								nvarchar(max)  
			,@sysdate							nvarchar(250)
            ,@mod_date							datetime = getdate()
			,@mod_by							nvarchar(15) ='EOD'
			,@mod_ip_address					nvarchar(15) ='SYSTEM'
			,@code								nvarchar(50)
			,@asset_code						nvarchar(50)
			,@branch_code						nvarchar(50)
			,@branch_name						nvarchar(250)
			,@requestor_code					nvarchar(50)
			,@vendor_code						nvarchar(50)
			,@vendor_name						nvarchar(250)
			,@service_code						nvarchar(50)
			,@service_name						nvarchar(250)
			,@maintenance_id					bigint


	begin try
		begin			
			-- Insert maintenance header berdasarkan asset			
			declare curr_eod_main cursor fast_forward read_only for

			select	ams.asset_code
					,ass.branch_code
					,ass.branch_name
					,ass.requestor_code
					,ass.vendor_code
					,ass.vendor_name
					,ams.id
					,ams.service_code
					,ams.service_name
			from dbo.asset_maintenance_schedule ams
			left join dbo.asset ass on (ass.code = ams.asset_code)
			where maintenance_date <= @mod_date
			and maintenance_status = 'NOT DUE'
			group by ams.asset_code
					 ,ass.branch_code
					 ,ass.branch_name
					 ,ass.requestor_code
					 ,ass.vendor_code
					 ,ass.vendor_name
					 ,ams.id
					 ,ams.service_code
					 ,ams.service_name
			
			open curr_eod_main
			
			fetch next from curr_eod_main 
			into @asset_code
				,@branch_code
				,@branch_name
				,@requestor_code
				,@vendor_code
				,@vendor_name
				,@maintenance_id
				,@service_code
				,@service_name
			
			while @@fetch_status = 0
			begin
			    exec dbo.xsp_maintenance_insert @p_code					= @code output
												,@p_company_code		= 'DSF'
												,@p_asset_code			= @asset_code
												,@p_transaction_date	= @mod_date
												,@p_transaction_amount	= 0
												,@p_branch_code			= @branch_code
												,@p_branch_name			= @branch_name
												--,@p_location_code		= ''
												,@p_requestor_code		= ''
												,@p_requestor_name		= ''
												,@p_division_code		= ''
												,@p_division_name		= ''
												--,@p_category_code		= ''
												--,@p_category_name		= ''
												,@p_department_code		= ''
												,@p_department_name		= ''
												--,@p_sub_department_code = ''
												--,@p_sub_department_name = ''
												--,@p_units_code			= ''
												--,@p_units_name			= ''
												,@p_status				= 'NEW'
												,@p_maintenance_by		= 'EXT'
												,@p_vendor_code			= @vendor_code
												,@p_vendor_name			= @vendor_name
												,@p_remark				= ''
												,@p_actual_km			= 0
												,@p_work_date			= @mod_date
												,@p_service_type		= 'ROUTINE'
												,@p_cre_date			= @mod_date
												,@p_cre_by				= @mod_by
												,@p_cre_ip_address		= @mod_ip_address
												,@p_mod_date			= @mod_date
												,@p_mod_by				= @mod_by
												,@p_mod_ip_address		= @mod_ip_address

				-- Insert ke ke maintenance detail berdasrkan service per asset

				exec dbo.xsp_maintenance_detail_insert @p_id								= 0
				    									,@p_maintenance_code				= @code
				    									,@p_service_code					= @service_code
				    									,@p_service_name					= @service_name
				    									,@p_file_name						= null
				    									,@p_path							= null
				    									,@p_quantity						= 0
				    									,@p_pph_amount						= null
				    									,@p_ppn_amount						= null
				    									,@p_service_amount					= null
				    									,@p_asset_maintenance_schedule_id	= @maintenance_id
				    									,@p_cre_date						= @mod_date
				    									,@p_cre_by							= @mod_by
				    									,@p_cre_ip_address					= @mod_ip_address
				    									,@p_mod_date						= @mod_date
				    									,@p_mod_by							= @mod_by
				    									,@p_mod_ip_address					= @mod_ip_address
			
			    fetch next from curr_eod_main 
				into @asset_code
					,@branch_code
					,@branch_name
					,@requestor_code
					,@vendor_code
					,@vendor_name
					,@maintenance_id
					,@service_code
					,@service_name

				--Update reff no di maintenance schedule
				--update	dbo.asset_maintenance_schedule
				--set		reff_trx_no			= @code
				--		--
				--		,mod_date			= @p_mod_date
				--		,mod_by				= @p_mod_by
				--		,mod_ip_address		= @p_mod_ip_address
				--where	id					= @maintenance_id
			end
			
			close curr_eod_main
			deallocate curr_eod_main
				
		end
	end try
	begin catch
		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
	
end
	

