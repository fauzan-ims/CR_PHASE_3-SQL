CREATE PROCEDURE dbo.xsp_application_financial_analysis_update
(
	@p_code			   nvarchar(50)
	,@p_application_no nvarchar(50)
	,@p_periode_year   nvarchar(4)
	,@p_periode_month  nvarchar(2)
	,@p_dsr_pct		   decimal(9, 6) = 0
	,@p_idir_pct	   decimal(9, 6) = 0
	,@p_dbr_pct		   decimal(9, 6) = 0
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
			set @msg = 'Period must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if exists 
		(
			select	1
			from	application_financial_analysis
			where	application_no	  = @p_application_no
					and periode_year  = @p_periode_year
					and periode_month = @p_periode_month
					and	code		  <> @p_code
		)
		begin
    		set @msg = 'Period Year and Month already exists';
    		raiserror(@msg, 16, -1) ;
		end;

		update	application_financial_analysis
		set		application_no	= @p_application_no
				,periode_year	= @p_periode_year 
				,periode_month	= @p_periode_month
				,dsr_pct		= @p_dsr_pct
				,idir_pct		= @p_idir_pct
				,dbr_pct		= @p_dbr_pct
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
	end try
	Begin catch
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

