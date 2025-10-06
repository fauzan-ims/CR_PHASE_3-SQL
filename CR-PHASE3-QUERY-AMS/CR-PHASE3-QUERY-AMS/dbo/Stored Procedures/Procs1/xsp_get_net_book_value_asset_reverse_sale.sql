CREATE PROCEDURE dbo.xsp_get_net_book_value_asset_reverse_sale
(
	@p_company_code		  nvarchar(50)
	,@p_code_reverse_sale nvarchar(50)
	,@p_asset_no		  nvarchar(50)
)
as
begin
	declare @amount decimal(18, 2) =0 ;

	select	@amount = net_book_value
	from	dbo.reverse_sale_detail rsd
			inner join dbo.reverse_sale rs on rs.code = rsd.reverse_sale_code
	where	reverse_sale_code	= @p_code_reverse_sale
			and rs.company_code = @p_company_code
			and rsd.asset_code	= @p_asset_no ;

end ;
