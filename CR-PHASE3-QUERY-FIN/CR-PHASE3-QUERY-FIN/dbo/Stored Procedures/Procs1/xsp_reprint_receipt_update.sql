CREATE PROCEDURE dbo.xsp_reprint_receipt_update
(
	@p_code					nvarchar(50)
	,@p_branch_code			nvarchar(50)
	,@p_branch_name			nvarchar(250)
	,@p_reprint_status		nvarchar(10)
	,@p_reprint_date		datetime
	,@p_reprint_reason_code nvarchar(50)
	,@p_reprint_remarks		nvarchar(4000)
	,@p_cashier_type		nvarchar(10)
	,@p_cashier_code		nvarchar(50)
	,@p_old_receipt_code	nvarchar(50)
	,@p_new_receipt_code	nvarchar(50)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_reprint_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		update	reprint_receipt
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,reprint_status			= @p_reprint_status
				,reprint_date			= @p_reprint_date
				,reprint_reason_code	= @p_reprint_reason_code
				,reprint_remarks		= @p_reprint_remarks
				,cashier_type			= @p_cashier_type
				,cashier_code			= @p_cashier_code
				,old_receipt_code		= @p_old_receipt_code
				,new_receipt_code		= @p_new_receipt_code
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code;
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
