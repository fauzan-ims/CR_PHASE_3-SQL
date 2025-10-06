create PROCEDURE dbo.xsp_branch_todo_getall_data
(
	@p_user_id		   nvarchar(50) = ''
	,@p_array_position varchar(max) = ''
	,@p_array_branch   varchar(max) = ''
)
as
begin
	declare @rows_count	   int = 0
			,@msg		   nvarchar(max)
			,@link_address nvarchar(250)
			,@query		   nvarchar(250)
			,@query_exec   nvarchar(250)
			,@todo_code	   nvarchar(50) 
			,@priority     nvarchar(10);

	declare @temptable table
	(
		todo_code	  nvarchar(50)
		,branch_name  nvarchar(250)
		,keterangan	  nvarchar(250)
		,count_data	  nvarchar(50)
		,link_address nvarchar(250)
		,priority     nvarchar(10)
	) ;

	declare curr_todo_employee cursor fast_forward read_only for
	select		query
				,link_address
				,td.code
				,tde.priority
	from		dbo.sys_todo td
				inner join dbo.sys_todo_employee tde on (tde.todo_code = td.code)
	where		is_active			  = '1'
				and tde.employee_code = @p_user_id
	order by	td.query desc ;

	open curr_todo_employee ;

	fetch next from curr_todo_employee
	into @query
		 ,@link_address
		 ,@todo_code 
		 ,@priority;

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
				,priority    = @priority
		where	todo_code    = @todo_code ;

		fetch next from curr_todo_employee
		into @query
			 ,@link_address
			 ,@todo_code 
			 ,@priority;
	end ;

	close curr_todo_employee ;
	deallocate curr_todo_employee ; 

	select		branch_name
				,keterangan  as 'keterangan'
				,count_data
				,link_address
				,priority
	from		@temptable
	order by count_data desc
end

