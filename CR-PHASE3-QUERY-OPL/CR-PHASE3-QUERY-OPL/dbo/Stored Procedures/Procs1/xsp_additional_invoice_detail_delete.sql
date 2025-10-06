CREATE PROCEDURE dbo.xsp_additional_invoice_detail_delete
(
	@p_id			bigint
)
as
begin
	declare @msg nvarchar(max) ;

	begin try

	--- update for header
		declare @add_code				 nvarchar(50)
				, @request_code			 nvarchar(50)
				, @total_billing_amount	 decimal(18, 2)
				, @total_discount_amount decimal(18, 2)
				, @total_ppn_amount		 int
				, @total_pph_amount		 int
				, @total_amount			 decimal(18, 2) ;

		select	@add_code		= additional_invoice_code
				, @request_code = isnull(additional_invoice_request_code, '')
		from	dbo.additional_invoice_detail
		where	id = @p_id ;

		update dbo.additional_invoice_request 
		set status = 'HOLD'
		where code = @request_code

		delete	additional_invoice_detail
		where	id	= @p_id

	 
		select	@total_billing_amount	 = isnull(sum(billing_amount), 0)
				, @total_discount_amount = isnull(sum(discount_amount), 0)
				, @total_ppn_amount		 = isnull(sum(ppn_amount), 0)
				, @total_pph_amount		 = isnull(sum(pph_amount), 0)
				, @total_amount			 = isnull(sum(total_amount), 0)
		from	dbo.additional_invoice_detail
		where	additional_invoice_code = @add_code ;

		update	dbo.additional_invoice
		set		total_billing_amount = @total_billing_amount
				, total_discount_amount = @total_discount_amount
				, total_ppn_amount = @total_ppn_amount
				, total_pph_amount = @total_pph_amount
				, total_amount = @total_amount
		where	code = @add_code ;

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
