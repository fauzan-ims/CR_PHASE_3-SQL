CREATE PROCEDURE dbo.xsp_suspend_main_update
(
	@p_code				 nvarchar(50)
	,@p_branch_code		 nvarchar(50)
	,@p_branch_name		 nvarchar(250)
	,@p_suspend_date	 datetime
	,@p_suspend_amount	 decimal(18, 2)
	,@p_suspend_remarks	 nvarchar(4000)
	,@p_used_amount		 decimal(18, 2)
	,@p_remaining_amount decimal(18, 2)
	,@p_reff_name		 nvarchar(250)
	,@p_reff_no			 nvarchar(50)
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	suspend_main
		set		branch_code			= @p_branch_code
				,branch_name		= @p_branch_name
				,suspend_date		= @p_suspend_date
				,suspend_amount		= @p_suspend_amount
				,suspend_remarks	= @p_suspend_remarks
				,used_amount		= @p_used_amount
				,remaining_amount	= @p_remaining_amount
				,reff_name			= @p_reff_name
				,reff_no			= @p_reff_no
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
