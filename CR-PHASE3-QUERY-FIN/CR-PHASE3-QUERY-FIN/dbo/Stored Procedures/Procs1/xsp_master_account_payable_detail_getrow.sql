create procedure dbo.xsp_master_account_payable_detail_getrow
(
	@p_id bigint
)
as
begin
	select	id,
            account_payable_code,
            payment_source
	from	dbo.master_account_payable_detail
	where	id = @p_id ;
end ;
