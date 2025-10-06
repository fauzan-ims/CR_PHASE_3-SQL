CREATE PROCEDURE dbo.xsp_change_category_return_journal_trial
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@status		nvarchar(20)
			,@asset_code	nvarchar(50) 

	begin try  
		select	@status			= status 
				,@asset_code	= asset_code
		from	dbo.change_category
		where	code = @p_code ;

		if (@status = 'POST')
		begin
			update	dbo.change_category
			set		status			= 'ON PROGRESS'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code = @p_code;

			delete	dbo.efam_interface_journal_gl_link_transaction 
			where	transaction_code = @p_code ;

			delete dbo.asset_mutation_history
			where document_refference_no = @p_code

			delete dbo.asset_depreciation_schedule_commercial
			where asset_code = @asset_code

			delete dbo.asset_depreciation_schedule_fiscal
			where asset_code = @asset_code

			delete dbo.asset_barcode_history
			where asset_code = @asset_code
		end
		
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
