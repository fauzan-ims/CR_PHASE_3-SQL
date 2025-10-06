CREATE FUNCTION dbo.xfn_depre_threshold_validation
(
	@p_company_code		nvarchar(50)
	,@p_category_code	nvarchar(50)
	,@p_amount			decimal(18,2)
)
returns int
as
begin
	
	declare @is_valid			int = 1
			,@threshold_amount	decimal(18,2)

	select	@threshold_amount = depre_amount_threshold
	from	dbo.master_category
	where	company_code = @p_company_code
	and		code = @p_category_code

	if @p_amount >= @threshold_amount
		set @is_valid = 1
	else
		set @is_valid = 0

    return @is_valid;

end
