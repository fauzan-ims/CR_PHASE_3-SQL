CREATE PROCEDURE dbo.xsp_document_main_update
(
	@p_code					 nvarchar(50)
	,@p_estimate_return_date datetime
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@movement_remark	nvarchar(4000)
			,@document_code		nvarchar(50)
			,@document_status	nvarchar(20)
			,@movement_type		nvarchar(20)
			,@movement_location nvarchar(20)
			,@movement_from		nvarchar(50)
			,@movement_to		nvarchar(50)
			,@movement_by		nvarchar(250)
			,@locker_position	nvarchar(10)
			,@locker_code		nvarchar(50)
			,@drawer_code		nvarchar(50)
			,@row_code			nvarchar(50)
			,@movement_date		datetime ;

	begin try
		if exists
		(
			select	1
			from	dbo.document_main
			where	code					 = @p_code
					and estimate_return_date <> @p_estimate_return_date
		)
		begin
			update	document_main
			set		estimate_return_date = @p_estimate_return_date
					--
					,mod_date			 = @p_mod_date
					,mod_by				 = @p_mod_by
					,mod_ip_address		 = @p_mod_ip_address
			where	code				 = @p_code ;
		
			select top 1
						@document_status = dh.document_status
						,@movement_type = dh.movement_type
						,@movement_location = dh.movement_location
						,@movement_from = dh.movement_from
						,@movement_to = dh.movement_to
						,@movement_date = dh.movement_date
						,@locker_position = dh.locker_position
						,@locker_code = dh.locker_code
						,@drawer_code = dh.drawer_code
						,@row_code = dh.row_code
			from		dbo.document_history dh
			where		document_code = @p_code
			order by	dh.cre_date desc ;

			set @movement_remark = 'Estimate Return Date Update : ' + convert(nvarchar(15), @p_estimate_return_date, 103)

			exec dbo.xsp_document_history_insert @p_id						= 0
												 ,@p_document_code			= @p_code
												 ,@p_document_status		= @document_status	
												 ,@p_movement_type			= @movement_type		
												 ,@p_movement_location		= @movement_location	
												 ,@p_movement_from			= @movement_from		
												 ,@p_movement_to		    = @movement_to		
												 ,@p_movement_by		    = @movement_by		
												 ,@p_movement_date			= @movement_date		
												 ,@p_movement_return_date	= @p_estimate_return_date
												 ,@p_locker_position	    = @locker_position
												 ,@p_locker_code		    = @locker_code
												 ,@p_drawer_code		    = @drawer_code
												 ,@p_row_code				= @row_code	
												 ,@p_remarks				= @movement_remark
												 ,@p_cre_date				= @p_mod_date
												 ,@p_cre_by					= @p_mod_by
												 ,@p_cre_ip_address			= @p_mod_ip_address
												 ,@p_mod_date				= @p_mod_date
												 ,@p_mod_by					= @p_mod_by
												 ,@p_mod_ip_address			= @p_mod_ip_address ;
		end ;
	end try
	begin catch 

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
