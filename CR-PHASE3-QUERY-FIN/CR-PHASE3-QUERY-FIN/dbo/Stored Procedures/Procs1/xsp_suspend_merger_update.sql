CREATE PROCEDURE dbo.xsp_suspend_merger_update
(
	@p_code					 nvarchar(50)
	,@p_branch_code			 nvarchar(50)
	,@p_branch_name			 nvarchar(250)
	,@p_merger_status		 nvarchar(20)
	,@p_merger_date			 datetime
	,@p_merger_amount		 decimal(18, 2)
	,@p_merger_remarks		 nvarchar(4000)
	,@p_merger_currency_code nvarchar(3)
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_merger_date > dbo.xfn_get_system_date()) 
				begin
					set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
					raiserror(@msg ,16,-1)
				end

		update	suspend_merger
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,merger_status			= @p_merger_status
				,merger_date			= @p_merger_date
				,merger_amount			= @p_merger_amount
				,merger_remarks			= @p_merger_remarks
				,merger_currency_code	= @p_merger_currency_code
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
