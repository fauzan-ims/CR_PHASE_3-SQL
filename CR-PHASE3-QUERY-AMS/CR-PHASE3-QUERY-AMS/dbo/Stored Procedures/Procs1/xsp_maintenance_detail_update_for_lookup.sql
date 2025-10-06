CREATE PROCEDURE [dbo].[xsp_maintenance_detail_update_for_lookup]
(
	@p_id			   bigint
	,@p_service_code   nvarchar(50)
	,@p_service_type   nvarchar(50)
	,@p_service_name   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(50)
)
as
begin
	declare @msg nvarchar(max) 
			,@maintenance_code	nvarchar(50) 

	begin try
		
		select	@maintenance_code = b.maintenance_code
		from	dbo.maintenance_detail	b
		where	b.id	= @p_id
	
		if exists
		(
			select	1
			from	dbo.maintenance_detail	
			where	id <> @p_id
			and		maintenance_code = @maintenance_code
			and		service_type = 'ROUTINE'
		)
		begin
			set @msg = N'Cannot add service routine, because already in maintenance schedule.' ;
			raiserror(@msg, 16, -1) ;
		end ;

		update	maintenance_detail
		set		service_code	= @p_service_code
				,service_type	= @p_service_type
				,service_name	= @p_service_name
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
