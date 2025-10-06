/*
	Created : Yunus Muslim, 22 April 2020
*/
CREATE PROCEDURE dbo.xsp_document_storage_post 
(
	@p_code				nvarchar(50)
	,@p_name			nvarchar(250)
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@document_code			nvarchar(50)
			,@locker_code			nvarchar(50)
			,@drawer_code			nvarchar(50)
			,@row_code				nvarchar(50)
			,@remark				nvarchar(4000)
			,@storage_type			nvarchar(20)
			,@movement_date			datetime

	begin try
		 
		select	@locker_code			= ds.locker_code
				,@drawer_code			= ds.drawer_code
		 		,@row_code				= ds.row_code
				,@storage_type			= ds.storage_type
				,@remark				= ds.remark
				,@movement_date			= ds.storage_date
		from	dbo.document_storage ds
		where	ds.code			= @p_code
		
		if exists (select 1 from dbo.document_storage where code = @p_code and storage_status <> 'HOLD')
		begin
		    raiserror('Data already proceed',16,1) ;
		end
		else
		begin
			if not exists (select 1 from dbo.document_storage_detail where document_storage_code = @p_code)
			begin
            set @msg = 'Please add document before posting'
				raiserror(@msg,16,1)
			end
                
			declare doc_cur	cursor local fast_forward for
			select	document_code
			from	dbo.document_storage_detail
			where	document_storage_code = @p_code
						
			open doc_cur
			fetch next from doc_cur  
			into	@document_code

			while @@fetch_status = 0
			begin
				
				begin
					SET @remark = @storage_type +' : ' + @remark
                
					if @storage_type = 'RETRIVE'
					begin
						select 
								@locker_code	 = locker_code
								,@drawer_code	 = drawer_code
								,@row_code		 = row_code	
						 from dbo.document_main
						 where	code			= @document_code

					    update	dbo.document_main
						set		locker_position			= 'OUT LOCKER'
								,last_locker_position	= 'IN LOCKER'		
								,last_locker_code		= @locker_code
								,last_drawer_code		= @drawer_code
								,last_row_code			= @row_code	
								,locker_code			= null
								,drawer_code			= null
								,row_code				= null
								--
								,mod_date				= @p_mod_date		
								,mod_by					= @p_mod_by			
								,mod_ip_address			= @p_mod_ip_address	
						where	code					= @document_code
						
						exec dbo.xsp_document_history_insert @p_id						= 0
															 ,@p_document_code			= @document_code
															 ,@p_document_status		= 'ON HAND'		
															 ,@p_movement_type			= 'RETRIVE'			
															 ,@p_movement_location		= 'BRANCH'		
															 ,@p_movement_from			= 'LOCKER'			
															 ,@p_movement_to			= 'BRANCH'
															 ,@p_movement_by			= @p_name			
															 ,@p_movement_date			= @movement_date			
															 ,@p_movement_return_date	= null
															 ,@p_locker_position		= 'OUT LOCKER'
															 ,@p_locker_code			= null
															 ,@p_drawer_code			= null
															 ,@p_row_code				= null
															 ,@p_remarks				= @remark
															 ,@p_cre_date				= @p_cre_date		
															 ,@p_cre_by					= @p_cre_by			
															 ,@p_cre_ip_address			= @p_cre_ip_address
															 ,@p_mod_date				= @p_mod_date		
															 ,@p_mod_by					= @p_mod_by			
															 ,@p_mod_ip_address			= @p_mod_ip_address
						
					end
					else if @storage_type = 'STORE'
					begin
					    update	dbo.document_main
						set		locker_position	= 'IN LOCKER'
								,locker_code	= @locker_code
								,drawer_code	= @drawer_code
								,row_code		= @row_code		
								,last_locker_code	  = null
								,last_drawer_code	  = null
								,last_row_code		  = null					
								--
								,mod_date		= @p_mod_date		
								,mod_by			= @p_mod_by			
								,mod_ip_address	= @p_mod_ip_address	
						where	code			= @document_code
						exec dbo.xsp_document_history_insert @p_id						= 0
															 ,@p_document_code			= @document_code
															 ,@p_document_status		= 'ON HAND'		
															 ,@p_movement_type			= 'STORE'
															 ,@p_movement_location		= 'BRANCH'		
															 ,@p_movement_from			= 'BRANCH'			
															 ,@p_movement_to			= 'LOCKER'			
															 ,@p_movement_by			=  @p_name		
															 ,@p_movement_date			= @movement_date			
															 ,@p_movement_return_date	= null
															 ,@p_locker_position		= 'IN LOCKER'
															 ,@p_locker_code			= @locker_code
															 ,@p_drawer_code			= @drawer_code
															 ,@p_row_code				= @row_code
															 ,@p_remarks				= @remark
															 ,@p_cre_date				= @p_cre_date		
															 ,@p_cre_by					= @p_cre_by			
															 ,@p_cre_ip_address			= @p_cre_ip_address
															 ,@p_mod_date				= @p_mod_date		
															 ,@p_mod_by					= @p_mod_by			
															 ,@p_mod_ip_address			= @p_mod_ip_address
						
					end
				end

				fetch next from doc_cur   
				into	@document_code	
			
			end
				
			close doc_cur
			deallocate doc_cur
			
			
			update	dbo.document_storage
			set		storage_status	= 'POST'
					--
					,mod_date		= @p_mod_date		
					,mod_by			= @p_mod_by			
					,mod_ip_address	= @p_mod_ip_address	
			where	code			= @p_code 
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


