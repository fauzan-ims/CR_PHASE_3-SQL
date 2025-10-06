CREATE procedure [dbo].[xsp_document_tbo_document_tbo_update_for_is_valid]
(
	@p_id			   bigint
	,@p_is_valid	   nvarchar(1)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_is_valid = 'T')
		begin
			set @p_is_valid = '1' ;
		end ;
		else
		begin
			set @p_is_valid = '0' ;
		end ;

		update	dbo.document_tbo_document_tbo
		set		is_valid		= @p_is_valid
				--
				,mod_by			= @p_mod_by
				,mod_date		= @p_mod_date
				,mod_ip_address = @p_mod_ip_address
		where	id = @p_id ;
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
