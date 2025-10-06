CREATE PROCEDURE [dbo].[xsp_procurement_proceed]
(
	@p_code							nvarchar(50)
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@purchase_type_code	nvarchar(50)
			,@item_code				nvarchar(50)
			,@count_invtry			int
			,@count_asset			int
			,@purchase				nvarchar(20)
			,@approve_request		int
			,@quantity_purchase		int
			,@purchase_type_name	nvarchar(250)
			,@unit_from				nvarchar(50)

	begin try

		select	@purchase_type_code		= purchase_type_code
				,@item_code				= item_code
				,@purchase				= new_purchase
				,@approve_request		= approved_quantity
				,@quantity_purchase		= quantity_purchase
				,@purchase_type_name	= purchase_type_name
				,@unit_from				= unit_from
		from	dbo.procurement
		where	code = @p_code ;

		if(@quantity_purchase > @approve_request)
		begin
			set @msg = 'Quantity Purchase Must be Less or Equal Than Quantity Request.' ;
			raiserror(@msg, 16, 1) ;
		end

		if(isnull(@unit_from,'') = '')
		begin
			set @msg = 'Please Input Unit From First.' ;
			raiserror(@msg, 16, 1) ;
		end

		--Tidak digunakan karena sekarang didefault YES
		-------------------------------------------------------------------------------
		--if (@purchase = 'NO')
		--begin
		--	if (
		--		   @transaction_type = 'FXDAST'
		--		   and	@status_efam = '1'
		--	   )
		--	begin
		--		-- cek ada atau enggak
		--		if exists
		--		(
		--			select	1
		--			from	ifinams.dbo.ASSET
		--			where	status		  = 'AVAILABLE'
		--					and item_code = @item_code
		--		)
		--		begin
		--			select	@count_asset = count(*)
		--			from	ifinams.dbo.asset
		--			where	status		  = 'AVAILABLE'
		--					and item_code = @item_code ;

		--			if (@quantity_inventory > @count_asset)
		--			begin
		--				set @msg = 'Item is not available for this quantity, please check your data' ;

		--				raiserror(@msg, 16, 1) ;
		--			end ;
		--		end ;
		--		else -- jika tidak ada
		--		begin
		--			set @msg = 'Item does not exist in asset list' ;

		--			raiserror(@msg, 16, 1) ;
		--		end ;
		--	end ;
		--	else if (@transaction_type = 'INVTRY')
		--	begin
		--		-- cek ada atau enggak
		--		if exists
		--		(
		--			select	1
		--			from	dbo.inventory_card
		--			where	item_code = @item_code
		--		)
		--		begin
		--			select	@count_invtry = count(*)
		--			from	dbo.inventory_card
		--			where	item_code = @item_code ;

		--			if (@quantity_inventory > @count_invtry)
		--			begin
		--				set @msg = 'Item is not available for this quantity, please check your data' ;

		--				raiserror(@msg, 16, 1) ;
		--			end ;
		--		end ;
		--		else -- jika tidak ada
		--		begin
		--			set @msg = 'Item does not exist in inventory stock card' ;

		--			raiserror(@msg, 16, 1) ;
		--		end ;
		--	end ;
		--end
		
		--Tidak digunakan karena sekarang cuman ada withquotation atau without quotation
		------------------------------------------------------------------------------
		--if(@purchase_type_code = 'TNDR')
		--begin
			
		--	if not exists	(
		--						select	1 
		--						from	dbo.procurement_vendor
		--						where procurement_code = @p_code
		--					)
		--	BEGIN
				
		--		set @msg = 'Please input vendor list' ;
		--		RAISERROR(@msg, 16, -1) ;

  --          END

  --      end

		update	procurement
		set		status			= 'ON PROCESS'
				--,quantity_purchase = @quantity_purchase
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	code			= @p_code ;
        
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
