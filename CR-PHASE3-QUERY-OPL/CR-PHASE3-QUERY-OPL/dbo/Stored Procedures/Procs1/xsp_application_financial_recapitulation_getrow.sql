CREATE PROCEDURE [dbo].[xsp_application_financial_recapitulation_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	declare @detail_count					  int
			,@month_installment_amount		  decimal(18, 2)
			,@total_outstanding_amount		  decimal(18, 2)
			,@plafond_max_amount			  decimal(18, 2)
			,@presentation_installment_amount decimal(18, 2) ;

	select	@detail_count = count(1)
	from	dbo.application_financial_recapitulation_detail
	where	financial_recapitulation_code = @p_code ;

	select	@month_installment_amount = isnull(sum(installment_amount), 0)
	from	application_financial_recapitulation afr 
			left join dbo.application_exposure ae on (ae.application_no = afr.application_no)
	where	afr.code = @p_code ;

	select	@total_outstanding_amount = isnull(sum(os_installment_amount), 0)
	from	application_financial_recapitulation afr 
			left join dbo.application_exposure ae on (ae.application_no = afr.application_no)
	where	afr.code = @p_code ;

	select	@presentation_installment_amount = isnull(sum(ovd_installment_amount), 0)
	from	application_financial_recapitulation afr 
			left join dbo.application_exposure ae on (ae.application_no = afr.application_no)
	where	afr.code = @p_code ;

	select	afr.code
			,afr.code 'financial_recapitulation_code'
			,afr.application_no
			,afr.from_periode_year
			,afr.from_periode_month
			,case afr.from_periode_month
				 when 1 then 'January'
				 when 2 then 'February'
				 when 3 then 'March'
				 when 4 then 'April'
				 when 5 then 'May'
				 when 6 then 'June'
				 when 7 then 'July'
				 when 8 then 'August'
				 when 9 then 'September'
				 when 10 then 'October'
				 when 11 then 'November'
				 when 12 then 'December'
			 end as 'from_periode_months'
			,afr.to_periode_year
			,afr.to_periode_month
			,case afr.to_periode_month
				 when 1 then 'January'
				 when 2 then 'February'
				 when 3 then 'March'
				 when 4 then 'April'
				 when 5 then 'May'
				 when 6 then 'June'
				 when 7 then 'July'
				 when 8 then 'August'
				 when 9 then 'September'
				 when 10 then 'October'
				 when 11 then 'November'
				 when 12 then 'December'
			 end as 'to_periode_months'
			,afr.current_rasio_pct
			,afr.debet_to_asset_pct
			,afr.return_on_equity_pct 
			,@month_installment_amount 'month_installment_amount'
			,@total_outstanding_amount 'total_outstanding_amount'
			,@plafond_max_amount 'plafond_max_amount'
			,@presentation_installment_amount 'presentation_installment_amount'
			,@detail_count 'detail_count'
	from	application_financial_recapitulation afr
			inner join dbo.application_main am on (am.application_no	= afr.application_no) 
	where	afr.code = @p_code ;
end ;
