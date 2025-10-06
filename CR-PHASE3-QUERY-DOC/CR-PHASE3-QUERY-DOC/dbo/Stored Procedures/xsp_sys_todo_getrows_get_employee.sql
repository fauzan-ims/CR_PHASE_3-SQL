
CREATE PROCEDURE dbo.xsp_sys_todo_getrows_get_employee
(
	@p_keywords		   nvarchar(50)
	,@p_pagenumber	   int
	,@p_rowspage	   int
	,@p_order_by	   int
	,@p_sort_by		   nvarchar(5)
	,@p_user_id		   nvarchar(50) = ''
	,@p_array_position varchar(max) = ''
	,@p_array_branch   varchar(max) = ''
)
as
begin

	/* declare variables */
	declare @rows_count	   int = 0
			,@msg		   nvarchar(max)
			,@link_address nvarchar(250)
			,@query		   nvarchar(250)
			,@query_exec   nvarchar(250)
			,@todo_code	   nvarchar(50) ;

	declare @temptable table
	(
		todo_code	  nvarchar(50)
		,branch_name  nvarchar(250)
		,keterangan	  nvarchar(250)
		,count_data	  nvarchar(50)
		,link_address nvarchar(250)
	) ;

	declare curr_todo_employee cursor fast_forward read_only for
	select		query
				,link_address
				,td.code
	from		dbo.sys_todo td
				inner join dbo.sys_todo_employee tde on (tde.todo_code = td.code)
	where		is_active			  = '1'
				and tde.employee_code = @p_user_id
	order by	td.query desc ;

	open curr_todo_employee ;

	fetch next from curr_todo_employee
	into @query
		 ,@link_address
		 ,@todo_code ;

	while @@fetch_status = 0
	begin
		set @query_exec = 'exec ' + @query + ' @p_todo_code = ''' + @todo_code + '''' + ', @p_user_id = ''' + @p_user_id + '''' + ', @p_array_position = ''' + @p_array_position + '''' + ', @p_array_branch = ''' + @p_array_branch + '''' ;

		--select @query_exec
		insert into @temptable
		(
			todo_code
			,branch_name
			,keterangan
			,count_data
		)
		execute sp_executesql @query_exec ;

		update	@temptable
		set		link_address = @link_address
		where	todo_code    = @todo_code ;

		fetch next from curr_todo_employee
		into @query
			 ,@link_address
			 ,@todo_code ;
	end ;

	close curr_todo_employee ;
	deallocate curr_todo_employee ;

	select	@rows_count = count(1)
	from	@temptable
	where	(
				branch_name						like '%' + @p_keywords + '%'
				or	keterangan					like '%' + @p_keywords + '%'
				or	count_data					like '%' + @p_keywords + '%'
				or	link_address				like '%' + @p_keywords + '%'
			) ;

	select		branch_name
				,keterangan
				,count_data
				,link_address
				,@rows_count as 'rowcount'
	from		@temptable
	where		(
					branch_name						like '%' + @p_keywords + '%'
					or	keterangan					like '%' + @p_keywords + '%'
					or	count_data					like '%' + @p_keywords + '%'
					or	link_address				like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then branch_name
													 when 2 then keterangan
													 when 3 then count_data
													 when 4 then link_address
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then branch_name
													   when 2 then keterangan
													   when 3 then count_data
													   when 4 then link_address
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
