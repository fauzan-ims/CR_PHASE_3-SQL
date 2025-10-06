CREATE PROCEDURE [dbo].[xsp_purchase_order_detail_delete]
(
	@p_id			bigint
	,@p_po_code		nvarchar(50)
)
as
begin
	declare @msg			nvarchar(max) 
			,@temp_pph		decimal(18, 2)
			,@temp_ppn		decimal(18, 2)
			,@total_amount	decimal(18, 2)
			,@supplier_id	int

	begin try
		select @supplier_id = supplier_selection_detail_id 
		from dbo.purchase_order_detail
		where id = @p_id

		delete	purchase_order_detail
		where id = @p_id

		delete dbo.purchase_order_detail_object_info
		where purchase_order_detail_id = @p_id

		--select sum data total amount, ppn, pph dari tabel purchase order detail
		select	@total_amount	= sum ((isnull(price_amount, 0) - isnull(discount_amount, 0)) * isnull(order_quantity, 0) + isnull(ppn_amount, 0) - isnull(pph_amount, 0)) 
				,@temp_pph		= sum(isnull(pph_amount, 0))
				,@temp_ppn		= sum(isnull(ppn_amount, 0))
		from	dbo.purchase_order_detail
		where	po_code			= @p_po_code

		--update data di tabel puchase order
		update	dbo.purchase_order
		set		total_amount	= isnull(@total_amount, 0)
				,pph_amount		= isnull(@temp_pph, 0)
				,ppn_amount		= isnull(@temp_ppn, 0)
		where	code			= @p_po_code

		update	dbo.supplier_selection_detail
		set		supplier_selection_detail_status = 'HOLD'
				,purchase_order_no				 = null
		where	id = @supplier_id
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
end
