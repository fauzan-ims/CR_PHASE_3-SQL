CREATE PROCEDURE dbo.xsp_fin_interface_received_request_upload_cancel
(
	@p_cre_date		   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin

	declare		@msg				nvarchar(max) 
				,@primary_key		nvarchar(250);

	begin TRY
    
		declare c_received_request cursor for

		select	primary_key
		from	dbo.core_upload_generic
		where	table_name	= 'FIN_INTERFACE_RECEIVED_REQUEST'
		and		cre_by		= @p_cre_by

		open	c_received_request
		fetch	c_received_request
		into	@primary_key

		while @@fetch_status = 0
		begin
			
			delete	dbo.upload_error_log
			where	primary_column_name = @primary_key

			delete	dbo.core_upload_generic
			where	primary_key = @primary_key

			fetch	c_received_request
			into	@primary_key

		end
		close c_received_request
		deallocate c_received_request

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
