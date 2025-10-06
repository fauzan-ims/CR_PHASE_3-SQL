--Created, Rian 22/12/2022

CREATE PROCEDURE dbo.xsp_opl_interface_handover_asset_insert
(
	@p_code						nvarchar(50)   = '' output
	,@p_branch_code				nvarchar(50)   = ''
	,@p_branch_name				nvarchar(50)   = ''
	,@p_status					nvarchar(50)   = ''
	,@p_transaction_date		datetime	   
	,@p_type					nvarchar(50)   = ''
	,@p_remark					nvarchar(4000) = ''
	,@p_fa_code					nvarchar(50)   = ''
	,@p_fa_name					nvarchar(50)   = ''
	,@p_handover_from			nvarchar(50)   = ''
	,@p_handover_to				nvarchar(50)   = ''
	,@p_handover_address		nvarchar(4000) = null
	,@p_handover_phone_area		nchar(5)	   = null
	,@p_handover_phone_no		nvarchar(15)   = null
	,@p_handover_eta_date		datetime	   = null
	,@p_unit_condition			nvarchar(50)   = ''
	,@p_reff_no					nvarchar(50)   = ''
	,@p_reff_name				nvarchar(50)   = ''
	,@p_agreement_external_no	nvarchar(50)   = ''
	,@p_agreement_no			nvarchar(50)   = ''
	,@p_asset_no				nvarchar(50)   = ''
	,@p_client_no				nvarchar(50)   = ''
	,@p_client_name				nvarchar(250)  = ''
	,@p_bbn_location			nvarchar(250)  = ''
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
		set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code = @code output
													,@p_branch_code = @p_branch_code
													,@p_sys_document_code = N''
													,@p_custom_prefix = 'OPLHA'
													,@p_year = @year
													,@p_month = @month
													,@p_table_name = 'OPL_INTERFACE_HANDOVER_ASSET'
													,@p_run_number_length = 6
													,@p_delimiter = '.'
													,@p_run_number_only = N'0' ;

		insert into dbo.opl_interface_handover_asset
		(
			code
			,branch_code
			,branch_name
			,status
			,transaction_date
			,type
			,remark
			,fa_code
			,fa_name
			,handover_from
			,handover_to
			,handover_address
			,handover_phone_area
			,handover_phone_no
			,handover_eta_date
			,unit_condition
			,reff_no
			,reff_name
			,agreement_external_no
			,agreement_no
			,asset_no
			,client_no
			,client_name
			,bbn_location
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
			,@p_status
			,@p_transaction_date
			,@p_type
			,@p_remark
			,@p_fa_code
			,@p_fa_name
			,@p_handover_from
			,@p_handover_to
			,@p_handover_address
			,@p_handover_phone_area
			,@p_handover_phone_no
			,@p_handover_eta_date
			,@p_unit_condition
			,@p_reff_no
			,@p_reff_name
			,@p_agreement_external_no
			,@p_agreement_no
			,@p_asset_no	
			,@p_client_no
			,@p_client_name			
			,@p_bbn_location			
			--
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
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


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_opl_interface_handover_asset_insert] TO [ims-raffyanda]
    AS [dbo];

