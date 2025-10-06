/*
exec dbo.xsp_application_doc_request_waive @p_id = 0 -- bigint
										   ,@p_mod_date = '2023-02-28 10.16.41' -- datetime
										   ,@p_mod_by = N'' -- nvarchar(15)
										   ,@p_mod_ip_address = N'' -- nvarchar(15)

*/
-- Louis Selasa, 28 Februari 2023 17.16.21 --
CREATE PROCEDURE dbo.xsp_application_doc_request_waive
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_doc
			where	id							 = @p_id
					and isnull(waive_status, 'HOLD') = 'HOLD'
		)
		begin
			update	dbo.application_doc
			set		waive_status		= 'REQUEST'
					,waive_request_date	= dbo.xfn_get_system_date()
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	id					= @p_id ;
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, 1) ;
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
