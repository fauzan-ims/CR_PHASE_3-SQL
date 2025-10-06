CREATE PROCEDURE [dbo].[xsp_asset_maintenance_schedule_insert]
(
	@p_id					bigint = 0 output
	,@p_asset_code			nvarchar(50)
	,@p_maintenance_no		nvarchar(50)
	,@p_maintenance_date	datetime
	,@p_maintenance_status	nvarchar(20)
	,@p_last_status_date	datetime
	,@p_reff_trx_no			nvarchar(50)
	,@p_miles				int
	,@p_month				int
	,@p_hour				int
	,@p_service_code		nvarchar(50)	= ''
	,@p_service_name		nvarchar(250)	= ''
	,@p_service_type		nvarchar(50)	= ''
	,@p_service_date		datetime		= null
	--
	,@p_cre_by				nvarchar(15)
	,@p_cre_date			datetime
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_by				nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into asset_maintenance_schedule
		(
			asset_code
			,maintenance_no
			,maintenance_date
			,maintenance_status
			,last_status_date
			,reff_trx_no
			,miles
			,month
			,hour
			,service_code
			,service_name
			,service_type
			,service_date
			--
			,cre_by
			,cre_date
			,cre_ip_address
			,mod_by
			,mod_date
			,mod_ip_address
		)
		values
		(	@p_asset_code
			,@p_maintenance_no
			,@p_maintenance_date
			,@p_maintenance_status
			,@p_last_status_date
			,@p_reff_trx_no
			,@p_miles
			,@p_month
			,@p_hour
			,@p_service_code
			,@p_service_name
			,@p_service_type
			,@p_service_date
			--
			,@p_cre_by
			,@p_cre_date
			,@p_cre_ip_address
			,@p_mod_by
			,@p_mod_date
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
	end
