CREATE PROCEDURE dbo.xsp_application_financial_analysis_insert
(
	@p_code			   nvarchar(50) output
	,@p_application_no nvarchar(50)
	,@p_periode_year   nvarchar(4)
	,@p_periode_month  nvarchar(2)
	,@p_dsr_pct		   decimal(9, 6) = 0
	,@p_idir_pct	   decimal(9, 6) = 0
	,@p_dbr_pct		   decimal(9, 6) = 0
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = ''
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'AFA'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'APPLICATION_FINANCIAL_ANALYSIS'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0' ;

	begin try
		if @p_periode_year + @p_periode_month >  convert(varchar(6), dbo.xfn_get_system_date(),112)
		begin
			set @msg = 'Period must be less or equal than System Date';
			raiserror(@msg, 16, -1) ;
		end
		if exists (select 1 from application_financial_analysis where application_no = @p_application_no and periode_year = @p_periode_year and periode_month = @p_periode_month)
		begin
    		set @msg = 'Period Year and Month already exists';
    		raiserror(@msg, 16, -1) ;
		end

		insert into application_financial_analysis
		(
			code
			,application_no
			,periode_year
			,periode_month
			,dsr_pct
			,idir_pct
			,dbr_pct
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@code
			,@p_application_no
			,@p_periode_year
			,@p_periode_month
			,@p_dsr_pct
			,@p_idir_pct
			,@p_dbr_pct
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_code = @code ;

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

