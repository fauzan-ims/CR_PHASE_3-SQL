-- Stored Procedure

-- Louis Rabu, 28 Desember 2022 11.32.32 -- 
CREATE PROCEDURE dbo.xsp_write_off_main_proceed
(
	@p_code						nvarchar(50)
	--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)	
	,@p_mod_ip_address			nvarchar(15)
)

as
begin
	declare @msg							nvarchar(max)
			,@branch_code					nvarchar(50)
			,@process_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@interface_remarks				nvarchar(4000)
			,@agreement_no					nvarchar(50)
			,@req_date						datetime
			,@wo_amount						decimal(18, 2)
			,@client_name					nvarchar(250)
			,@reff_approval_category_code	nvarchar(50)
			,@code							nvarchar(50)
			,@request_code					nvarchar(50)
			,@approval_code					nvarchar(50)
			,@reff_dimension_code			nvarchar(50)
			,@reff_dimension_name			nvarchar(250)
			,@dimension_code				nvarchar(50)
			,@table_name					nvarchar(50)
			,@primary_column				nvarchar(50)
			,@dim_code						nvarchar(50)
			,@dim_value						nvarchar(50)
			,@is_approval					nvarchar(1)
			,@path							nvarchar(250)
			,@url_path						nvarchar(250)
			,@approval_path					nvarchar(4000);
	
	begin try
		

		select	@process_code	= wo_type
		from	dbo.write_off_main  
		where	code = @p_code

		if (isnull(dbo.xfn_request_check_balance('WO',@p_code,@process_code),'') <> '')
		begin
			set @msg = dbo.xfn_request_check_balance('WO',@p_code,@process_code);
			raiserror(@msg, 16, 1) ;
		end

		if exists(select 1 from dbo.write_off_main where code = @p_code and wo_status <> 'HOLD')
		begin
			set @msg ='Error data already proceed';
		    raiserror(@msg,16,1) ;
		end
		
		if ((select isnull(wo_type,'') from dbo.write_off_main where code = @p_code) = '')
		begin
		    set @msg = 'Please fil WO Type'
		    raiserror(@msg,16,1) ;
		end
								 
		if exists
		(
			select	1
			from	dbo.master_approval
			where	code			 = 'WRITE OFF'
					and is_active	 = '1'
		)
		begin
			select	@branch_code = wom.branch_code
					,@branch_name = wom.branch_name
					,@client_name = am.client_name
					,@wo_amount = wom.wo_amount
					,@agreement_no = am.agreement_external_no
			from	dbo.write_off_main wom
					inner join dbo.agreement_main am on (am.agreement_no = wom.agreement_no)
			where	wom.code = @p_code ;

			set @interface_remarks = 'Approval Write Off ' + @agreement_no + ' - ' + @client_name ;
			set @req_date = dbo.xfn_get_system_date() ;

			select	@reff_approval_category_code = reff_approval_category_code
			from	dbo.master_approval
			where	code						 = 'WRITE OFF' ;

			update dbo.write_off_main
			set		wo_status				= 'ON PROCESS'
					,mod_by					= @p_mod_by
					,mod_date				= @p_mod_date
					,mod_ip_address			= @p_mod_ip_address
			where   code					= @p_code
			
			--select path di global param
			select	@url_path = value
			from	dbo.sys_global_param
			where	code = 'URL_PATH' ;

			select	@path = @url_path + value
			from	dbo.sys_global_param
			where	code = 'APVWRO'

			--set approval path
			set	@approval_path = @path + @p_code
					 
			exec dbo.xsp_opl_interface_approval_request_insert @p_code						= @request_code output -- nvarchar(50)
															   ,@p_branch_code				= @branch_code
															   ,@p_branch_name				= @branch_name
															   ,@p_request_status			= N'HOLD'
															   ,@p_request_date				= @req_date
															   ,@p_request_amount			= @wo_amount
															   ,@p_request_remarks			= @interface_remarks
															   ,@p_reff_module_code			= N'IFINOPL'
															   ,@p_reff_no					= @p_code
															   ,@p_reff_name				= N'WRITE OFF APPROVAL'
															   ,@p_paths					= @approval_path
															   ,@p_approval_category_code	= @reff_approval_category_code
															   ,@p_approval_status			= N'HOLD'
															   ,@p_cre_date					= @p_mod_date
															   ,@p_cre_by					= @p_mod_by
															   ,@p_cre_ip_address			= @p_mod_ip_address
															   ,@p_mod_date					= @p_mod_date
															   ,@p_mod_by					= @p_mod_by
															   ,@p_mod_ip_address			= @p_mod_ip_address ;
					
			declare master_approval_dimension cursor for

					select 	approval_code
							,reff_dimension_code
							,reff_dimension_name
							,dimension_code
					from	dbo.master_approval_dimension
					where	approval_code = 'WRITE OFF'

				open master_approval_dimension		
				fetch next from master_approval_dimension
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
															,@p_reff_table	= 'WRITE_OFF_MAIN'
															,@p_output		= @dim_value output ;

				exec dbo.xsp_opl_interface_approval_request_dimension_insert @p_id					= 0
																			 ,@p_request_code		= @request_code
																			 ,@p_dimension_code		= @reff_dimension_code
																			 ,@p_dimension_value	= @dim_value
																			 ,@p_cre_date			= @p_mod_date
																			 ,@p_cre_by				= @p_mod_by
																			 ,@p_cre_ip_address		= @p_mod_ip_address
																			 ,@p_mod_date			= @p_mod_date
																			 ,@p_mod_by				= @p_mod_by
																			 ,@p_mod_ip_address		= @p_mod_ip_address ;
						

				fetch next from master_approval_dimension
				into @approval_code
					,@reff_dimension_code
					,@reff_dimension_name
					,@dimension_code
				end
						
				close master_approval_dimension
				deallocate master_approval_dimension
		end
		else
		begin
			set @msg = 'Please setting Master Approval';
			raiserror(@msg, 16, 1) ;
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




