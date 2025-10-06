CREATE PROCEDURE [dbo].[xsp_work_order_cancel_old]
(
	@p_id			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@status			nvarchar(20)
			,@asset_code		nvarchar(50)
			,@maintenance_code	nvarchar(50)

	begin try  
		select	@status				= status
				,@asset_code		= asset_code
				,@maintenance_code	= maintenance_code
		from	dbo.work_order
		where	code = @p_id ;

		if (@status = 'ON PROCESS')
		begin
			update	dbo.work_order
			set		status			= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_id ;

			update	dbo.MAINTENANCE
			set		STATUS			= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @maintenance_code ;

			update	dbo.asset
			set		wo_no			= ''
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @asset_code ;
		end
		else
		begin
			set @msg = 'Data already proceed';
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
