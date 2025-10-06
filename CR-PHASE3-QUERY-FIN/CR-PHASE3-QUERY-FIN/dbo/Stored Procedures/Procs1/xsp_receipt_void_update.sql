CREATE PROCEDURE dbo.xsp_receipt_void_update
(
	@p_code				 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_void_status		 nvarchar(10)
	,@p_void_date		 datetime
	,@p_void_reason_code nvarchar(50)
	,@p_void_remarks	 nvarchar(4000)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_void_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		update	receipt_void
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,void_status		= @p_void_status
				,void_date			= @p_void_date
				,void_reason_code	= @p_void_reason_code
				,void_remarks		= @p_void_remarks
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;
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
