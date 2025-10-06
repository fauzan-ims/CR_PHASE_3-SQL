--CREATED by ALIV on 16/05/2023
CREATE PROCEDURE dbo.xsp_ifinproc_interface_handover_request_insert
(	
	@p_code							nvarchar(50) = ''	output
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_status						nvarchar(15)
	,@p_transaction_date			datetime
	,@p_type						nvarchar(15)
	,@p_remark						nvarchar(4000)
	,@p_fa_code						nvarchar(50)
	,@p_fa_name						nvarchar(250)
	,@p_handover_from				nvarchar(250)
	,@p_handover_to					nvarchar(250)
	,@p_unit_condition				nvarchar(15)
	,@p_reff_no						nvarchar(50)
	,@p_reff_name					nvarchar(250)
	,@p_handover_address			nvarchar(4000)	
	,@p_handover_phone_area			nvarchar(4)		
	,@p_handover_phone_no			nvarchar(15)	
	,@p_handover_eta_date			datetime		
	,@p_handover_code				nvarchar(50)	
	,@p_handover_bast_date			datetime		
	,@p_handover_remark				nvarchar(4000)	
	,@p_handover_status				nvarchar(15)	
	,@p_asset_status				nvarchar(15)	
	,@p_settle_date					datetime		
	,@p_job_status					nvarchar(15)	
	,@p_failed_remarks				nvarchar(4000)	
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(50)
	,@p_cre_ip_address				nvarchar(50)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(50)
	,@p_mod_ip_address				nvarchar(50)
)
as
begin
	declare @msg	nvarchar(max)
			,@code	nvarchar(50)
			,@year	nvarchar(4)
			,@month nvarchar(2);

	begin try

		set @year = substring(cast(datepart(year, @p_mod_date) as nvarchar), 3, 2) ;
		set @month = replace(str(cast(datepart(month, @p_mod_date) as nvarchar), 2, 0), ' ', '0') ;

		exec dbo.xsp_get_next_unique_code_for_table @p_unique_code			= @code output
													,@p_branch_code			= @p_branch_code
													,@p_sys_document_code	= N''
													,@p_custom_prefix		= 'PRCHR'
													,@p_year				= @year
													,@p_month				= @month
													,@p_table_name			= 'IFINPROC_INTERFACE_HANDOVER_REQUEST'
													,@p_run_number_length	= 6
													,@p_delimiter			= '.'
													,@p_run_number_only		= N'0' ;

		insert into ifinproc_interface_handover_request
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
			,unit_condition		
			,reff_no			
			,reff_name			
			,handover_address	
			,handover_phone_area
			,handover_phone_no	
			,handover_eta_date	
			,handover_code		
			,handover_bast_date	
			,handover_remark	
			,handover_status	
			,asset_status		
			,settle_date		
			,job_status			
			,failed_remarks	
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
			@code				
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
			,@p_unit_condition		
			,@p_reff_no				
			,@p_reff_name			
			,@p_handover_address	
			,@p_handover_phone_area	
			,@p_handover_phone_no	
			,@p_handover_eta_date	
			,@p_handover_code		
			,@p_handover_bast_date	
			,@p_handover_remark		
			,@p_handover_status		
			,@p_asset_status		
			,@p_settle_date			
			,@p_job_status			
			,@p_failed_remarks		
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
