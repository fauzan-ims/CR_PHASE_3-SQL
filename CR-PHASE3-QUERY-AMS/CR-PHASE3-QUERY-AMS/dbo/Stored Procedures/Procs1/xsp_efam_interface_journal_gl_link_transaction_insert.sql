CREATE PROCEDURE dbo.xsp_efam_interface_journal_gl_link_transaction_insert
(
	@p_code						nvarchar(50) output
	,@p_company_code			nvarchar(50)
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_transaction_status		nvarchar(10)
	,@p_transaction_date		datetime
	,@p_transaction_value_date	datetime
	,@p_transaction_code		nvarchar(50)
	,@p_transaction_name		nvarchar(250)
	,@p_reff_module_code		nvarchar(10)
	,@p_reff_source_no			nvarchar(50)
	,@p_reff_source_name		nvarchar(250)
	,@p_is_journal_reversal		nvarchar(1) = '0'
	,@p_transaction_type		nvarchar(50)
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
	declare @msg			nvarchar(max)
			,@year			nvarchar(2)
			,@month			nvarchar(2)
			,@code			nvarchar(50)
			,@branch_code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'ABJT'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'EFAM_INTERFACE_JOURNAL_GL_LINK_TRANSACTION'
												,@p_run_number_length = 6
												,@p_delimiter = ''
												,@p_run_number_only = N'0'
												,@p_specified_column = '' ;
	

	begin try
		insert into dbo.efam_interface_journal_gl_link_transaction
		(
			code
			,company_code
			,branch_code
			,branch_name
			,transaction_status
			,transaction_date
			,transaction_value_date
			,transaction_code
			,transaction_name
			,reff_module_code
			,reff_source_no
			,reff_source_name
			,is_journal_reversal
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
			,@p_company_code
			,@p_branch_code
			,@p_branch_name
			,@p_transaction_status
			,@p_transaction_date
			,@p_transaction_value_date
			,@p_transaction_code
			,@p_transaction_name
			,@p_reff_module_code
			,@p_reff_source_no
			,@p_reff_source_name
			,@p_is_journal_reversal
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



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_efam_interface_journal_gl_link_transaction_insert] TO [ims-raffyanda]
    AS [dbo];

