--CREATED by ALIV on 16/05/2023
CREATE PROCEDURE  xsp_ifinproc_interface_handover_request_update
(
	@p_id							bigint		
	,@p_code						nvarchar(50)
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
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(50)
	,@p_mod_ip_address				nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	ifinproc_interface_handover_request
		set		code					= @p_code				
				,branch_code			= @p_branch_code			
				,branch_name			= @p_branch_name			
				,status					= @p_status				
				,transaction_date		= @p_transaction_date	
				,type					= @p_type				
				,remark					= @p_remark				
				,fa_code				= @p_fa_code				
				,fa_name				= @p_fa_name				
				,handover_from			= @p_handover_from		
				,handover_to			= @p_handover_to			
				,unit_condition			= @p_unit_condition		
				,reff_no				= @p_reff_no				
				,reff_name				= @p_reff_name			
				,handover_address		= @p_handover_address	
				,handover_phone_area	= @p_handover_phone_area	
				,handover_phone_no		= @p_handover_phone_no	
				,handover_eta_date		= @p_handover_eta_date	
				,handover_code			= @p_handover_code		
				,handover_bast_date		= @p_handover_bast_date	
				,handover_remark		= @p_handover_remark		
				,handover_status		= @p_handover_status		
				,asset_status			= @p_asset_status		
				,settle_date			= @p_settle_date			
				,job_status				= @p_job_status			
				,failed_remarks			= @p_failed_remarks		
				--						
				,mod_date				= @p_mod_date			
				,mod_by					= @p_mod_by				
				,mod_ip_address			= @p_mod_ip_address		
		
		where	id = @p_id ;
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
