CREATE procedure [dbo].[xsp_due_date_change_transaction_update]
(
	@p_id					 bigint
	,@p_due_date_change_code nvarchar(50)
	,@p_is_every_eom		 nvarchar(1) = 'F'
	,@p_new_due_date_day	 datetime	 = null
	--
	,@p_mod_date			 datetime
	,@p_mod_by				 nvarchar(15)
	,@p_mod_ip_address		 nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if @p_is_every_eom = 'T'
			set @p_is_every_eom = '1' ;
		else
			set @p_is_every_eom = '0' ;

		if (@p_new_due_date_day is null)
		begin
			set @msg = N'Please Insert New Due Date.' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if @p_is_every_eom = '1'
		begin
			if @p_new_due_date_day <> eomonth(@p_new_due_date_day)
			begin
				set @msg = N'New Due Date Must be End Of Month.' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		update	dbo.due_date_change_detail
		set		is_every_eom		= @p_is_every_eom
				,new_due_date_day	= @p_new_due_date_day
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id ;
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
