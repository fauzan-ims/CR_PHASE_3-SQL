create PROCEDURE dbo.xsp_repossession_main_validate
(
	@p_code						nvarchar(50)
	,@p_permit_sell_remarks		nvarchar(250)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max);

	begin try

		if exists
		(
			select	1
			from	repossession_main
			where	code					= @p_code
					and is_permit_to_sell	= '1'
		)
		begin
			update	dbo.repossession_main
			set		is_permit_to_sell		= '0'
					,permit_sell_remarks	= @p_permit_sell_remarks
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;
		end ;
		else
		begin
			update	dbo.repossession_main
			set		is_permit_to_sell		= '1'
					,permit_sell_remarks	= @p_permit_sell_remarks
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	code					= @p_code ;
		end ;
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
			set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
