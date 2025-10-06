CREATE PROCEDURE dbo.xsp_master_public_service_address_delete
(
	@p_id						bigint
    --
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
BEGIN

	declare @msg						nvarchar(max)
			--
			,@is_latest					nvarchar(1)
			,@public_service_code		nvarchar(50)


	begin TRY
		
		select	@public_service_code	= public_service_code
				,@is_latest				= is_latest
		from	dbo.master_public_service_address
		where	id = @p_id

		EXEC	dbo.xsp_master_public_service_update_invalid 
				@public_service_code
				,@p_mod_date					
				,@p_mod_by						
				,@p_mod_ip_address				

		delete	master_public_service_address
		where	id = @p_id ;

		if @is_latest = '1'
		begin
			update	dbo.master_public_service_address
			set		is_latest = 1
			where	id =	(
								select top 1 id 
								from master_public_service_address 
								where public_service_code = @public_service_code
							)
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
