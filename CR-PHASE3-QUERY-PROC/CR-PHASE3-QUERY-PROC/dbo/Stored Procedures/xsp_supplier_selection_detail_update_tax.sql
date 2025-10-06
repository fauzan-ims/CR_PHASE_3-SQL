CREATE PROCEDURE dbo.xsp_supplier_selection_detail_update_tax
(
	 @p_id					bigint
	,@p_tax_code			nvarchar(50)
	,@p_tax_name			nvarchar(250)
	,@p_ppn_pct				decimal(9,6) = 0
	,@p_pph_pct				decimal(9,6) = 0
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@pph			decimal(9, 6)
			,@ppn			decimal(9, 6)
			,@pph_amount	decimal(18,2)
			,@ppn_amount	decimal(18,2)
			,@total_amount	decimal(18,2)
			,@unit_price	decimal(18,2)
			,@quantity		int
			,@discount		decimal(18,2)

	begin try
		select	@quantity		= quantity
				,@unit_price	= amount
				,@discount		= discount_amount
				,@ppn			= ppn_pct
				,@pph			= pph_pct
		from dbo.supplier_selection_detail
		where id = @p_id
		
		set @ppn_amount = round(isnull(@p_ppn_pct / 100 * (@quantity * (@unit_price - @discount)),0),0) ;
		set @pph_amount = round(isnull(@p_pph_pct / 100 * (@quantity * (@unit_price - @discount)),0),0) ;

		set @total_amount = round((@quantity * (@unit_price - @discount )),0)
    
		update	supplier_selection_detail
		set		tax_code			= @p_tax_code
				,tax_name			= @p_tax_name
				,ppn_amount			= @ppn_amount
				,pph_amount			= @pph_amount
				,ppn_pct			= @p_ppn_pct
				,pph_pct			= @p_pph_pct
				--,total_amount		= @quantity * (@unit_price - @discount )
				,total_amount		= @total_amount
									--= (@p_amount * @p_quotation_quantity) - (@p_discount_amount * @p_quotation_quantity) + @ppn_amount
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id	= @p_id

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
