CREATE PROCEDURE dbo.xsp_claim_progress_delete
(
	@p_id bigint
)
as
begin
	declare @msg   nvarchar(max) 
			,@date date;

	begin try
		select @date = claim_progress_date
		from   dbo.claim_progress
		where  id = @p_id

		if (@date <> dbo.xfn_get_system_date())
		begin
			set @msg = 'Date must be same as the System Date' ;

			raiserror(@msg, 16, -1) ;
		end
        else
		begin
			delete claim_progress
			where	id = @p_id ;
		end
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

