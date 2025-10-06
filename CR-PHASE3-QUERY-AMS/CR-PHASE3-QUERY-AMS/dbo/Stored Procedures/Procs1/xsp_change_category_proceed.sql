CREATE PROCEDURE dbo.xsp_change_category_proceed
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
			-- Asqal 12-Oct-2022 ket : for WOM (+)
			,@is_valid		int 
			,@max_day		int
			,@date			datetime
			,@company_code	nvarchar(50)

	begin try -- 
		select	@status				= status
				,@date				= date
				,@company_code		= company_code
				,@asset_code		= asset_code
		from	dbo.change_category
		where	code = @p_code ;

		-- Trisna 07-Nov-2022 ket : for handle double process transaction (+)
		if exists (select 1 from dbo.change_category where asset_code = @asset_code and status in ('NEW', 'ON PROGRESS'))
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Change Category menu.';
			raiserror(@msg ,16,-1);	
		end
		if exists (select 1 from dbo.change_item_type where asset_code = @asset_code and status in ('NEW', 'ON PROGRESS'))
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Change Item menu.';
			raiserror(@msg ,16,-1);	
		end
		if exists (select 1 from dbo.adjustment where asset_code = @asset_code and status in ('NEW', 'ON PROGRESS'))
		begin
		    set @msg = 'Data cannot be processed. The asset has been used in other transaction processes on the Adjustment menu.';
			raiserror(@msg ,16,-1);	
		end
		-- End of additional control ===================================================

		if (@status = 'NEW')
		begin
			    update	dbo.change_category
				set		status			= 'ON PROGRESS'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @p_code ;
				
				-- send mail attachment based on setting ================================================
				--exec dbo.xsp_master_email_notification_broadcast @p_code			= 'APRQTR'
				--												,@p_doc_code		= @p_code
				--												,@p_attachment_flag = 0
				--												,@p_attachment_file = ''
				--												,@p_attachment_path = ''
				--												,@p_company_code	= @company_code
				--												,@p_trx_no			= @p_code
				--												,@p_trx_type		= 'CHANGE CATEGORY'
				-- End of send mail attachment based on setting ================================================
		
		end
		else
		begin
			set @msg = 'Data Already Proceed.';
			raiserror(@msg ,16,-1);
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
