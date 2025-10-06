--Created, Rian at 28/12/2022

CREATE PROCEDURE dbo.xsp_master_bast_checklist_asset_update
(
	@p_code				nvarchar(50)
	,@p_asset_type_code nvarchar(50)
	,@p_checklist_name	nvarchar(250)
	,@p_order_key		int
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max) 
			,@old_order_key int
			,@count			int ;;

	begin try
		if exists
		(
			select	1
			from	dbo.master_bast_checklist_asset
			where	code			   <> @p_code
					and checklist_name = @p_checklist_name
		)
		begin
			set @msg = 'Checklist Name already exist' ;

			raiserror(@msg, 16, -1) ;
		end ;

		if (@p_order_key <= 0)
		begin
			set @msg = 'Step Order must be greater than 0' ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@count = count(code)
		from	dbo.master_bast_checklist_asset
		where	asset_type_code = @p_asset_type_code ;

		if (@count < @p_order_key)
		begin
			set @msg = 'Maximum Step Order is ' + cast(@count as nvarchar(3)) ;

			raiserror(@msg, 16, -1) ;
		end ;

		select	@old_order_key = order_key
		from	dbo.master_bast_checklist_asset
		where	code					= @p_code
				and asset_type_code		= @p_asset_type_code;

		begin
			if @old_order_key > @p_order_key
			begin
				update	dbo.master_bast_checklist_asset
				set		order_key = order_key + 1
				where	order_key
				between @p_order_key and @old_order_key
				and asset_type_code = @p_asset_type_code;
			end ;
			else if @old_order_key < @p_order_key
			begin
				update	dbo.master_bast_checklist_asset
				set		order_key = order_key - 1
				where	order_key
				between @old_order_key and @p_order_key 
				and asset_type_code = @p_asset_type_code;
			end ;
		end ;

		update	dbo.master_bast_checklist_asset
		set		asset_type_code		= upper(@p_asset_type_code)
				,checklist_name		= upper(@p_checklist_name)
				,order_key			= @p_order_key
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	code				= @p_code 
		and		asset_type_code		= @p_asset_type_code
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
