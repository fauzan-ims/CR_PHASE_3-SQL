CREATE PROCEDURE [dbo].[xsp_ap_invoice_registration_detail_delete]
(
	@p_id bigint
)
as
begin
	declare @msg					nvarchar(max)
			,@grn_code				nvarchar(50)
			,@invoice_register_code nvarchar(50)
			,@ppn_amount			decimal(18, 2) = 0
			,@pph_amount			decimal(18, 2) = 0
			,@total_amount_head		decimal(18, 2) = 0 
			,@discount_head			decimal(18, 2) = 0
			,@total_amount			decimal(18, 2)
			,@ppn					decimal(18, 2)
			,@pph					decimal(18, 2) 
			,@discount				decimal(18, 2) 
			,@unit_price_head		decimal(18,2)
			,@unit_price_amount		decimal(18,2)
			,@id_detail				bigint

	begin try
		select	@grn_code				= grn_code
				,@invoice_register_code = invoice_register_code
		from	dbo.ap_invoice_registration_detail
		where	id = @p_id ;

		--select	@total_amount_head	= invoice_amount 
		--		,@ppn_amount		= ppn
		--		,@pph_amount		= pph
		--		,@discount_head		= discount
		--		,@unit_price_head	= unit_price
		--from	dbo.ap_invoice_registration
		--where	code = @invoice_register_code ;

		--declare c_invoice_detail cursor fast_forward for
		--select	sum(((ird.purchase_amount - ird.discount) * ird.quantity)  + ird.ppn - ird.pph) 'total_amount'
		--		,ppn
		--		,pph
		--		,sum((ird.discount * ird.quantity)) 'discount'
		--		,ird.purchase_amount
		--from	dbo.ap_invoice_registration_detail ird
		--where	invoice_register_code = @invoice_register_code
		--		--and grn_code		  = @grn_code
		--		group by
		--				ird.ppn
		--				,ird.pph
		--				,ird.discount
		--				,ird.purchase_amount


		--open c_invoice_detail ;

		--fetch c_invoice_detail
		--into @total_amount
		--	 ,@ppn
		--	 ,@pph 
		--	 ,@discount
		--	 ,@unit_price_amount

		--while @@fetch_status = 0
		--begin
		--	set @ppn_amount = @ppn_amount - @ppn ;
		--	set @pph_amount = @pph_amount - @pph ;
		--	set @discount_head = @discount_head - @discount ;
		--	set @total_amount_head = @total_amount_head - @total_amount ;
		--	set @unit_price_head = @unit_price_head - @unit_price_amount ;

		--	fetch c_invoice_detail
		--	into @total_amount
		--		 ,@ppn
		--		 ,@pph 
		--		 ,@discount
		--		 ,@unit_price_amount;
		--end ;

		--close c_invoice_detail ;
		--deallocate c_invoice_detail ;

 
		if exists
		(
			select	1
			from	dbo.ap_invoice_registration_detail
			where	grn_code = @grn_code
		)
		begin			
			declare curr_delete_invoice cursor fast_forward read_only for
            select id 
			from dbo.ap_invoice_registration_detail
			where grn_code = @grn_code
			
			open curr_delete_invoice
			
			fetch next from curr_delete_invoice 
			into @id_detail
			
			while @@fetch_status = 0
			begin
					delete dbo.ap_invoice_registration_detail_faktur
					where invoice_registration_detail_id = @id_detail

			    fetch next from curr_delete_invoice 
				into @id_detail
			end
			
			close curr_delete_invoice
			deallocate curr_delete_invoice

			delete dbo.ap_invoice_registration_detail
			where	grn_code = @grn_code ;

			update	dbo.ap_invoice_registration
			set		invoice_amount = @total_amount_head
					,ppn = @ppn_amount
					,pph = @pph_amount 
					,discount = @discount_head
					,unit_price = @unit_price_head
			where	code = @invoice_register_code ;
		end ;


		--select @invoice_register_code = invoice_register_code 
		--from dbo.ap_invoice_registration_detail
		--where id = @p_id

		--delete dbo.ap_invoice_registration_detail
		--where	id = @p_id ;

		select @discount_head		= sum(discount)
				,@ppn_amount		= sum(ppn)
				,@pph				= sum(pph)
				,@total_amount_head = sum(((purchase_amount - discount) * quantity)  + ppn)
		from dbo.ap_invoice_registration_detail
		where invoice_register_code = @invoice_register_code

		update	dbo.ap_invoice_registration
		set		invoice_amount		= isnull(@total_amount_head,0)
				,ppn				= isnull(@ppn_amount,0)
				,pph				= isnull(@pph_amount,0) 
				,discount			= isnull(@discount_head,0)
				,unit_price			= isnull(@unit_price_head,0)
		where	code = @invoice_register_code ;
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
