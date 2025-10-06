CREATE PROCEDURE [dbo].[xsp_master_contract_document_update]
(
	@p_id			   bigint
	,@p_remark		   nvarchar(4000) = ''
	,@p_promise_date   datetime		  = null
	,@p_expired_date   datetime		  = null
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (
			   @p_promise_date is not null
			   and	@p_expired_date is not null
		   )
		begin
			set @msg = N'Cannot insert promise date and expired date together, insert one of them.' ;

			raiserror(@msg, 16, 1) ;
		end ;

		update	dbo.master_contract_document
		set		remarks			= @p_remark
				,promise_date	= @p_promise_date
				,expired_date	= @p_expired_date
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
