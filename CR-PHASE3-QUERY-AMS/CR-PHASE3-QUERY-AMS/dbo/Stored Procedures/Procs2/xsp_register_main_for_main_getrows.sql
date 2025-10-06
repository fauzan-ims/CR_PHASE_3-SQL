CREATE PROCEDURE [dbo].[xsp_register_main_for_main_getrows]
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_register_status nvarchar(20)
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	declare @register_main table
	(
		code			  nvarchar(50)
		,register_date	  datetime
		,register_status  nvarchar(50)
		,register_no	  nvarchar(50)
		,branch_name	  nvarchar(250)
		,register_remarks nvarchar(4000)
		,fa_code		  nvarchar(50)
		,item_name		  nvarchar(250)
		,document_name	  nvarchar(4000)
	) ;

	insert into @register_main
	(
		code
		,register_date
		,register_status
		,register_no
		,branch_name
		,register_remarks
		,fa_code
		,item_name
		,document_name
	)
	select	rmn.code
			,rmn.register_date
			,case
				 when rmn.register_status = 'PAID'
					  and	rmn.register_process_by = 'INTERNAL' then 'REGISTER'
				 when rmn.register_status = 'PAID'
					  and	rmn.register_process_by = 'CUSTOMER' then 'DONE'
				 else rmn.register_status
			 end
			,rmn.register_no
			,rmn.branch_name
			,rmn.register_remarks
			,rmn.fa_code
			,ass.item_name
			,stuff((
					   select	distinct
								', ' + replace(sgs.description,'&','DAN')
					   from		dbo.register_detail				   rd
								inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
					   where	rd.register_code = rmn.code
					   for xml path('')
				   ), 1, 1, ''
				  )
	from	register_main				rmn
			inner join dbo.asset		ass on (ass.code	   = rmn.fa_code)
			left join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	rmn.branch_code = case @p_branch_code
								  when 'ALL' then rmn.branch_code
								  else @p_branch_code
							  end
			and case
					when rmn.register_status = 'PAID'
						 and rmn.register_process_by = 'INTERNAL' then 'REGISTER'
					when rmn.register_status = 'PAID'
						 and rmn.register_process_by = 'CUSTOMER' then 'DONE'
					else rmn.register_status
				end			= case @p_register_status
								  when 'ALL' then rmn.register_status
								  else @p_register_status
							  end
			and rmn.register_status in
	(
		'HOLD', 'CANCEL', 'ON PROCESS', 'PAID', 'REVISI'
	)
			and
			(
				rmn.register_no												like '%' + @p_keywords + '%'
				or	convert(varchar(30), rmn.register_date, 103)			like '%' + @p_keywords + '%'
				or	rmn.register_remarks									like '%' + @p_keywords + '%'
				or	rmn.branch_name											like '%' + @p_keywords + '%'
				or	case
						when rmn.register_status = 'PAID'
							 and rmn.register_process_by = 'INTERNAL' then 'REGISTER'
						when rmn.register_status = 'PAID'
							 and rmn.register_process_by = 'CUSTOMER' then 'DONE'
						else rmn.register_status
					end														like '%' + @p_keywords + '%'
				or	rmn.fa_code												like '%' + @p_keywords + '%'
				or	ass.item_name											like '%' + @p_keywords + '%'
				or	stuff((
							  select	distinct
										', ' + replace(sgs.description,'&','DAN')
							  from		dbo.register_detail				   rd
										inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
							  where		rd.register_code = rmn.code
							  for xml path('')
						  ), 1, 1, ''
						 )													like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@register_main ;

	select		code
				,register_status
				,register_no
				,branch_name
				,register_remarks
				,fa_code
				,item_name
				,document_name
				,convert(nvarchar(30), register_date, 103) 'register_date'
				,@rows_count 'rowcount'
	from		@register_main
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then register_no
													 when 2 then branch_name
													 when 3 then cast(register_date as sql_variant)
													 when 4 then fa_code
													 when 5 then document_name
													 when 6 then register_remarks
													 when 7 then register_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then register_no
													   when 2 then branch_name
													   when 3 then cast(register_date as sql_variant)
													   when 4 then fa_code
													   when 5 then document_name
													   when 6 then register_remarks
													   when 7 then register_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
