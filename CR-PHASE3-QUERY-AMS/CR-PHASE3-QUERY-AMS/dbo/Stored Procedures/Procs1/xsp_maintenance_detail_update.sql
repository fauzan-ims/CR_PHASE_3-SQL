CREATE PROCEDURE dbo.xsp_maintenance_detail_update
(
	@p_id					bigint
	,@p_service_fee			decimal(18,2) = 0
	,@p_quantity			INT
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(50)
)
as
begin
	declare @msg nvarchar(max)
			,@item_service	nvarchar(50);

	begin try
		
		select @item_service = SERVICE_CODE
		from dbo.MAINTENANCE_DETAIL
		where id = @p_id ;

		if @item_service = ''
		begin
	
			set @msg = 'Item service cannot be empty.';
	
			raiserror(@msg, 16, -1) ;
	
		end   

		update	maintenance_detail
		set		service_fee			= @p_service_fee
				,quantity			= @p_quantity
				--
				,mod_date			 = @p_mod_date
				,mod_by				 = @p_mod_by
				,mod_ip_address		 = @p_mod_ip_address
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
