CREATE PROCEDURE dbo.xsp_reverse_disposal_proceed
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
		   ,@status					nvarchar(20)
		   ,@asset_code				nvarchar(50)
		   -- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid				int 
			,@max_day				int
			,@reverse_disposal_date	datetime
			,@company_code			nvarchar(50)

	begin try -- 
		select	@status					=  status
				,@asset_code			= rdd.asset_code
				,@reverse_disposal_date = rd.reverse_disposal_date
				,@company_code		    = rd.company_code

		from	dbo.reverse_disposal rd
		left join dbo.reverse_disposal_detail rdd on rd.code = (rdd.reverse_disposal_code)
		where	code = @p_code ;

		-- Asqal 12-Oct-2022 ket : for WOM to control back date based on setting (+) ====
		set @is_valid = dbo.xfn_date_validation(@reverse_disposal_date)
		select @max_day = cast(value as int) from dbo.sys_global_param where code = 'MDT'

		if @is_valid = 0
		begin
			set @msg = 'The maximum back date input transaction is ' + cast(@max_day as char(2)) + ' in each month';
			raiserror(@msg ,16,-1);	    
		end
		
		-- Arga 06-Nov-2022 ket : request wom back date only for register aset (+)
		if datediff(month,@reverse_disposal_date,dbo.xfn_get_system_date()) > 0
		begin
			set @msg = 'Back date transactions are not allowed for this transaction';
			raiserror(@msg ,16,-1);	 
		end
		-- End of additional control ===================================================

		if (@status = 'NEW' and @asset_code is not null)
		begin
			    update	dbo.reverse_disposal
				set		status			= 'ON PROGRESS'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;

				-- send mail attachment based on setting ================================================
				--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
				--                                                ,@p_doc_code		= @p_code
				--                                                ,@p_attachment_flag = 0
				--                                                ,@p_attachment_file = ''
				--                                                ,@p_attachment_path = ''
				--                                                ,@p_company_code	= @company_code
				--                                                ,@p_trx_no			= @p_code
				--												,@p_trx_type		= 'REVERSE DISPOSAL'
				-- End of send mail attachment based on setting ================================================

		end
		else if (@status = 'NEW' and @asset_code is null)
		begin
			set @msg = 'Please Fill in the Reverse Disposal Asset';
			raiserror(@msg ,16,-1);
		end 
		else
		begin
			set @msg = 'Data already proceed.';
			raiserror(@msg ,16,-1);
		end
		
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
