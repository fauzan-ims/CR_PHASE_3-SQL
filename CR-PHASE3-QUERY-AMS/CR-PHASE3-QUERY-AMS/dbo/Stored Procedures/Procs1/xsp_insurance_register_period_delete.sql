CREATE PROCEDURE dbo.xsp_insurance_register_period_delete
(
	@p_id bigint
)
as
begin
	declare @msg				nvarchar(max) 
			,@register_code		varchar(50) 
			,@year_period		int ;

	begin try

		select	@register_code		= register_code,
				@year_period		= year_periode
		from	insurance_register_period
		where	id					= @p_id;

		--delete	dbo.insurance_register_loading
		--where	register_code	= @register_code
		--		and year_period = @year_period;

		delete insurance_register_period
		where	id = @p_id ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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

