CREATE PROCEDURE dbo.xsp_document_history_update
(
	@p_id					 bigint
	,@p_document_code		 nvarchar(50)
	,@p_document_status		 nvarchar(20)
	,@p_movement_type		 nvarchar(20)
	,@p_movement_location	 nvarchar(20)
	,@p_movement_from		 nvarchar(50)
	,@p_movement_to			 nvarchar(50)
	,@p_movement_by			 nvarchar(250)
	,@p_movement_date		 datetime
	,@p_movement_return_date datetime
	,@p_locker_position		 nvarchar(10)
	,@p_locker_code			 nvarchar(50)
	,@p_drawer_code			 nvarchar(50)
	,@p_row_code			 nvarchar(50)
	,@p_remarks				 nvarchar(4000)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	document_history
		set		document_code			= @p_document_code
				,document_status		= @p_document_status
				,movement_type			= @p_movement_type
				,movement_location		= @p_movement_location
				,movement_from			= @p_movement_from
				,movement_to			= @p_movement_to
				,movement_by			= @p_movement_by
				,movement_date			= @p_movement_date
				,movement_return_date	= @p_movement_return_date
				,locker_position		= @p_locker_position
				,locker_code			= @p_locker_code
				,drawer_code			= @p_drawer_code
				,row_code				= @p_row_code
				,remarks				= @p_remarks
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
