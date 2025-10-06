CREATE PROCEDURE [dbo].[xsp_document_movement_send_proceed]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
declare @msg						  nvarchar(max)
		,@movement_location			  nvarchar(20)
		,@request_code				  nvarchar(50)
		,@branch_code				  nvarchar(50)
		,@branch_name				  nvarchar(250)
		,@to_branch_name			  nvarchar(250)
		,@req_date					  datetime
		,@agreement_external_no		  nvarchar(50)
		,@reff_dimension_code		  nvarchar(50)
		,@interface_remarks			  nvarchar(4000)
		,@client_name				  nvarchar(250)
		,@movement_remarks			  nvarchar(250)
		,@dimension_code			  nvarchar(50)
		,@dim_value					  nvarchar(50)
		,@reff_approval_category_code nvarchar(50)
		,@asset_no					  nvarchar(50)
		,@url_path					  nvarchar(250)
		,@path						  nvarchar(250)
		,@approval_path				  nvarchar(4000)
		,@approval_dimension_code	  nvarchar(50)
		,@requestor_code			  nvarchar(50)
		,@requestor_name			  nvarchar(250) ;

	begin try 
		if not exists
		(
			select	1
			from	dbo.document_movement_detail
			where	movement_code = @p_code
		)
		begin
			set @msg = N'Please add document before Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		-- 15/12/2023 Raffy (+) penambahan kondisi untuk membedakan approval document borrow dan release
		select	@approval_dimension_code =	case 
											when movement_location = 'CLIENT' 
												then 'DOCUMENT SEND RELEASE'
											else 'DOCUMENT SEND BORROW'
											end 
		from	dbo.document_movement
		WHERE	code = @p_code

		
		-- Hari - 01.Aug.2023 01:09 PM --	validasi hanya untuk jika borrow client saja
		if exists
		(
			select	1
			from	dbo.document_movement dmv
			where	dmv.code = @p_code
			and		dmv.movement_location = 'BORROW CLIENT'
		)
		begin
			if not exists
			(
				select	1
				from		dbo.document_movement_replacement dmr
				inner join	dbo.document_movement dmv on (dmv.code = dmr.movement_code)
				where		movement_code = @p_code
				and			dmv.movement_location = 'BORROW CLIENT'
			)
			begin
				set @msg = N'Please add replacement before Proceed' ;

				raiserror(@msg, 16, -1) ;
			end ;

		end ;

	
		if exists
		(
			select	1
			from	document_movement
			where	code				= @p_code
					and movement_status <> 'HOLD'
		)
		begin 
			set @msg = N'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;
		else
		begin 
			if exists
			(
				select	1
				from	dbo.master_approval
				where	code			 = 'DOCUMENT SEND'
						and is_active	 = '1'
			)
			begin
				select	@branch_code			= branch_code
						,@branch_name			= branch_name 
						,@to_branch_name		= isnull(movement_to ,'')
						,@movement_location		= movement_location
						,@movement_remarks		= movement_remarks
				from	dbo.document_movement  dm
				where	dm.code = @p_code ;
			 
				--if exists
				--(
				--	select	1
				--	from	dbo.document_movement_detail dmd
				--			inner join dbo.document_main dm on dm.code = dmd.document_code
				--	where	dmd.movement_code	   = @p_code
				--			and isnull(is_sold,0)  = '0'
				--			and @movement_location = 'CLIENT'
				--)
				--begin
				--	select	@asset_no = dm.asset_no
				--	from	dbo.document_movement_detail dmd
				--			inner join dbo.document_main dm on dm.code = dmd.document_code
				--	where	dmd.movement_code	   = @p_code
				--			and isnull(is_sold,0)  = '0'
				--			and @movement_location = 'CLIENT'

				--	set @msg = 'Cannot release, Asset '+ @asset_no +' have not been sold yet' ;

				--	raiserror(@msg, 16, -1) ;
				--end ;

				update	dbo.document_movement
				set		movement_status = 'ON PROCESS'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;

				set @interface_remarks = 'Approval Send Document ' + @p_code + ' To ' + @movement_location + ' ' +@to_branch_name +' '+@movement_remarks ;
				set @req_date = dbo.xfn_get_system_date() ;


				select	@reff_approval_category_code = reff_approval_category_code
				from	dbo.master_approval
				where	code						 = @approval_dimension_code--'DOCUMENT SEND' ;
			
				--select path di global param
				select	@url_path = value
				from	dbo.sys_global_param
				where	code = 'URL_PATH' ;

				select	@path = @url_path + value
				from	dbo.sys_global_param
				where	code = 'DOCUMENT SEND'

				--set approval path
				set	@approval_path = @path + @p_code

				select @requestor_name = name 
				from ifinsys.dbo.sys_employee_main
				where code = @p_mod_by

				exec dbo.xsp_doc_interface_approval_request_insert @p_code						= @request_code output
																   ,@p_branch_code				= @branch_code
																   ,@p_branch_name				= @branch_name
																   ,@p_request_status			= N'HOLD'
																   ,@p_request_date				= @req_date
																   ,@p_request_amount			= 0
																   ,@p_request_remarks			= @interface_remarks
																   ,@p_reff_module_code			= N'IFINDOC'
																   ,@p_reff_no					= @p_code
																   ,@p_reff_name				= N'DOCUMENT SEND APPROVAL'
																   ,@p_paths					= @approval_path
																   ,@p_approval_category_code	= @reff_approval_category_code
																   ,@p_approval_status			= N'HOLD'
																   ,@p_requestor_code			= @p_mod_by
																   ,@p_requestor_name			= @requestor_name
																   --
																   ,@p_cre_date					= @p_mod_date
																   ,@p_cre_by					= @p_mod_by
																   ,@p_cre_ip_address			= @p_mod_ip_address
																   ,@p_mod_date					= @p_mod_date
																   ,@p_mod_by					= @p_mod_by
																   ,@p_mod_ip_address			= @p_mod_ip_address ;

				declare master_approval_dimension cursor for
                
				select  reff_dimension_code 
						,dimension_code
				from	dbo.master_approval_dimension
				where	approval_code = @approval_dimension_code--'DOCUMENT SEND'

				open master_approval_dimension		
				fetch next from master_approval_dimension
				into @reff_dimension_code 
					 ,@dimension_code
						
				while @@fetch_status = 0

				begin 

					exec dbo.xsp_get_table_value_by_dimension @p_dim_code	 = @dimension_code
															  ,@p_reff_code	 = @p_code
															  ,@p_reff_table = 'DOCUMENT SEND'
															  ,@p_output	 = @dim_value output ;

					exec dbo.xsp_doc_interface_approval_request_dimension_insert @p_id					= 0
																				 ,@p_request_code		= @request_code
																				 ,@p_dimension_code		= @reff_dimension_code
																				 ,@p_dimension_value	= @dim_value
																				 --
																				 ,@p_cre_date			= @p_mod_date
																				 ,@p_cre_by				= @p_mod_by
																				 ,@p_cre_ip_address		= @p_mod_ip_address
																				 ,@p_mod_date			= @p_mod_date
																				 ,@p_mod_by				= @p_mod_by
																				 ,@p_mod_ip_address		= @p_mod_ip_address ;
						

				fetch next from master_approval_dimension
				into @reff_dimension_code
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
		end ;
	end try
	begin catch
		if cursor_status('global', 'cursor_movement') >= -1
		begin
			if cursor_status('global', 'cursor_movement') > -1
			begin
				close cursor_movement ;
			end ;

			deallocate cursor_movement ;
		end ;

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
