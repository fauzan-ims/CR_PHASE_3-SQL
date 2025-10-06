CREATE FUNCTION dbo.xfn_finance_request_check_balance
(
	@p_request_type	 nvarchar(20)
	,@p_request_code nvarchar(50)
)
returns nvarchar(250)
as
begin
	declare @output nvarchar(250) ;

	if (@p_request_type = 'CASHIER')
	begin
		if ((
				select	isnull(request_amount, 0)
				from	dbo.opl_interface_cashier_received_request
				where	code = @p_request_code
			) +
			(
				select	isnull(sum(isnull(orig_amount, 0)), 0)
				from	dbo.opl_interface_cashier_received_request_detail
				where	cashier_received_request_code = @p_request_code
			) <> 0
		   )
		begin
			set @output = 'Cashier Received Request Is Not Balance' ;
		end ;
	end ;
	else if (@p_request_type = 'PAYMENT')
	begin
		if ((
				select	payment_amount
				from	dbo.opl_interface_payment_request
				where	code = @p_request_code
			) <>
		   (
			   select	sum(orig_amount)
			   from		dbo.opl_interface_payment_request_detail
			   where	payment_request_code = @p_request_code
		   )
		   )
		begin
			set @output = 'Payment Request Is Not Balance' ;
		end ;
	end ;
	else if (@p_request_type = 'RECEIVE')
	begin
		if ((
				select	isnull(received_amount, 0)
				from	dbo.opl_interface_received_request
				where	code = @p_request_code
			) +
			(
				select	isnull(sum(isnull(orig_amount, 0)), 0)
				from	dbo.opl_interface_received_request_detail
				where	received_request_code = @p_request_code
			) <> 0
		   )
		begin
			set @output = 'Receive Request Is Not Balance' ;
		end ;
	end ;

	return @output ;
end ;
