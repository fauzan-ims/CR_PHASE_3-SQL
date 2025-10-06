CREATE PROCEDURE dbo.xsp_replacement_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@request_id		nvarchar(50);

	begin try
		if exists
		(
			select	1
			from	dbo.replacement
			where	code			= @p_code
					and status		= 'HOLD'
		)
		begin

			select	@request_id			= rpd.replacement_request_detail_id--rpd.replacement_request_id
			from	dbo.replacement rpl
					inner join dbo.replacement_detail rpd on (rpl.code = rpd.replacement_code)
			where	code				= @p_code ;

			update	dbo.replacement
			set		status				= 'CANCEL'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code

			update	dbo.replacement_request
			set		status				= 'HOLD'
					,replacement_code	= null
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	replacement_code	= @p_code --id	= @request_id ;

			update	dbo.replacement_request_detail
			set		replacement_code	= null
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	replacement_code	= @p_code --replacement_request_id	= @request_id ;
			
		end ;												  
		else												  
		begin
			set @msg = 'Data already Cancel'
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
