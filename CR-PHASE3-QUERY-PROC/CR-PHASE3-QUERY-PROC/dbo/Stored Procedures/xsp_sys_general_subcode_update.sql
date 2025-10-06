CREATE PROCEDURE dbo.xsp_sys_general_subcode_update
(
	@p_code				nvarchar(50)
	,@p_company_code	nvarchar(50)
	,@p_general_code	nvarchar(50)
	,@p_order_key		int
	,@p_description		nvarchar(4000)
	,@p_is_active		nvarchar(1)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	begin TRY
		
		if exists
		(
			select	1
			from	sys_general_subcode
			where	code <> @p_code
			and		general_code	= @p_general_code
			and		description		= @p_description
			and		company_code	= @p_company_code
					
		)
		begin
			set @msg = 'Description already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		update	sys_general_subcode
		set		general_code	= @p_general_code
				,order_key		= @p_order_key
				,description	= upper(@p_description)
				,is_active		= @p_is_active
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code 
		and		company_code	= @p_company_code;
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
