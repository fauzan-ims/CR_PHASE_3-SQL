CREATE PROCEDURE [dbo].[xsp_asset_as_stock_approve]
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
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@request_code					nvarchar(50)
			,@req_date						datetime
			,@interface_remarks				nvarchar(4000)
			,@reff_approval_category_code	nvarchar(50)
			,@path							nvarchar(250)
			,@value_approval				nvarchar(250)
			,@approval_code					nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(250)
			,@dimension_code				nvarchar(50)
			,@dim_value						nvarchar(50)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@activity_status				nvarchar(250)
			,@url_path						nvarchar(250)
			,@approval_path					nvarchar(4000)
			,@requestor_code				nvarchar(50)
			,@requestor_name				nvarchar(250)
			
	begin try
		select	@activity_status = activity_status
		from	dbo.asset
		where	code = @p_code ;

		if @activity_status = 'APPROVAL ASSET AS STOCK'
		begin
	
			set @msg = 'Approval asset as stock on process.';
	
			raiserror(@msg, 16, -1) ;
	
		end   

		declare curr_apv cursor fast_forward read_only for
		select	branch_code
				,branch_name
		from dbo.asset
		where code = @p_code
		
		open curr_apv
		
		fetch next from curr_apv 
		into @branch_code
			,@branch_name
		
		while @@fetch_status = 0
		begin
				set @interface_remarks = 'Approval Asset As Stock ' + @p_code ;
				set @req_date = dbo.xfn_get_system_date() --getdate() ;

				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = 'STOCK' ;

				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'PATHSTOCK'

				--set approval path
				set	@approval_path = @path + @p_code

				select @requestor_name = name 
				from ifinsys.dbo.sys_employee_main
				where code = @p_mod_by
				
				exec dbo.xsp_ams_interface_approval_request_insert @p_code						= @request_code output
																   ,@p_branch_code				= @branch_code
																   ,@p_branch_name				= @branch_name
																   ,@p_request_status			= 'HOLD'
																   ,@p_request_date				= @req_date
																   ,@p_expired_date				= @req_date
																   ,@p_request_amount			= 0
																   ,@p_request_remarks			= @interface_remarks
																   ,@p_reff_module_code			= 'IFINAMS'
																   ,@p_reff_no					= @p_code
																   ,@p_reff_name				= 'APPROVAL ASSET AS STOCK'
																   ,@p_paths					= @approval_path
																   ,@p_approval_category_code	= @reff_approval_category_code
																   ,@p_approval_status			= 'HOLD'
																   ,@p_requestor_code			= @p_mod_by
																   ,@p_requestor_name			= @requestor_name
																   ,@p_cre_date					= @p_mod_date	  
																   ,@p_cre_by					= @p_mod_by		  
																   ,@p_cre_ip_address			= @p_mod_ip_address
																   ,@p_mod_date					= @p_mod_date	  
																   ,@p_mod_by					= @p_mod_by		  
																   ,@p_mod_ip_address			= @p_mod_ip_address

				declare curr_appv cursor fast_forward read_only for
				select 	approval_code
						,reff_dimension_code
						,reff_dimension_name
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = 'STOCK'

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
																,@p_reff_table	= 'ASSET'
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
																				 ,@p_mod_ip_address		= @p_mod_ip_address
					
					fetch next from curr_appv 
					into @approval_code
						,@reff_dimension_code
						,@reff_dimension_name
						,@dimension_code
				end

				close curr_appv
				deallocate curr_appv
				
		
		    fetch next from curr_apv 
			into @branch_code
				,@branch_name
		end
		
		close curr_apv
		deallocate curr_apv

		update	dbo.asset
		set		activity_status = 'APPROVAL ASSET AS STOCK'
		where	code = @p_code ;
		
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
