CREATE PROCEDURE dbo.xsp_ap_payment_request_detail_delete
(
	@p_id				bigint
    ,@p_mod_date	    datetime
	,@p_mod_by		    nvarchar(15)
	,@p_mod_ip_address  nvarchar(15)
)
as
begin
	declare @msg						nvarchar(max) 
			,@payment_request_code		NVARCHAR(50)
			,@id						INT
			,@sum_amount				decimal(18,2)
			,@ppn						decimal(18,2)
			,@pph						decimal(18,2)

	begin TRY
	
	
	select @payment_request_code = payment_request_code
	from dbo.ap_payment_request_detail 
	where id = @p_id

	delete	ap_payment_request_detail
	where	id	= @p_id
	

	select @sum_amount	= sum(payment_amount)
			,@ppn		= sum(ppn)
			,@pph		= sum(pph)
	from dbo.ap_payment_request_detail
	where payment_request_code = @payment_request_code


	update dbo.AP_PAYMENT_REQUEST
	set		invoice_amount	= @sum_amount
			,ppn			= @ppn
			,pph			= @pph
			--
			,mod_date		= @p_mod_date
			,mod_by			= @p_mod_by
			,mod_ip_address	= @p_mod_ip_address
	where	code			= @payment_request_code

	--select @id = count(id)
	--from dbo.ap_payment_request_detail
	--where  payment_request_code = @payment_request_code

	--if (@id = 1)
	--begin
		if not exists
			(
				select	1
				from dbo.ap_payment_request_detail 
				where payment_request_code = @payment_request_code
			)
			begin
				exec dbo.xsp_ap_payment_request_cancel @p_code				= @payment_request_code,
														@p_mod_date			= @p_mod_date,
														@p_mod_by			= @p_mod_by,
														@p_mod_ip_address	= @p_mod_ip_address
			

			end ;
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
