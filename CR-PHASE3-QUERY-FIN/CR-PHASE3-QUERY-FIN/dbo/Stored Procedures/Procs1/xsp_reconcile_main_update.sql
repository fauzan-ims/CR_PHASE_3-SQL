CREATE PROCEDURE dbo.xsp_reconcile_main_update
(
	@p_code						  nvarchar(50)
	,@p_branch_code				  nvarchar(50)
	,@p_branch_name				  nvarchar(250)
	,@p_reconcile_status		  nvarchar(10)
	,@p_reconcile_date			  datetime
	,@p_reconcile_from_value_date datetime
	,@p_reconcile_to_value_date	  datetime
	,@p_reconcile_remarks		  nvarchar(4000)
	,@p_branch_bank_code		  nvarchar(50)
	,@p_branch_bank_name		  nvarchar(250)
	,@p_bank_gl_link_code		  nvarchar(50)
	,@p_system_amount			  decimal(18, 2)
	,@p_upload_amount			  decimal(18, 2)
	--,@p_file_name				  nvarchar(250)
	--,@p_paths					  nvarchar(250)
	--
	,@p_mod_date				  datetime
	,@p_mod_by					  nvarchar(15)
	,@p_mod_ip_address			  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		if (@p_reconcile_date > dbo.xfn_get_system_date()) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('Date','System Date');
			raiserror(@msg ,16,-1)
		end

		if (@p_reconcile_from_value_date > @p_reconcile_to_value_date) 
		begin
			set @msg = dbo.xfn_get_msg_err_must_be_lower_or_equal_than('From Date','To Date') ;
			raiserror(@msg ,16,-1)
		end

		update	reconcile_main
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,reconcile_status			= @p_reconcile_status
				,reconcile_date				= @p_reconcile_date
				,reconcile_from_value_date	= @p_reconcile_from_value_date
				,reconcile_to_value_date	= @p_reconcile_to_value_date
				,reconcile_remarks			= @p_reconcile_remarks
				,branch_bank_code			= @p_branch_bank_code
				,branch_bank_name			= @p_branch_bank_name
				,bank_gl_link_code			= @p_bank_gl_link_code
				,system_amount				= @p_system_amount
				,upload_amount				= @p_upload_amount
				--,file_name					= @p_file_name
				--,paths						= @p_paths
				--
				,mod_date					= @p_mod_date
				,mod_by						= @p_mod_by
				,mod_ip_address				= @p_mod_ip_address
		where	code						= @p_code ;
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
