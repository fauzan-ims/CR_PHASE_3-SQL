CREATE PROCEDURE dbo.xsp_agreement_deposit_main_insert
(
	@p_code						nvarchar(50) output
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_agreement_no			nvarchar(50)
	,@p_deposit_type			nvarchar(15)
	,@p_deposit_currency_code   nvarchar(3)
	,@p_deposit_amount			decimal(18, 2)
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
	declare @msg	nvarchar(max)
			,@year	nvarchar(2)
			,@month nvarchar(2)
	
	begin try	
			set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
			set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

			exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @p_code output
														,@p_branch_code = @p_branch_code
														,@p_sys_document_code = N''
														,@p_custom_prefix = 'OPLADM'
														,@p_year = @year
														,@p_month = @month
														,@p_table_name = 'AGREEMENT_DEPOSIT_MAIN'
														,@p_run_number_length = 6
														,@p_delimiter = '.'
														,@p_run_number_only = N'0' ;

	
		insert into dbo.agreement_deposit_main
		(
		    code,
		    branch_code,
		    branch_name,
		    agreement_no,
		    deposit_type,
		    deposit_currency_code,
		    deposit_amount,
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	
			@p_code						
			,@p_branch_code				
			,@p_branch_name				
			,@p_agreement_no			
			,@p_deposit_type			
			,@p_deposit_currency_code   
			,@p_deposit_amount	
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

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



