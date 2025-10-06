
CREATE procedure dbo.xsp_client_main_lookup
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_client_type nvarchar(10) = ''
	,@p_branch_code nvarchar(50) = 'ALL' -- (+) Ari 2023-10-16 ket : tampilkan berdasarkan branch
)
as
begin
	declare @rows_count int = 0 ;

	-- (+) Ari 2023-10-16 ket : get param
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

	-- (+) Ari 2023-10-16
	declare @tempTable table
	(
		client_no	 nvarchar(50)
		,client_name nvarchar(250)
		,client_type nvarchar(10)
	) ;

	insert into @tempTable
	(
		client_no
		,client_name
		,client_type
	)
	select	distinct
			client_no
			,client_name
			,client_type
	from	dbo.agreement_main
	where	client_type			 = case @p_client_type
									   when '' then client_type
									   else @p_client_type
								   end
			and agreement_status = 'GO LIVE'
			-- (+) Ari 2023-10-16
			and branch_code		 = case @p_branch_code
									   when 'ALL' then branch_code
									   else @p_branch_code
								   end
			-- (+) Ari 2023-10-16
			and
			(
				client_no		like '%' + @p_keywords + '%'
				or	client_name like '%' + @p_keywords + '%'
				or	branch_code like '%' + @p_keywords + '%'
				or	branch_name like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@tempTable ;

	select		client_no
				,client_name
				,client_type
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
-- DSF ambil dari agreement
end ;
