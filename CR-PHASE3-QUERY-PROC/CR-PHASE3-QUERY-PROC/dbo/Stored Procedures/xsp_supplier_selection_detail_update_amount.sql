CREATE PROCEDURE [dbo].[xsp_supplier_selection_detail_update_amount]
(
	 @p_id						bigint
	,@p_amount					decimal(18, 2) = 0
	,@p_quotation_quantity		int
	,@p_discount_amount			decimal(18,2)  = 0
		--
	,@p_mod_date				datetime
	,@p_mod_by					nvarchar(15)
	,@p_mod_ip_address			nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@pph			decimal(9, 6)
			,@ppn			decimal(9, 6)
			,@pph_amount	decimal(18,2) = 0
			,@ppn_amount	decimal(18,2) = 0
			,@ppn_pct		decimal(9,6)
			,@pph_pct		decimal(9,6);

	begin try
		select	@ppn_pct	= ppn_pct
				,@pph_pct	= pph_pct
		from dbo.supplier_selection_detail
		where id = @p_id

		set @ppn_amount = isnull(@ppn_pct / 100 * ((@p_amount * @p_quotation_quantity) - (@p_discount_amount * @p_quotation_quantity)),0) ;
		set @pph_amount = isnull(@pph_pct / 100 * ((@p_amount * @p_quotation_quantity) - (@p_discount_amount * @p_quotation_quantity)),0) ;

		update	supplier_selection_detail
		set		amount				= @p_amount
				,discount_amount	= @p_discount_amount
				,total_amount		= (@p_amount * @p_quotation_quantity) - (@p_discount_amount * @p_quotation_quantity)
				,ppn_amount			= @ppn_amount
				,pph_amount			= @pph_amount
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
