CREATE PROCEDURE dbo.xsp_receipt_register_update
(
	@p_code				 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_register_status	 nvarchar(10)
	,@p_register_date	 datetime
	,@p_register_remarks nvarchar(4000)
	,@p_receipt_prefix	 nvarchar(50) = null
	,@p_receipt_sequence nvarchar(50)
	,@p_receipt_postfix	 nvarchar(50) = null
	,@p_receipt_number	 int
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_register_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
			raiserror(@msg ,16,-1)
		end
		else if (@p_receipt_number > 1000)
		begin
		    set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Receipt Number','1000');
			raiserror(@msg ,16,-1)
		end

		update	receipt_register
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,register_status	= @p_register_status
				,register_date		= @p_register_date
				,register_remarks	= @p_register_remarks
				,receipt_prefix		= @p_receipt_prefix
				,receipt_sequence	= @p_receipt_sequence
				,receipt_postfix	= @p_receipt_postfix
				,receipt_number		= @p_receipt_number
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
