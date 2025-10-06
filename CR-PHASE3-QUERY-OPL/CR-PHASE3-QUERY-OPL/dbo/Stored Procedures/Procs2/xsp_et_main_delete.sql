CREATE procedure dbo.xsp_et_main_delete
(
	@p_code nvarchar(50)
)
as
begin
	declare @msg		   nvarchar(max)
			,@agreement_no nvarchar(50) ;

	begin try
		select	@agreement_no = agreement_no
		from	dbo.et_main
		where	code = @p_code ;

		delete	et_main
		where	code = @p_code ;

		-- update lms status
		exec dbo.xsp_agreement_main_update_opl_status @p_agreement_no = @agreement_no
													  ,@p_status = N'' ;
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
