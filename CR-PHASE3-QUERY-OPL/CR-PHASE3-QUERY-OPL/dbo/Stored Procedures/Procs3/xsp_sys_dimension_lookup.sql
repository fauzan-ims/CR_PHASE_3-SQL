CREATE PROCEDURE dbo.xsp_sys_dimension_lookup
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)
	,@p_array_data			varchar(max) = ''
)
as
begin

	declare @rows_count int = 0 ;

	declare @temptable table
	(
		code nvarchar(50),
		stringvalue nvarchar(250)
	);

	if isnull(@p_array_data,'') = ''
	begin
		insert into @temptable
		(
			code,
			stringvalue
		)
		values
		(   '', -- code - nvarchar(50)
			''  -- stringvalue - nvarchar(250)
		)
    end
	else
	begin
		insert into @temptable
		(
			code,
			stringvalue
		)
		select name,
			   stringvalue
		from dbo.parsejson(@p_array_data) ;
	end	

	select 	@rows_count = count(1)
	from	sys_dimension sd
	where	sd.code not in (
								select stringvalue
								from @temptable
								where isnull(stringvalue, '') = sd.code
							)
			and is_active = '1'
			and (
				code								like 	'%'+@p_keywords+'%'
				or	description						like 	'%'+@p_keywords+'%'
			);
			 
		select	code
				,description
				,@rows_count 'rowcount'
		from	sys_dimension sd
		where	sd.code not in (
									select stringvalue
									from @temptable
									where isnull(stringvalue, '') = sd.code
								)
				and is_active = '1'
				and (
					code								like 	'%'+@p_keywords+'%'
					or	description						like 	'%'+@p_keywords+'%'
				) 
		Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then code
													when 2	then description
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1	then code
													when 2	then description
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end
