CREATE PROCEDURE dbo.xsp_master_cashier_priority_detail_getrow
(
	@p_id							bigint
    ,@p_cashier_priority_code		nvarchar(50)
)
as
BEGIN

	select	mcpd.id
			,mcpd.cashier_priority_code
			,mcpd.order_no
			,mcpd.transaction_code
			,mt.transaction_name
	from	master_cashier_priority_detail mcpd
			INNER join dbo.master_transaction mt	on (mcpd.transaction_code = mt.code)    
	where	id						= @p_id
	and		cashier_priority_code	= @p_cashier_priority_code;

end ;
