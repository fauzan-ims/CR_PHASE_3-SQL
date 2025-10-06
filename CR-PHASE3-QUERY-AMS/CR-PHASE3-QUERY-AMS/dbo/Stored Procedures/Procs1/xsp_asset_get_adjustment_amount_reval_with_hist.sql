CREATE PROCEDURE dbo.xsp_asset_get_adjustment_amount_reval_with_hist
(
    @p_company_code nvarchar(50)
  , @p_code nvarchar(50)
  , @p_asset_no nvarchar(50)
)
as
begin
	declare	@total_adjust_hist			decimal(18,2)
			,@last_adjust_date			datetime
			,@total_depre_hist			decimal(18,2)
			,@amount_reval				decimal(18,2)
			,@date						datetime
			,@last_depre				datetime
	
	select	@total_adjust_hist  = sum(total_adjustment)
			,@last_adjust_date	= max(date)
	from	dbo.adjustment
	where	asset_code = @p_asset_no
	and		company_code = @p_company_code
	and		status = 'POST'

	select	@last_depre = max(depreciation_date)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		status = 'POST'
	
	select	@date = date
	from	dbo.adjustment
	where	asset_code = @p_asset_no
	and		company_code = @p_company_code
												
	select	@total_depre_hist = sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no
	and		transaction_code <> ''
	and		convert(char(6),depreciation_date,112) < convert(char(6),@last_adjust_date,112) 

	set @amount_reval = isnull(@total_adjust_hist,0) + isnull(@total_depre_hist,0)
	select @amount_reval 
end;
