CREATE PROCEDURE dbo.xsp_faktur_registration_delete
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		delete	dbo.faktur_registration_detail
		where	faktur_no in
				(
					select	faktur_no
					from	dbo.faktur_main
					where	status in
							(
								'NEW'
							)
							and registration_code = @p_code
				)
				and registration_code = @p_code ;

		delete	dbo.faktur_main
		where	status in
				(
					'NEW'
				)
				and registration_code = @p_code ;

		if ((
				select	count(1)
				from	dbo.faktur_registration_detail
				where	registration_code = @p_code
			) = 0
		   )
		begin
			delete	dbo.faktur_registration
			where	code = @p_code ;
		end ;
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
