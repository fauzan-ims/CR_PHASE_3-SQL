CREATE PROCEDURE dbo.xsp_get_net_book_value_asset_sale
(
	@p_company_code nvarchar(50)
	,@p_code_sale	nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare @amount decimal(18, 2) ;

	select	@amount = sd.net_book_value
	from	dbo.sale_detail sd
			inner join dbo.sale s on s.code = sd.sale_code
	where	sale_code		   = @p_code_sale
			and s.company_code = @p_company_code
			and sd.asset_code = @p_asset_no ;

end ;
