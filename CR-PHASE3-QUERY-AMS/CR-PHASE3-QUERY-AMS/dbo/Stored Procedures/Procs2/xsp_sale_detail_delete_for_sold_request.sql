CREATE PROCEDURE [dbo].[xsp_sale_detail_delete_for_sold_request]
(
	@p_id BIGINT,
    @p_asset_code NVARCHAR(50),
	@p_sale_code NVARCHAR(50)
)
as
begin
	declare @msg			nvarchar(max)
			,@sale_type					nvarchar(50)
			,@asset_selling_price		decimal(18,2)
			,@total_asset_selling_price	decimal(18,2)
			,@total_auction_base_price	decimal(18,2)
			,@total_book_value			decimal(18,2)
			,@total_profitability		decimal(18,2)
			,@total_gain_loss			decimal(18,2)
			,@total_claim_amount		decimal(18,2)
			,@total_purchase_price		decimal(18,2)
			,@getdate					DATETIME = GETDATE()

	begin TRY
    	EXEC dbo.xsp_sale_detail_update @p_id = @p_id,                              -- bigint
		                            @p_sale_code = @p_sale_code,                     -- nvarchar(50)
		                            @p_description_detail = N'',            -- nvarchar(4000)
		                            @p_sell_request_amount = 0,          -- decimal(18, 2)
		                            @p_faktur_no = N'',                     -- nvarchar(20)
		                            @p_faktur_date = @getdate, -- datetime
		                            @p_condition = N'',                     -- nvarchar(250)
		                            @p_auction_location = N'',              -- nvarchar(250)
		                            @p_auction_base_price = 0,           -- decimal(18, 2)
		                            @p_asset_selling_price = 0,          -- decimal(18, 2)
		                            @p_asset_selling_price_mocil = 0,    -- decimal(18, 2)
		                            @p_asset_selling_price_cop = 0,      -- decimal(18, 2)
		                            @p_claim_amount = 0,                 -- decimal(18, 2)
		                            @p_mod_date = @getdate,    -- datetime
		                            @p_mod_by = N'xsp_sale_detail_delete_for_sold_request',                        -- nvarchar(15)
		                            @p_mod_ip_address = N'xsp_sale_detail_delete_for_sold_request'                 -- nvarchar(15)
	
		delete	sale_detail
		where	id = @p_id ;

		DELETE	SALE_ATTACHEMENT_GROUP
		WHERE	SALE_CODE = @p_sale_code 
		AND		ASSET_CODE = @p_asset_code;

		if not exists
		(
			select	1
			from	dbo.sale_detail 
			where	sale_code = @p_sale_code
		)
		begin
			update dbo.sale
			set		total_auction_recommended_price		= 0
					,total_asset_selling_price			= 0
					,total_book_value					= 0
					,gain_loss_selling_asset			= 0
					,total_profitability_asset			= 0
					,claim_amount						= 0
					,total_asset_purchase_price			= 0
			where	code = @p_sale_code				

		end
-----------------------------------------------------------------------------------------------
				-- new 01/07/2025 
		--if(@sale_type = 'AUCTION')
		--begin
		--	select	@total_auction_base_price	= isnull(sum(auction_base_price), 0)
		--			,@total_asset_selling_price	= isnull(sum(sell_request_amount), 0)
		--			,@total_book_value			= isnull(sum(net_book_value),0)
		--			,@total_profitability		= isnull(sum(gain_loss_profit),0)
		--			,@total_gain_loss			= isnull(sum(gain_loss),0)
		--	from	dbo.sale_detail
		--	where	sale_code = @p_sale_code ;

		--	update dbo.sale
		--	set total_asset_selling_price			= @total_asset_selling_price
		--		,total_auction_recommended_price	= @total_auction_base_price
		--		,total_book_value					= @total_book_value
		--		,total_profitability_asset			= @total_profitability
		--		,gain_loss_selling_asset			= @total_gain_loss
		--	where code = @p_sale_code
		--end
		--else if(@sale_type = 'CLAIM')
		--begin
		--	select	@total_claim_amount = isnull(sum(claim_amount),0) 
		--	from	dbo.sale_detail
		--	where	sale_code = @p_sale_code

		--	update	dbo.sale
		--	set		claim_amount = @total_claim_amount
		--	where	code = @p_sale_code
		--end
		--else if (@sale_type = 'DSSM')
		--begin
		--	select	@total_asset_selling_price	= isnull(sum(a.sell_request_amount), 0)
		--			,@total_book_value			= isnull(sum(net_book_value),0)
		--			,@total_profitability		= isnull(sum(gain_loss_profit),0)
		--			,@total_gain_loss			= isnull(sum(gain_loss),0)
		--			,@total_purchase_price		= isnull(sum(b.purchase_price),0)
		--	from	dbo.sale_detail a
		--	inner join dbo.asset b on a.asset_code = b.code
		--	where	sale_code = @p_sale_code ;

		--	update dbo.SALE
		--	set total_asset_selling_price			= @total_asset_selling_price
		--		,total_book_value					= @total_book_value
		--		,total_profitability_asset			= @total_profitability
		--		,gain_loss_selling_asset			= @total_gain_loss
		--		,total_asset_purchase_price			= @total_purchase_price
		--	where code = @p_sale_code
		--end
		--else if (@sale_type = 'COP')
		--begin
		--	select	@total_asset_selling_price	= isnull(sum(a.sell_request_amount), 0)
		--			,@total_book_value			= isnull(sum(net_book_value),0)
		--			,@total_profitability		= isnull(sum(gain_loss_profit),0)
		--			,@total_gain_loss			= isnull(sum(gain_loss),0)
		--			,@total_purchase_price		= isnull(sum(b.purchase_price),0)
		--	from	dbo.sale_detail a
		--	inner join dbo.asset b on a.asset_code = b.code
		--	where	sale_code = @p_sale_code ;

		--	update dbo.SALE
		--	set total_asset_selling_price		= @total_asset_selling_price
		--		,total_book_value				= @total_book_value
		--		,total_profitability_asset		= @total_profitability
		--		,gain_loss_selling_asset		= @total_gain_loss
		--		,total_asset_purchase_price		= @total_purchase_price
		--	where code = @p_sale_code
		--END


		
-----------------------------------------------------------------------------------------------
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;
		else if (@error = 547)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_used() ;
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
