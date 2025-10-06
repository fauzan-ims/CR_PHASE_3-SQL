create PROCEDURE dbo.xsp_sys_audit_detail_get_sys_date
as
begin
	declare @sysdate datetime ;

	declare @tamptable table
	(
		date datetime
	) ;

	insert into @tamptable
	(
		date
	)
	values (convert(date, dbo.xfn_get_system_date())) ;

	select	date
	from	@tamptable ;
end ;
