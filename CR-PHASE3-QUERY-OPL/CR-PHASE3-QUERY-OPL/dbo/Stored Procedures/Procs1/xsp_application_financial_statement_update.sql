CREATE PROCEDURE dbo.xsp_application_financial_statement_update
(
	@p_code			   nvarchar(50)
	,@p_application_code   nvarchar(50)
	,@p_periode_year   nvarchar(4)
	,@p_periode_month  nvarchar(2)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if @p_periode_year + @p_periode_month >  convert(varchar(6), dbo.xfn_get_system_date(),112)
		begin
			set @msg = 'Month - Year must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if exists (select 1 from application_financial_statement where application_code = @p_application_code and periode_year = @p_periode_year and periode_month = @p_periode_month and CODE <> @p_code)
		begin
    		set @msg = 'Month - Year Year and Month already exists';
    		raiserror(@msg, 16, -1) ;
		end

		update	application_financial_statement
		set		application_code	= @p_application_code
				,periode_year	= @p_periode_year
				,periode_month	= @p_periode_month
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code = @p_code ;
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

