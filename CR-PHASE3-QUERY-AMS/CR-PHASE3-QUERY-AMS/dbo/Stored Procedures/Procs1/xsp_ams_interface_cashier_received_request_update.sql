CREATE PROCEDURE dbo.xsp_ams_interface_cashier_received_request_update
(
	@p_code					  nvarchar(50)
	,@p_branch_code			  nvarchar(50)
	,@p_branch_name			  nvarchar(250)
	,@p_request_status		  nvarchar(10)
	,@p_request_currency_code nvarchar(5)
	,@p_request_date		  datetime
	,@p_request_amount		  decimal(18, 2)
	,@p_request_remarks		  nvarchar(4000)
	,@p_fa_code				  nvarchar(50)
	,@p_pdc_code			  nvarchar(50)
	,@p_pdc_no				  nvarchar(50)
	,@p_doc_ref_code		  nvarchar(50)
	,@p_doc_ref_name		  nvarchar(250)
	,@p_process_date		  datetime
	,@p_process_reff_no		  nvarchar(50)
	,@p_process_reff_name	  nvarchar(250)
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	ams_interface_cashier_received_request
		set		branch_code				= @p_branch_code
				,branch_name			= @p_branch_name
				,request_status			= @p_request_status
				,request_currency_code	= @p_request_currency_code
				,request_date			= @p_request_date
				,request_amount			= @p_request_amount
				,request_remarks		= @p_request_remarks
				,fa_code				= @p_fa_code
				,pdc_code				= @p_pdc_code
				,pdc_no					= @p_pdc_no
				,doc_ref_code			= @p_doc_ref_code
				,doc_ref_name			= @p_doc_ref_name
				,process_date			= @p_process_date
				,process_reff_no		= @p_process_reff_no
				,process_reff_name		= @p_process_reff_name
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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



