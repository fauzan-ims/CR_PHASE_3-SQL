
CREATE procedure dbo.xsp_asset_get_journal_balancing_amount
(
    @p_company_code nvarchar(50)
  , @p_code nvarchar(50)
  , @p_asset_no nvarchar(50)
)
as
begin
	declare	@db_amount			decimal(18,2)
			,@cr_amount			decimal(18,2)
			,@balance_amount	decimal(18,2)
	
	select	@db_amount = sum(base_amount_db)
			,@cr_amount = sum(base_amount_cr)
	from	dbo.efam_interface_journal_gl_link_transaction_detail
	where	gl_link_transaction_code = @p_code
	and		company_code = @p_company_code

	set @balance_amount = @db_amount - @cr_amount
	select @balance_amount 
end;
