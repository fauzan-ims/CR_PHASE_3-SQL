
create procedure dbo.xsp_asset_get_sale_amount_after_tax
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	select	(sld.sale_value * 2.5) / 100.00
	from	dbo.sale_detail sld
			inner join dbo.sale sle on sle.code = sld.sale_code
	where	asset_code = @p_asset_no 
	and		sale_code = @p_code
	and		sle.company_code = @p_company_code  ;
end ;
