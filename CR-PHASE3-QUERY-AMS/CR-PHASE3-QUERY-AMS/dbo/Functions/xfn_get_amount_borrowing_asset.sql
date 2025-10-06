CREATE FUNCTION dbo.xfn_get_amount_borrowing_asset
(
	@p_asset_code		nvarchar(50)
	,@p_sale_date		datetime
	,@p_agreement_no	nvarchar(50) = null
)
returns nvarchar(50)
as
begin
	declare @amount				decimal(18,2)
			,@asset_periode		int
			,@borrowing_amount	decimal(18,2)

	--selisih umur asset
	select @asset_periode = datediff(month, purchase_date, @p_sale_date) 
	from dbo.asset
	where code = @p_asset_code

	--borrowing rate
	select top 1 @borrowing_amount = isnull(borrowing_interest_amount / periode,0) 
	from ifinopl.dbo.agreement_asset 
	where fa_code = @p_asset_code
	and agreement_no = isnull(@p_agreement_no,agreement_no)

	set @amount = @asset_periode * @borrowing_amount

	return @amount ;
end ;
