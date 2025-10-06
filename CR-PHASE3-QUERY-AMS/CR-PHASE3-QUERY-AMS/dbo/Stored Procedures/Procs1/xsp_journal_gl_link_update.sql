CREATE PROCEDURE dbo.xsp_journal_gl_link_update
(
	@p_code				nvarchar(50)
	,@p_name			nvarchar(250)
	,@p_is_bank			nvarchar(1)
	,@p_company_code	nvarchar(50)
	,@p_is_expense		nvarchar(1)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	if @p_is_bank = 'T'
		set @p_is_bank = '1' ;
	else
		set @p_is_bank = '0' ;
	
	if @p_is_expense = 'T'
		set @p_is_expense = '1' ;
	else
		set @p_is_expense = '0' ;

	begin try
		update	journal_gl_link
		set		name				= upper(@p_name)
				,is_bank			= @p_is_bank
				,is_expense			= @p_is_expense
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code
				and company_code	= @p_company_code ;
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
