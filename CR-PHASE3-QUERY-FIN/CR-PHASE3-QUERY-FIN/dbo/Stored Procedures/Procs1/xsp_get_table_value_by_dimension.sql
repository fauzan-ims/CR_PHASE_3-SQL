CREATE PROCEDURE dbo.xsp_get_table_value_by_dimension
(
	@p_dim_code	   nvarchar(50)
	,@p_reff_code  nvarchar(50)
	,@p_reff_table nvarchar(50)
	,@p_output	   nvarchar(100) output
)
as
begin
	declare @sql			 nvarchar(2000) = ''
			,@param			 nvarchar(2000) = '@out nvarchar(1000) output'
			,@function_param nvarchar(2000) = '@fn_param nvarchar(100),@out nvarchar(1000) output'
			,@table_name	 nvarchar(50)
			,@column_name	 nvarchar(50)
			,@primary		 nvarchar(50)
			,@err_msg		 nvarchar(200)
			,@type			 nvarchar(10)
			,@function_name	 nvarchar(100) ;

	select	@table_name = table_name
			,@column_name = column_name
			,@type = type
			,@function_name = function_name
	from	dbo.sys_dimension
	where	code = @p_dim_code ;

	if @type = 'TABLE'
	begin
		exec dbo.xsp_sys_dimension_get_join_query @p_query = @sql output
												  ,@p_done = 0
												  ,@p_from_table = @table_name
												  ,@p_from_column = @column_name
												  ,@p_to_table = @p_reff_table
												  ,@p_iteration = 0 ;

		select	@primary = col.column_name
		from	information_schema.table_constraints tab
				inner join information_schema.constraint_column_usage col on col.constraint_name  = tab.constraint_name
																			 and   col.table_name = tab.table_name
		where	constraint_type	   = 'PRIMARY KEY'
				and col.table_name = @p_reff_table ;

		if @sql = ''
		begin
			set @err_msg = 'There is no connection from table ' + @table_name + ' to table ' + @p_reff_table ;

			raiserror(@err_msg, 16, -1) ;

			return ;
		end ;

		set @sql = @sql + ' where ' + @p_reff_table + '.' + @primary + ' = ''' + @p_reff_code + '''' ;

		--select	@sql ;
		--print @sql
		exec sp_executesql @sql
						   ,@param
						   ,@out = @p_output output ;
	end ;
	else
	begin
		set @sql = 'set @out = dbo.' + @function_name + '(@fn_param)' ;

		exec sp_executesql @sql
						   ,@function_param
						   ,@fn_param = @p_reff_code
						   ,@out = @p_output output ;
	end ; 
end ;

