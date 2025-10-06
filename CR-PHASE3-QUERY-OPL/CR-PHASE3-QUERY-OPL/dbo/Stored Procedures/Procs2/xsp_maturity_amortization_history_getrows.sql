--Created, Rian 21/12/2022

CREATE PROCEDURE dbo.xsp_maturity_amortization_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_id				bigint

)
as
begin
	
	declare @rows_count			int = 0 
			,@asset_no			nvarchar(50)
			,@maturity_code		nvarchar(50);

	select	@asset_no		= asset_no
			,@maturity_code = maturity_code
	from	dbo.maturity_detail
	where	id = @p_id

	select	@rows_count = count(1)
	from		dbo.maturity_amortization_history mah
	inner join	dbo.agreement_asset aa on (aa.asset_no = mah.asset_no)
	where		mah.asset_no = @asset_no
	and			mah.maturity_code = @maturity_code
	and			(
					mah.asset_no				like '%' + @p_keywords + '%'
					or	mah.installment_no		like '%' + @p_keywords + '%'
					or	mah.billing_amount		like '%' + @p_keywords + '%'
					or	mah.description			like '%' + @p_keywords + '%'
					or	mah.old_or_new			like '%' + @p_keywords + '%'
				) ;

	select		mah.maturity_code
				,mah.installment_no
				,mah.asset_no								 
				,convert(nvarchar(15), mah.due_date, 103) 'due_date'									 
				,convert(nvarchar(15), mah.billing_date, 103) 'billing_date'
				,mah.billing_amount
				,mah.description
				,mah.old_or_new
				,aa.asset_name
				,@rows_count 'rowcount'
	from		dbo.maturity_amortization_history mah
	inner join	dbo.agreement_asset aa on (aa.asset_no = mah.asset_no)
	where		mah.asset_no = @asset_no
	and			mah.maturity_code = @maturity_code
	and			(
					mah.asset_no				like '%' + @p_keywords + '%'
					or	mah.installment_no		like '%' + @p_keywords + '%'
					or	mah.billing_amount		like '%' + @p_keywords + '%'
					or	mah.description			like '%' + @p_keywords + '%'
					or	mah.old_or_new			like '%' + @p_keywords + '%'
				)
	order by	mah.installment_no asc
end ;
