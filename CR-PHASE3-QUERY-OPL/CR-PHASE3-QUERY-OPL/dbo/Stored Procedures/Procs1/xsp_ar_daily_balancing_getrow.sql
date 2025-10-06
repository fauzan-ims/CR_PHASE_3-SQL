CREATE PROCEDURE dbo.xsp_ar_daily_balancing_getrow
(
	@p_as_at_date datetime
)
as
begin
	--raffi : dikarnakan sudah memakai konsep baru untuk generate tiga hari kebelakang pada saat libur
	--if(cast(@p_as_at_date as date) <> dateadd(day, -1, cast(dbo.xfn_get_system_date() as date)))
	--begin 
	--	exec dbo.xsp_ar_daily_balancing_insert @p_eod_date = @p_as_at_date
	--end
	
    
	select	replace(agreement_no, '.', '/') agreement_no
			,client_name
			,ar_due
			,ar_not_due
			,eod_date
	from	dbo.ar_daily_balancing with (nolock)
	where	cast(eod_date as date) = cast(@p_as_at_date as date) ;
end ;
