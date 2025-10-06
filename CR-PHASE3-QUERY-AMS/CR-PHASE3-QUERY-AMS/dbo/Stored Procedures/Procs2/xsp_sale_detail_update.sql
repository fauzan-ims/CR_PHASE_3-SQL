CREATE PROCEDURE dbo.xsp_sale_detail_update
(
	@p_id							bigint
	,@p_sale_code					nvarchar(50)
	,@p_description_detail			nvarchar(4000)	= ''
	,@p_sell_request_amount			decimal(18,2)	 = 0
	,@p_faktur_no					nvarchar(20)	= NULL
    ,@p_faktur_date					datetime		= null
	,@p_condition					nvarchar(250)	= null
	,@p_auction_location			nvarchar(250)	= null
	,@p_auction_base_price			decimal(18,2)	= 0
	,@p_asset_selling_price			decimal(18,2)	= 0
	,@p_asset_selling_price_mocil	decimal(18,2)	= 0
	,@p_asset_selling_price_cop		decimal(18,2)	= 0
	,@p_claim_amount				decimal(18,2)	= 0
	--,@p_total_income			decimal(18,2)
	--,@p_total_expense			decimal(18,2)
	--,@p_buyer_type				nvarchar(15) 
	--,@p_buyer_name				nvarchar(250)
	--,@p_buyer_area_phone		nvarchar(4) 
	--,@p_buyer_area_phone_no		nvarchar(15)
	--,@p_buyer_address			nvarchar(4000)
	--,@p_file_name				nvarchar(250)
	--,@p_file_paths				nvarchar(250)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare		@msg						nvarchar(max)
				,@total_income				decimal(18, 2) = 0
				,@total_expense				decimal(18, 2) = 0
				,@gain_loss					bigint = 0 --decimal(18, 2) = 0
				,@ppn_asset					decimal(18, 2) = 0
				,@netbook					decimal(18, 2) = 0
				,@gain_loss_profit			bigint = 0--decimal(18, 2) = 0
				,@ppn_sold_pct				decimal(18, 2) = 0
				,@asset_code				nvarchar(50)
				,@sale_type					nvarchar(50)
				,@rv						decimal(18,2)
				,@status_asset				nvarchar(50)
				,@borrowing_amount			decimal(18,2) = 0
				,@return_value1				decimal(18,2)
				,@return_value2				decimal(18,2)
				,@sp_name1					nvarchar(250) = 'xfn_get_amount_borrowing_asset'
				,@sp_name2					nvarchar(250) = 'xfn_get_expense_replacement_asset'
				,@sale_date					datetime
				,@agreement_no				nvarchar(50)
				,@asset_selling_price		decimal(18,2)
				,@total_asset_selling_price	decimal(18,2)
				,@total_auction_base_price	decimal(18,2)
				,@total_book_value			decimal(18,2)
				,@total_profitability		decimal(18,2)
				,@total_gain_loss			decimal(18,2)
				,@total_claim_amount		decimal(18,2)
				,@total_purchase_price		decimal(18,2)
				,@doc_code					nvarchar(50)
				,@is_required				nvarchar(1)
				,@sale_code					NVARCHAR(50)
	BEGIN TRY
    
		
	
		--PPN
		select	@ppn_sold_pct = value
		from	dbo.sys_global_param
		where	code = 'PPNSOLD' ;
 
		SELECT	@netbook		= a.net_book_value_comm
				,@asset_code	= sd.asset_code
				,@sale_type		= sal.sell_type
				,@rv			= a.residual_value
				,@status_asset	= a.status
				,@sale_date		= sal.sale_date
		from	dbo.sale_detail		 sd
				inner join dbo.sale sal on sal.code = sd.sale_code
				inner join dbo.asset a on sd.asset_code = a.code
		where	id = @p_id ;

		--new 01/07/2025
		if(@sale_type = 'AUCTION')
		begin
			set @p_sell_request_amount = @p_asset_selling_price
		end
		ELSE IF (@sale_type = 'DSSM')
		begin
			set @p_sell_request_amount = @p_asset_selling_price_mocil
		end
		else if (@sale_type = 'COP')
		begin
			set @p_sell_request_amount = @p_asset_selling_price_cop
		end
		
		if(@status_asset = 'REPLACEMENT')
		begin
			set @total_expense	= 0
			set @total_income	= 0
		end
		else
		begin
			--get borrowing untuk all agreement
			set @borrowing_amount = 0

			declare curr_borrowing cursor fast_forward read_only for
			select asat.agreement_no 
			from dbo.sale_detail sd
			inner join dbo.asset ass on (sd.asset_code = ass.code)
			left join ifinopl.dbo.agreement_asset asat on (asat.fa_code = ass.code)
			left join ifinopl.dbo.agreement_main aman on (aman.agreement_no = asat.agreement_no)
			where	ass.code = @asset_code ;
			
			open curr_borrowing
			
			fetch next from curr_borrowing 
			into @agreement_no
			
			while @@fetch_status = 0
			begin
			    	exec @return_value1 = @sp_name1 @asset_code,@sale_date,@agreement_no
					set @borrowing_amount = @borrowing_amount + @return_value1

			    fetch next from curr_borrowing 
				into @agreement_no
			end
			
			close curr_borrowing
			deallocate curr_borrowing

			--get replacement amount
			exec @return_value2 = @sp_name2 @asset_code ;
			
			--total income asset
			select	@total_income = isnull(sum(income_amount), 0)
			from	dbo.asset_income_ledger
			where	asset_code = @asset_code ;

			--total expense asset
			SELECT	@total_expense = isnull(sum(expense_amount), 0)
			from	dbo.asset_expense_ledger
			where	asset_code = @asset_code ;
		end
		
		if (@sale_type <> 'CLAIM')
		BEGIN
			set @ppn_asset = (@p_sell_request_amount * @ppn_sold_pct) / (100 + @ppn_sold_pct);
		end;
		else
		begin
			set @ppn_asset = 0;
		end;
		
		SET @gain_loss			= (isnull((@p_sell_request_amount - @ppn_asset - @netbook),0))  ;
		SET @gain_loss_profit	= (@total_income + @rv - (@total_expense + isnull(@borrowing_amount,0) + isnull(@return_value2,0)) + (@p_sell_request_amount - @netbook - @ppn_asset))  ;
		
		update	sale_detail
		set		description				= @p_description_detail
				,sell_request_amount	= @p_sell_request_amount
				,gain_loss				= @gain_loss
				,gain_loss_profit		= @gain_loss_profit
				,total_income			= round(@total_income,0)	
				,total_expense			= round((ISNULL(@total_expense,0) + ISNULL(@borrowing_amount,0) + isnull(@return_value2,0)),0)
				,faktur_no				= @p_faktur_no
				,faktur_date			= @p_faktur_date
				,condition				= @p_condition
				,auction_location		= @p_auction_location
				,auction_base_price		= @p_auction_base_price
				,asset_selling_price	= @p_sell_request_amount
				,claim_amount			= @p_claim_amount
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		-- new 01/07/2025 
		if(@sale_type = 'AUCTION')
		begin
			select	@total_auction_base_price	= isnull(sum(auction_base_price), 0)
					,@total_asset_selling_price	= isnull(sum(sell_request_amount), 0)
					,@total_book_value			= isnull(sum(net_book_value),0)
					,@total_profitability		= isnull(sum(gain_loss_profit),0)
					,@total_gain_loss			= isnull(sum(gain_loss),0)
			from	dbo.sale_detail
			where	sale_code = @p_sale_code ;

			update dbo.sale
			set total_asset_selling_price			= @total_asset_selling_price
				,total_auction_recommended_price	= @total_auction_base_price
				,total_book_value					= @total_book_value
				,total_profitability_asset			= @total_profitability
				,gain_loss_selling_asset			= @total_gain_loss
			where code = @p_sale_code
		end
		else if(@sale_type = 'CLAIM')
		begin
			select	@total_claim_amount = isnull(sum(claim_amount),0) 
			from	dbo.sale_detail
			where	sale_code = @p_sale_code

			update	dbo.sale
			set		claim_amount = @total_claim_amount
			where	code = @p_sale_code
		end
		else if (@sale_type = 'DSSM')
		begin
			select	@total_asset_selling_price	= isnull(sum(a.sell_request_amount), 0)
					,@total_book_value			= isnull(sum(net_book_value),0)
					,@total_profitability		= isnull(sum(gain_loss_profit),0)
					,@total_gain_loss			= isnull(sum(gain_loss),0)
					,@total_purchase_price		= isnull(sum(b.purchase_price),0)
			from	dbo.sale_detail a
			inner join dbo.asset b on a.asset_code = b.code
			where	sale_code = @p_sale_code ;

			update dbo.SALE
			set total_asset_selling_price			= @total_asset_selling_price
				,total_book_value					= @total_book_value
				,total_profitability_asset			= @total_profitability
				,gain_loss_selling_asset			= @total_gain_loss
				,total_asset_purchase_price			= @total_purchase_price
			where code = @p_sale_code
		end
		else if (@sale_type = 'COP')
		begin
			select	@total_asset_selling_price	= isnull(sum(a.sell_request_amount), 0)
					,@total_book_value			= isnull(sum(net_book_value),0)
					,@total_profitability		= isnull(sum(gain_loss_profit),0)
					,@total_gain_loss			= isnull(sum(gain_loss),0)
					,@total_purchase_price		= isnull(sum(b.purchase_price),0)
			from	dbo.sale_detail a
			inner join dbo.asset b on a.asset_code = b.code
			where	sale_code = @p_sale_code ;

			update dbo.SALE
			set total_asset_selling_price		= @total_asset_selling_price
				,total_book_value				= @total_book_value
				,total_profitability_asset		= @total_profitability
				,gain_loss_selling_asset		= @total_gain_loss
				,total_asset_purchase_price		= @total_purchase_price
			where code = @p_sale_code
		END
        
		--update document yang belum di attach 
		--BEGIN
			
		--	DELETE	dbo.sale_attachement_group
		--	where	sale_code = @p_sale_code
		--			and		asset_code = @asset_code
		--			and		isnull(file_name, '')<>''
			
		--	DECLARE curr_attachment cursor fast_forward read_only for
		--	select	b.general_doc_code
		--			,b.is_required
		--	from	dbo.master_selling_attachment_group a
		--	inner join dbo.master_selling_attachment_group_detail b on a.code = b.document_group_code
		--	where	a.sell_type = @sale_type
		--			and a.is_active = '1'
		--			and b.general_doc_code not in 
		--			(
		--				select	document_code 
		--				from	dbo.sale_attachement_group
		--				where	sale_code = @p_sale_code
		--						and	asset_code = @asset_code
		--			)
		--	open curr_attachment
			
		--	fetch next from curr_attachment 
		--	into @doc_code
		--		,@is_required
			
		--	while @@fetch_status = 0
		--	begin
		--	    insert into dbo.sale_attachement_group
		--	    (
		--	    	sale_code
		--	    	,document_code
		--	    	,value
		--	    	,file_name
		--	    	,file_path
		--	    	,doc_file
		--	    	,doc_no
		--			,is_required
		--	    	,cre_date
		--	    	,cre_by
		--	    	,cre_ip_address
		--	    	,mod_date
		--	    	,mod_by
		--	    	,mod_ip_address
		--			,ASSET_CODE
		--	    )
		--	    values
		--	    (
		--	    	@p_sale_code
		--			,@doc_code
		--			,''
		--			,null
		--			,null
		--			,null
		--			,null
		--			,@is_required
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--			,@p_mod_date
		--			,@p_mod_by
		--			,@p_mod_ip_address
		--			,@asset_code
		--	    )
			
		--	    fetch next from curr_attachment 
		--		into @doc_code
		--			,@is_required
		--	end
			
		--	close curr_attachment
		--	deallocate curr_attachment
		--end
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

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[xsp_sale_detail_update] TO [ims-raffyanda]
    AS [dbo];

