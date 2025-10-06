CREATE PROCEDURE dbo.xsp_sale_detail_fee_update_tax
(
	@p_id			   bigint
	,@p_tax_code	   nvarchar(50)
	,@p_tax_name	   nvarchar(250) = ''
	,@p_ppn_pct		   decimal(9, 6)
	,@p_pph_pct  	   decimal(9, 6)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg							nvarchar(max)
			,@pph_amount					decimal(18,2)
			,@ppn_amount					decimal(18,2)
			,@fee_amount					decimal(18,2)
			,@total_depre					decimal(18,2)
			,@purchase_price				decimal(18,2)
			,@sale_detail_id				bigint
			,@sale_value					decimal(18,2)
			,@netbook						decimal(18,2)
			,@ppn_sold_pct					decimal(9,6)
			,@total_fee_amount				decimal(18,2)
			,@total_fee_amountfee_amount	decimal(18,2)

	begin try
		select	@fee_amount			= fee_amount
				,@sale_detail_id	= sale_detail_id
		from	dbo.sale_detail_fee
		where	id = @p_id;

		set @pph_amount = isnull(@fee_amount * @p_pph_pct / 100.00 ,0) ;
		set @ppn_amount = isnull(@fee_amount * @p_ppn_pct / 100.00,0) ;


		update	dbo.sale_detail_fee
		set		master_tax_code			= @p_tax_code
				,master_tax_description = @p_tax_name
				,ppn_amount				= @ppn_amount
				,pph_amount				= @pph_amount
				,master_tax_ppn_pct		= @p_ppn_pct
				,master_tax_pph_pct		= @p_pph_pct
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;

		---------------------
		select	@total_fee_amount		= isnull(sum(fee_amount),0) + isnull(sum(ppn_amount),0) - isnull(sum(pph_amount),0) 
				,@pph_amount			= isnull(sum(pph_amount),0)
				,@ppn_amount			= isnull(sum(ppn_amount),0)
		from dbo.sale_detail_fee
		where sale_detail_id = @sale_detail_id

		select	@total_depre		= isnull(ass.total_depre_comm,0)
				,@purchase_price	= isnull(ass.purchase_price,0)
				,@sale_value		= isnull(sd.sell_request_amount,0)
				,@netbook			= isnull(ass.net_book_value_comm,0)
		from dbo.sale_detail_fee sde
		left join dbo.sale_detail sd on (sd.id = sde.sale_detail_id)
		left join dbo.asset ass on (ass.code = sd.asset_code)
		where sde.id = @p_id

		--PPN
		select	@ppn_sold_pct = value
		from	dbo.sys_global_param
		where	code = 'PPNSOLD' ;
		
		update	dbo.sale_detail
		set		total_fee_amount	= @total_fee_amount
				,total_pph_amount	= @pph_amount
				,total_ppn_amount	= @ppn_amount
				,gain_loss			= isnull(sold_amount - (sold_amount * @ppn_sold_pct) / (100  + @ppn_sold_pct) - @netbook, 0) 
				--,gain_loss		= isnull(total_income,0) - isnull(total_expense,0) - (isnull(sold_amount,0) - isnull(net_book_value,0)) - @fee_amount --@sale_value - (isnull(@purchase_price,0) - isnull(@total_depre,0))
				,net_receive		= sold_amount - (@fee_amount + @ppn_amount - @pph_amount)
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id = @sale_detail_id

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
