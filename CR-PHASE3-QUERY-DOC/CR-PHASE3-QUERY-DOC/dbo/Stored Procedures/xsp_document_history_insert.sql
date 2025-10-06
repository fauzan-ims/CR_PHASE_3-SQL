CREATE PROCEDURE dbo.xsp_document_history_insert
(
	@p_id					 bigint			= 0 output
	,@p_document_code		 nvarchar(50)	= null
	,@p_document_status		 nvarchar(20)	= null
	,@p_movement_type		 nvarchar(20)	= null
	,@p_movement_location	 nvarchar(20)	= null
	,@p_movement_from		 nvarchar(50)	= null
	,@p_movement_to			 nvarchar(50)	= null
	,@p_movement_by			 nvarchar(250)	= null
	,@p_movement_date		 datetime		= null
	,@p_movement_return_date datetime		= null
	,@p_locker_position		 nvarchar(10)	
	,@p_locker_code			 nvarchar(50)	= null
	,@p_drawer_code			 nvarchar(50)	= null
	,@p_row_code			 nvarchar(50)	= null
	,@p_remarks				 nvarchar(4000)	
	--
	,@p_cre_date			 datetime
	,@p_cre_by				 nvarchar(15)
	,@p_cre_ip_address		 nvarchar(15)
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into document_history
		(
			document_code
			,document_status
			,movement_type
			,movement_location
			,movement_from
			,movement_to
			,movement_by
			,movement_date
			,movement_return_date
			,locker_position
			,locker_code
			,drawer_code
			,row_code
			,remarks
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_document_code
			,@p_document_status
			,@p_movement_type
			,@p_movement_location
			,@p_movement_from
			,@p_movement_to
			,@p_movement_by
			,@p_movement_date
			,@p_movement_return_date
			,@p_locker_position
			,@p_locker_code
			,@p_drawer_code
			,@p_row_code
			,@p_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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


