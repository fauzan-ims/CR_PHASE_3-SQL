CREATE FUNCTION dbo.xfn_get_payment_payment_type
(
	@p_code		 nvarchar(50)
)
returns nvarchar(50)
as
begin
	declare @payment_type		nvarchar(50);

	select @payment_type = case 
								when pr.payment_source = 'WORK ORDER' then 'WORK ORDER'
								else 'OTHERS'
							end
	from dbo.payment_transaction_detail ptd
	left join dbo.payment_request pr on (pr.code = ptd.payment_request_code)
	where ptd.payment_transaction_code = @p_code

	return @payment_type

end ;
