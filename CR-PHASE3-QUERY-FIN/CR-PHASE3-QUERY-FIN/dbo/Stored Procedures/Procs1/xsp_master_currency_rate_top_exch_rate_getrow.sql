CREATE PROCEDURE dbo.xsp_master_currency_rate_top_exch_rate_getrow
(
	@p_currency_code nvarchar(3)
	,@p_date		 datetime
)
as
begin
	select	 top 1
			 exch_rate
			 ,base.code
	from	 master_currency_rate mcr
			 outer apply (select code from dbo.master_currency where is_base_currency = '1') base
	where	 mcr.currency_code = @p_currency_code
			 and mcr.eff_date <= cast(@p_date as date)
	order by mcr.eff_date desc
end ;
