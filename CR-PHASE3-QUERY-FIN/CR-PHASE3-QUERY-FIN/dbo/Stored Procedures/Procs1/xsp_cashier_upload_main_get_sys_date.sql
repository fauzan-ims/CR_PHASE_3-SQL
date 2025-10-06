CREATE procedure dbo.xsp_cashier_upload_main_get_sys_date
as
begin
	declare @sysdate datetime ;

	declare @tamptable table
	(
		trx_date datetime
	) ;

	insert into @tamptable
	(
		trx_date
	)
	values (convert(date, dbo.xfn_get_system_date())) ;

	select	trx_date
	from	@tamptable ;
end ;
