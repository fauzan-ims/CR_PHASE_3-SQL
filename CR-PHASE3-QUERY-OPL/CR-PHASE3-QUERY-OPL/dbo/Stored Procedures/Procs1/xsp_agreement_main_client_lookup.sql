--created by, Rian at 21/06/2023	

CREATE procedure dbo.xsp_agreement_main_client_lookup
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	--
	,@p_branch_code nvarchar(50) = ''
)
as
begin
	declare @rows_count int = 0 ;

	declare @tempTable table
	(
		client_no	 nvarchar(50)
		,client_name nvarchar(250)
	) ;

	insert into @tempTable
	(
		client_no
		,client_name
	)
	select	distinct
			client_no
			,client_name
	from	agreement_main
	where	agreement_status = 'GO LIVE'
			and branch_code	 = case @p_branch_code
								   when 'ALL' then branch_code
								   else @p_branch_code
							   end
			and
			(
				client_no like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@tempTable ;

	select		client_no
				,client_name
				,@rows_count 'rowcount'
	from		@tempTable
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then client_no
													 when 2 then client_name
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then client_no
													   when 2 then client_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
