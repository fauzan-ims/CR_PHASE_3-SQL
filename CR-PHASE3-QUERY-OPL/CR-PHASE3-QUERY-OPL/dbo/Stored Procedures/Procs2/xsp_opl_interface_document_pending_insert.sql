CREATE PROCEDURE dbo.xsp_opl_interface_document_pending_insert
(
	@p_code						nvarchar(50) output
	,@p_branch_code				nvarchar(50)
	,@p_branch_name				nvarchar(250)
	,@p_initial_branch_code		nvarchar(50)
	,@p_initial_branch_name		nvarchar(250)
	,@p_document_type			nvarchar(20)
	,@p_document_status			nvarchar(10)
	,@p_client_no				nvarchar(50)
	,@p_client_name				nvarchar(250)
	,@p_plafond_no				nvarchar(50)
	,@p_agreement_no			nvarchar(50)
	,@p_collateral_no			nvarchar(50)
	,@p_collateral_name			nvarchar(250)
	,@p_plafond_collateral_no	nvarchar(50)
	,@p_plafond_collateral_name nvarchar(250)
	,@p_asset_no				nvarchar(50)
	,@p_asset_name				nvarchar(250)
	,@p_entry_date				datetime
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
			,@code	nvarchar(50) ;

	set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

	exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
												,@p_branch_code = @p_branch_code
												,@p_sys_document_code = N''
												,@p_custom_prefix = 'OPLIDP'
												,@p_year = @year
												,@p_month = @month
												,@p_table_name = 'OPL_INTERFACE_DOCUMENT_PENDING'
												,@p_run_number_length = 6
												,@p_delimiter = '.'
												,@p_run_number_only = N'0'
												,@p_specified_column = '' ;

	begin try

		insert into dbo.opl_interface_document_pending
		(
			code
			,branch_code
			,branch_name
			,initial_branch_code
			,initial_branch_name
			,document_type
			,document_status
			,client_no
			,client_name
			,plafond_no
			,agreement_no
			,collateral_no
			,collateral_name
			,plafond_collateral_no
			,plafond_collateral_name
			,asset_no
			,asset_name
			,entry_date
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
			,@p_branch_code
			,@p_branch_name
			,@p_initial_branch_code
			,@p_initial_branch_name
			,@p_document_type
			,@p_document_status
			,@p_client_no
			,@p_client_name
			,@p_plafond_no
			,@p_agreement_no
			,@p_collateral_no
			,@p_collateral_name
			,@p_plafond_collateral_no
			,@p_plafond_collateral_name
			,@p_asset_no
			,@p_asset_name
			,@p_entry_date
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

