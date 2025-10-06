CREATE PROCEDURE dbo.xsp_deskcoll_customer_info_getrow
(
	@p_deskcoll_id bigint
)
as
begin
	select	deskcoll_id
			,customer_client_no
			,invoice_no
			,transaction_amount
			,os_invoice_amount
			,invoice_due_date
	from	dbo.deskcoll_customer_info
	where	deskcoll_id = @p_deskcoll_id ;
end ;
