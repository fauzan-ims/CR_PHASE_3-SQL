CREATE procedure dbo.xsp_monitoring_document_position_getrows
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_branch_code nvarchar(50)
)
as
begin
	declare @rows_count			  int = 0
			,@branch_name		  nvarchar(250)
			,@position			  nvarchar(50)
			,@mutation_location	  nvarchar(250)
			,@custody_branch_name nvarchar(250)
			,@quantity			  int ;

	declare @temptable table
	(
		branch_name			 nvarchar(250)
		,document_status	 nvarchar(250)
		,mutation_location	 nvarchar(250)
		,custody_branch_name nvarchar(250) 
	) ;

	declare curr_error_log cursor fast_forward read_only for
	select		branch_name
				,document_status 'position'
				,mutation_location
				,custody_branch_name 
	from		document_main
	where		branch_code			= @p_branch_code
				and document_status <> 'RELEASE'
	group by	document_status
				,branch_name
				,mutation_location
				,custody_branch_name ;

	open curr_error_log ;

	fetch next from curr_error_log
	into @branch_name
		 ,@position
		 ,@mutation_location
		 ,@custody_branch_name  ;

	while @@fetch_status = 0
	begin
		begin
			insert into @temptable
			(
				branch_name
				,document_status
				,mutation_location
				,custody_branch_name 
			)
			values
			(@branch_name, @position, @mutation_location, @custody_branch_name) ;
		end ;

		fetch next from curr_error_log
		into @branch_name
			 ,@position
			 ,@mutation_location
			 ,@custody_branch_name ;
	end ;

	close curr_error_log ;
	deallocate curr_error_log ;

	select	@rows_count = count(1)
	from	@temptable
	where	(
				branch_name like '%' + @p_keywords + '%'
				or	document_status like '%' + @p_keywords + '%'
				or	mutation_location like '%' + @p_keywords + '%'
				or	custody_branch_name like '%' + @p_keywords + '%' 
			) ;

	select		branch_name
				,document_status 'position'
				,mutation_location
				,custody_branch_name
				,count(1) 'quantity'
				,@rows_count 'rowcount'
	from		@temptable
	where		(
					branch_name like '%' + @p_keywords + '%'
					or	document_status like '%' + @p_keywords + '%'
					or	mutation_location like '%' + @p_keywords + '%'
					or	custody_branch_name like '%' + @p_keywords + '%' 
				)
	group by	document_status
				,branch_name
				,mutation_location
				,custody_branch_name 
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then custody_branch_name
													 when 2 then branch_name
													 when 3 then document_status
													 when 4 then mutation_location 
													 when 5 then cast(count(1) as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then custody_branch_name
													   when 2 then branch_name
													   when 3 then document_status
													   when 4 then mutation_location
													 when 5 then cast(count(1) as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
