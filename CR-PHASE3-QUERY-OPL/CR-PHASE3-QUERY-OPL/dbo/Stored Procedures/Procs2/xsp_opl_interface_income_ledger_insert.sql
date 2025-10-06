CREATE PROCEDURE dbo.xsp_opl_interface_income_ledger_insert
(
	@p_asset_code				nvarchar(50)
	,@p_date					datetime
	,@p_reff_code				nvarchar(50)
	,@p_reff_name				nvarchar(250)
	,@p_reff_remark				nvarchar(4000)
	,@p_income_amount			decimal(18,2)
	,@p_agreement_no			nvarchar(50)
	,@p_client_name				nvarchar(250)
	,@p_job_status				nvarchar(250)
	,@p_failed_remark			nvarchar(250)
	--
	,@p_cre_date				datetime
	,@p_cre_by					nvarchar(15)
	,@p_cre_ip_address			nvarchar(15)
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2)
			,@msg	nvarchar(max) ;

	begin try
		--set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		--set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		--exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
		--											,@p_branch_code = @p_branch_code
		--											,@p_sys_document_code = N''
		--											,@p_custom_prefix = 'OPLIL'
		--											,@p_year = @year
		--											,@p_month = @month
		--											,@p_table_name = 'OPL_INTERFACE_INCOME_LEDGER'
		--											,@p_run_number_length = 6
		--											,@p_delimiter = '.'
		--											,@p_run_number_only = N'0' ;

		insert into dbo.opl_interface_income_ledger
		(
			asset_code
			,date
			,reff_code
			,reff_name
			,reff_remark
			,income_amount
			,agreement_no
			,client_name
			,job_status
			,failed_remark
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_asset_code
			,@p_date
			,@p_reff_code
			,@p_reff_name
			,@p_reff_remark
			,@p_income_amount
			,@p_agreement_no
			,@p_client_name
			,@p_job_status
			,@p_failed_remark
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) 
		;

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

