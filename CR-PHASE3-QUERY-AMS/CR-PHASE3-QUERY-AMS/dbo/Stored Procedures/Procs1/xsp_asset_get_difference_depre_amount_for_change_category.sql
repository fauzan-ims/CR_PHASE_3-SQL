CREATE PROCEDURE dbo.xsp_asset_get_difference_depre_amount_for_change_category
(
	@p_company_code nvarchar(50)
	,@p_code		nvarchar(50)
	,@p_asset_no	nvarchar(50)
)
as
begin
	declare @prev_depre_amount	decimal(18,2)
			,@last_depre		datetime
			,@sys_date			datetime = dbo.xfn_get_system_date()

	declare @get_amount table
	(amount		numeric(18,2))

	insert into @get_amount (amount)
	select	sum(depreciation_commercial_amount)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(@sys_date)
	and		status = 'POST'
	
	select	@prev_depre_amount = amount
	from	@get_amount
	set @prev_depre_amount = isnull(@prev_depre_amount,0)
		
	select	@last_depre = max(depreciation_date)
	from	dbo.asset_depreciation
	where	asset_code = @p_asset_no
	and		year(depreciation_date) = year(@sys_date)
	and		status = 'POST'

	select	@prev_depre_amount - sum(depreciation_amount)
	from	dbo.asset_depreciation_schedule_commercial
	where	asset_code = @p_asset_no 
	and		transaction_code = ''
	and		year(depreciation_date) = year(@last_depre)
	and		month(depreciation_date) <= month(@last_depre) ;
 

end ;
