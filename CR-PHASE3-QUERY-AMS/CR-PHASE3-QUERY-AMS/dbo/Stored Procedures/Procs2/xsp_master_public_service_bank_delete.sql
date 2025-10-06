CREATE procedure dbo.xsp_master_public_service_bank_delete
(
	@p_id bigint
)
as
begin
	declare @msg				  nvarchar(max)
			--
			,@is_default		  nvarchar(1)
			,@public_service_code nvarchar(50) ;

	begin try
		select	@public_service_code = public_service_code
				,@is_default = is_default
		from	dbo.master_public_service_bank
		where	id = @p_id ;

		delete master_public_service_bank
		where	id = @p_id ;

		if @is_default = '1'
		begin
			update	dbo.master_public_service_bank
			set		is_default = 1
			where	id =
			(
				select top 1
						id
				from	dbo.master_public_service_bank
				where	public_service_code = @public_service_code
			) ;
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
