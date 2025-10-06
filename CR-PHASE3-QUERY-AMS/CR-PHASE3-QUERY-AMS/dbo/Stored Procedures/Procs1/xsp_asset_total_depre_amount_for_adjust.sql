create procedure dbo.xsp_asset_total_depre_amount_for_adjust
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	select	old_total_depre_comm
	from	dbo.adjustment
	where	code = @p_code
	and		company_code = @p_company_code
end ;
