CREATE PROCEDURE dbo.xsp_asset_maintenance_schedule_update
(
	@p_id				   bigint
	,@p_asset_code		   nvarchar(50)
	,@p_maintenance_no	   nvarchar(50)
	,@p_maintenance_date   datetime
	,@p_maintenance_status nvarchar(20)
	,@p_last_status_date   datetime
	,@p_reff_trx_no		   nvarchar(50)
	,@p_service_date	   datetime
	--
	,@p_mod_by			   nvarchar(15)
	,@p_mod_date		   datetime
	,@p_mod_ip_address	   nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	asset_maintenance_schedule
		set		asset_code				 = @p_asset_code
				,maintenance_no			 = @p_maintenance_no
				,maintenance_date		 = @p_maintenance_date
				,maintenance_status		 = @p_maintenance_status
				,last_status_date		 = @p_last_status_date
				,reff_trx_no			 = @p_reff_trx_no
				,service_date			 = @p_service_date
				--
				,mod_by					 = @p_mod_by
				,mod_date				 = @p_mod_date
				,mod_ip_address			 = @p_mod_ip_address
		where	ID = @p_id ;
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
