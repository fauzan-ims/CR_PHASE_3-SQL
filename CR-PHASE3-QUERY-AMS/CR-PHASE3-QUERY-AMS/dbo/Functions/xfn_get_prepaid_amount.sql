CREATE FUNCTION dbo.xfn_get_prepaid_amount
(
	@p_branch_code nvarchar(50)
	,@p_periode	   nvarchar(6)
)
returns decimal(18, 2)
as
begin
	declare @amount decimal(18, 2) ;

	-- ambil total prepaid amount berdasarkan bulan dan tahun saja
	--select @amount = isnull(sum(prepaid_amount),0) 
	--from dbo.asset_prepaid_schedule aps
	--inner join dbo.asset_prepaid_main apm on (apm.prepaid_no = aps.prepaid_no)
	--left join dbo.asset ass on (ass.code = apm.fa_code)
	--where 
	----month(aps.prepaid_date) = month(eomonth(dbo.xfn_get_system_date()))
	----and year(aps.prepaid_date) = year(eomonth(dbo.xfn_get_system_date()))
	--convert(nvarchar(6), aps.prepaid_date, 112) <= convert(nvarchar(6),dbo.fn_get_system_date(),112)
	--and apm.prepaid_type = 'INSURANCE'
	--and isnull(ass.branch_code,'') = @p_branch_code

	select	@amount = isnull(sum(ap.prepaid_amount), 0)
	from	dbo.asset_prepaid				  ap
			inner join dbo.asset_prepaid_main apm on ap.prepaid_no = apm.prepaid_no
			left join dbo.asset				  ass on apm.fa_code   = ass.code
	where	convert(nvarchar(6), ap.prepaid_date, 112) = @p_periode
			and apm.prepaid_type					   = 'INSURANCE'
			and isnull(ass.branch_code, '')			   = @p_branch_code
			and ap.status							   = 'HOLD' ;

	return @amount ;
end ;
