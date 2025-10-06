CREATE PROCEDURE dbo.xsp_journal_gl_link_update
(
	@p_code							nvarchar(50)
	,@p_gl_link_name				nvarchar(250)
	,@p_is_bank						nvarchar(1)
	,@p_is_active					nvarchar(1)
	,@p_is_provit_or_cost			nvarchar(1)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
BEGIN

	declare @msg nvarchar(max) ;

	if @p_is_bank = 'T'
		set @p_is_bank = '1' ;
	else
		set @p_is_bank = '0' ;

	if @p_is_active = 'T'
		set @p_is_active = '1' ;
	else
		set @p_is_active = '0' ;

	if @p_is_provit_or_cost = 'T'
		set @p_is_provit_or_cost = '1' ;
	else
		set @p_is_provit_or_cost = '0' ;

	begin try
		
		if exists (select 1 from journal_gl_link where gl_link_name = @p_gl_link_name and code <> @p_code)
		begin
			set @msg = 'Name already used';
			raiserror(@msg, 16, -1) ;
		end
        
		update	dbo.journal_gl_link
		set		gl_link_name		= upper(@p_gl_link_name)
				,is_bank			= @p_is_bank
				,is_active			= @p_is_active
				,is_provit_or_cost	= @p_is_provit_or_cost
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code ;

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
