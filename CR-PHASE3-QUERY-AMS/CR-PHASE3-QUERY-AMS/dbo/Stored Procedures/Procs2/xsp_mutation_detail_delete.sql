CREATE PROCEDURE dbo.xsp_mutation_detail_delete
(
	@p_id bigint
)
as
begin
	declare @msg	 nvarchar(max)
			,@status nvarchar(20) ;

	begin try
		select	@status = status_received
		from	dbo.mutation_detail
		where	id = @p_id ;

		if @status = 'RECEIVED'
		begin
			set @msg = 'Assets that have been received cannot be deleted' ;

			raiserror(@msg, 16, -1) ;
		end ;

		delete mutation_detail
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
