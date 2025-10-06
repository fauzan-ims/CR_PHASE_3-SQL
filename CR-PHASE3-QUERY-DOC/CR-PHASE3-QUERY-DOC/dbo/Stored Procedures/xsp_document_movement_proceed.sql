CREATE PROCEDURE dbo.xsp_document_movement_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@document_request_code nvarchar(50) 
			,@document_main_code	nvarchar(50)
			,@document_code			nvarchar(50)
			,@is_reject				nvarchar(1)
			,@remarks				nvarchar(4000)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@agreement_no			nvarchar(50)
			,@collateral_no			nvarchar(50)
			,@asset_no				nvarchar(50)
			,@movement_date			datetime
			,@return_date			datetime
			,@movement_type			nvarchar(50)
			,@movement_location		nvarchar(50)
			,@doc_expired_date		datetime
			,@history_status		nvarchar(20)
			,@movement_status		nvarchar(20)
			,@document_status		nvarchar(20)
			,@movement_remark		NVARCHAR(250)
			,@document_movement_from	nvarchar(250)
			,@document_movement_to		nvarchar(250)
			,@movement_to_agreement_no	nvarchar(50)
			,@movement_by_emp_name		NVARCHAR(250)
			,@movement_to_client_name	nvarchar(250)
			,@movement_to_branch_code	nvarchar(50)
			,@movement_to_branch_name	nvarchar(250)
			,@movement_to_dept_code		nvarchar(50)
			,@movement_to_dept_name		nvarchar(250)
			,@movement_from_dept_code	nvarchar(50)
			,@movement_from_dept_name	nvarchar(250)

	begin try
			select 
                   @branch_code			        = branch_code,
                   @branch_name			        = branch_name,
                   @movement_date		        = movement_date,
                   @movement_type		        = movement_type,
                   @movement_location	        = movement_location,
				   @movement_status		        = movement_status,
				   @movement_remark		        = movement_remarks,
				   @movement_by_emp_name		= movement_by_emp_name,
				   @return_date					= estimate_return_date,

				   @movement_to_agreement_no	= movement_to_agreement_no,
				   @movement_to_client_name		= movement_to_client_name,
				   @movement_to_branch_code		= movement_to_branch_code,
				   @movement_to_branch_name		= movement_to_branch_name,
				   @movement_to_dept_code		= movement_to_dept_code,
				   @movement_to_dept_name		= movement_to_dept_name,
				   @movement_from_dept_code		= movement_from_dept_code,
				   @movement_from_dept_name		= movement_from_dept_name
			from dbo.document_movement
			where code = @p_code;
		
		if not exists (select 1 from dbo.document_movement_detail where movement_code = @p_code)
		begin
			set @msg = 'Please add document before Proceed';
			raiserror(@msg, 16, -1) ;
		end

		if (@movement_status <> 'HOLD')
			begin
				raiserror('Data already proceed',16,1) ;
			end
        else
			begin
				set @movement_status = 'ON PROCESS'

				declare cursor_movement cursor fast_forward read_only for 

					select	dmd.document_code,
							is_reject,
							isnull(dmd.remarks,dr.remarks),
							isnull(dp.agreement_no,dr.agreement_no),
							isnull(dp.collateral_no,dr.collateral_no),
							isnull(dp.asset_no,dr.asset_no),
							dp.document_expired_date
					from	dbo.document_movement_detail dmd
					left join dbo.document_pending dp on dp.code = dmd.document_pending_code
					left join dbo.document_request dr on dr.code = dmd.document_request_code
					where	movement_code = @p_code
				open cursor_movement
			
				fetch next from cursor_movement into 
					@document_code	
					,@is_reject		
					,@remarks		
					,@agreement_no		
					,@collateral_no		
					,@asset_no		
					,@doc_expired_date	
				while @@fetch_status = 0
				begin
			   
				if (@movement_type = 'BORROW' ) 
				begin
					set @movement_status		= 'ON PROCESS'
					set @document_status		= 'ON TRANSIT - BORROW'
					set @history_status			= 'BORROW - PROCEED'

					if ( @movement_location = 'BRANCH')
					begin
						if @branch_code = @movement_to_branch_code
                        begin
                        	set @msg = 'To branch must be different with From Branch';
                        	raiserror(@msg, 16, -1) ;
                        end

						--validasi document yg sama dengan type borrow-branch
						if exists (select 1 from dbo.document_movement_detail dmd 
								   inner join dbo.document_movement dm on (dm.code = dmd.movement_code) 
								   where code <> @p_code 
								   and document_code = @document_code and dm.movement_status = 'HOLD' )
						begin
                        	set @msg = 'Document already used';
                        	raiserror(@msg, 16, -1) ;
                        end
                        
						set @document_movement_from = @branch_name
						set @document_movement_to	= @movement_to_branch_name

						update  dbo.document_main
						set		document_status = @document_status
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	code = @document_code
					end
					else iF ( @movement_location = 'DEPARTMENT')
					begin
                    
						set @document_movement_from = @movement_from_dept_name
						set @document_movement_to	= @movement_to_dept_name
                
						update  dbo.document_main
						set		document_status = @document_status
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	code = @document_code
					end
					else iF ( @movement_location = 'THIRD PARTY')
					begin
						
						set @document_movement_from = @document_movement_from
						SET @document_movement_to	= @document_movement_to

						UPDATE  dbo.document_main
						set		document_status = @document_status
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	code = @document_code
					end
              
				end
				else if ( @movement_type = 'RETURN')
				begin
					set @movement_status = 'ON PROCESS'
					set @document_status = 'ON TRANSIT - RETURN'
					set @history_status			= 'RETURN - PROCEED'

                	if ( @movement_location = 'BRANCH')
					BEGIN
						SET @document_movement_from = @branch_name
						set @document_movement_to	= @movement_to_branch_name

						update  dbo.document_main
						set		document_status = @document_status
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	code = @document_code
					end
					else if ( @movement_location = 'DEPARTMENT')
					begin
						set @document_movement_from = @movement_from_dept_name
						SET @document_movement_to	= @movement_to_dept_name

						UPDATE  dbo.document_main
						set		document_status = @document_status
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	code = @document_code

					end
					else if ( @movement_location = 'THIRD PARTY')
					begin
                
						set @document_movement_from = @document_movement_from
						SET @document_movement_to	= @document_movement_to

						update  dbo.document_main
						set		document_status = @document_status
								,mod_date		= @p_mod_date
								,mod_by			= @p_mod_by
								,mod_ip_address	= @p_mod_ip_address
						where	code = @document_code

					end

				end
              
				EXEC dbo.xsp_document_history_insert @p_id = 0,                             
				                                     @p_document_code = @document_code,           
				                                     @p_document_status = @document_status,       
				                                     @p_movement_type = @history_status,           
				                                     @p_movement_location = @movement_location,   
				                                     @p_movement_from = @document_movement_from,  
				                                     @p_movement_to = @document_movement_to,      
				                                     @p_movement_by = @movement_by_emp_name,      
				                                     @p_movement_date = @movement_date,       
				                                     @p_movement_return_date = @return_date,  
				                                     @p_locker_position = 'OUT LOCKER',           
				                                     @p_locker_code = null,                       
				                                     @p_drawer_code = null,                       
				                                     @p_row_code = null,                          
				                                     @p_remarks = @movement_remark,               
				                                     @p_cre_date = @p_mod_date,             
				                                     @p_cre_by = @p_mod_by,                       
				                                     @p_cre_ip_address = @p_mod_ip_address,       
				                                     @p_mod_date =@p_mod_date,              
				                                     @p_mod_by = @p_mod_by,                       
				                                     @p_mod_ip_address = @p_mod_ip_address        
				
			 
					fetch next from cursor_movement into
						@document_code	
						,@is_reject		
						,@remarks		
						,@agreement_no		
						,@collateral_no		
						,@asset_no		
						,@doc_expired_date	
				end
				
			
			close cursor_movement
			deallocate cursor_movement
			
			update	dbo.document_movement
			set		movement_status = @movement_status
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;
		end
	end try
	begin catch
		
			if cursor_status('global','cursor_movement') >= -1
			 begin
			  if cursor_status('global','cursor_movement') > -1
			   begin
				close cursor_movement
			   end
			 deallocate cursor_movement
			end

			declare  @error int
			set  @error = @@error
		 
			if ( @error = 2627)
			begin
				set @msg = dbo.xfn_get_msg_err_code_already_exist();
			end ;
			if (len(@msg) <> 0)
			begin
				set @msg = 'V' + ';' + @msg ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message();
			end ;
	
			raiserror(@msg, 16, -1) ;
			return ; 

		 end catch ;
end ;

