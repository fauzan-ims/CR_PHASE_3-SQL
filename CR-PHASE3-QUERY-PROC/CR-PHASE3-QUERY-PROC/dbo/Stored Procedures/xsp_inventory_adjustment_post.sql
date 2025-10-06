CREATE PROCEDURE dbo.xsp_inventory_adjustment_post
(
	@p_code			   nvarchar(50)
	,@p_company_code   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@branch_code				 nvarchar(50)
			,@branch_name				 nvarchar(250)
			,@item_code					 nvarchar(50)
			,@item_name					 nvarchar(250)
			,@status					 nvarchar(50)
			,@warehouse_code			 nvarchar(50)
			,@plus_or_minus				 nvarchar(5)
			,@qty_adjustment			 int
			,@total_adjustment			 int
			,@quantity_stok_card		 int
			,@on_hand_quantity			 int
			,@on_hand_quantity_stok_card int
			,@trx_period				 nvarchar(6)
			,@adjustment_date			 datetime ;

	begin try

		select	@status		= adj.status
		from	dbo.inventory_adjustment adj
		where	adj.code	= @p_code ;

		if (@status = 'ON PROGRESS')
		begin
			update	dbo.inventory_adjustment
			set		status				= 'POST'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code ;
		end ;
		else
		begin
			set @msg = 'Data already proceed' ;

			raiserror(@msg, 16, -1) ;
		end ;

		declare curr_inventory_adjustment_detail cursor for
		select	iad.item_code
				,iad.item_name
				,iad.plus_or_minus
				,iad.warehouse_code
				,isnull(iad.total_adjustment, 0)
				,iaj.adjustment_date
				,iaj.branch_code
				,iaj.branch_name
		from	dbo.inventory_adjustment_detail iad
				inner join dbo.inventory_adjustment iaj on iaj.code = iad.inventory_adjustment_code
		where	inventory_adjustment_code = @p_code ;

		open curr_inventory_adjustment_detail ;

		fetch next from curr_inventory_adjustment_detail
		into @item_code
			 ,@item_name
			 ,@plus_or_minus
			 ,@warehouse_code
			 ,@total_adjustment
			 ,@adjustment_date
			 ,@branch_code
			 ,@branch_name ;
		while @@fetch_status = 0
		begin
			
			if not exists
			(
				select	1
				from	dbo.inventory_card
				where	item_code		 = @item_code
						and branch_code	 = @branch_code
						and company_code = @p_company_code
			)
			begin
				set @trx_period = convert(nvarchar, year(@adjustment_date)) + replace(str(month(@adjustment_date), 2, 0), ' ', '0') ;

				exec dbo.xsp_inventory_card_insert @p_id					= 0
												   ,@p_company_code			= @p_company_code
												   ,@p_branch_code			= @branch_code
												   ,@p_branch_name			= @branch_name
												   ,@p_transaction_code		= @p_code
												   ,@p_transaction_type		= 'ADJ'
												   ,@p_transaction_period	= @trx_period
												   ,@p_item_code			= @item_code
												   ,@p_item_name			= @item_name
												   ,@p_warehouse_code		= @warehouse_code
												   ,@p_plus_or_minus		= @plus_or_minus
												   ,@p_quantity				= @total_adjustment
												   ,@p_on_hand_quantity		= @total_adjustment
												   ,@p_cre_date				= @p_mod_date
												   ,@p_cre_by				= @p_mod_by
												   ,@p_cre_ip_address		= @p_mod_ip_address
												   ,@p_mod_date				= @p_mod_date
												   ,@p_mod_by				= @p_mod_by
												   ,@p_mod_ip_address		= @p_mod_ip_address ;
			end ;
			else
			begin
				select	@quantity_stok_card = isnull(quantity, 0)
						,@on_hand_quantity_stok_card = isnull(on_hand_quantity, 0)
				from	dbo.inventory_card
				where	item_code		 = @item_code
						and branch_code	 = @branch_code
						and company_code = @p_company_code ;

				print @quantity_stok_card
				print @total_adjustment
				if (@plus_or_minus = '1') --PLUS
				begin
					set @qty_adjustment = @quantity_stok_card + @total_adjustment ;
					set @on_hand_quantity = @on_hand_quantity_stok_card + @total_adjustment ;
				end ;
				else if (@plus_or_minus = '0') --MINUS
				begin
					set @qty_adjustment = @quantity_stok_card - abs(@total_adjustment) ;
					set @on_hand_quantity = @on_hand_quantity_stok_card - abs(@total_adjustment) ;
				end ;

				print @qty_adjustment
				update	dbo.inventory_card
				set		quantity			= @qty_adjustment
						,on_hand_quantity	= @on_hand_quantity
						,plus_or_minus		= @plus_or_minus
				where	item_code			= @item_code
						and branch_code		= @branch_code
						and company_code	= @p_company_code ;
			end ;

			fetch next from curr_inventory_adjustment_detail
			into @item_code
				 ,@item_name
				 ,@plus_or_minus
				 ,@warehouse_code
				 ,@total_adjustment
				 ,@adjustment_date
				 ,@branch_code
				 ,@branch_name ;
		end ;

		close curr_inventory_adjustment_detail ;
		deallocate curr_inventory_adjustment_detail ;
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
