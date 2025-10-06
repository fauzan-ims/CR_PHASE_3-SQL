CREATE PROCEDURE dbo.xsp_asset_get_adjustment_surplus_amount
(
    @p_company_code nvarchar(50)
  , @p_code nvarchar(50)
  , @p_asset_no nvarchar(50)
)
as
begin
    declare	@surplus_amount	decimal(18,2)
	
	select	@surplus_amount = adj.new_netbook_value_comm - adj.old_netbook_value_comm 
    from	dbo.adjustment adj
    where	adj.code				= @p_code
			and adj.company_code	= @p_company_code;

	if @surplus_amount > 0
		select @surplus_amount
	else
		select 0
end;
