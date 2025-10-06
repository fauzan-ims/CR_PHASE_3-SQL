CREATE PROCEDURE dbo.xsp_master_insurance_lookup_for_application
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_type	   nvarchar(10)
	,@p_array_data varchar(max) = ''
)
as
begin
	declare @rows_count int = 0 ;

	declare @temptable table
	(
		code		 nvarchar(50)
		,stringvalue nvarchar(250)
	) ;

	if (@p_array_data = '[]')
	begin
		set @p_array_data = ''
	end

	if isnull(@p_array_data, '') = ''
	begin
		insert into @temptable
		(
			code
			,stringvalue
		)
		values
		(	'' -- code - nvarchar(50)
			,'' -- stringvalue - nvarchar(250)
		) ;
	end ;
	else
	begin
		insert into @temptable
		(
			code
			,stringvalue
		)
		select	name
				,stringvalue
		from	dbo.parsejson(@p_array_data) ;
	end ;

	select	@rows_count = count(1)
	from	master_insurance
	where	(
				code in
				(
					select	stringvalue
					from	@temptable
					where	isnull(code, '') = 'insurance_code'
				)
				or	@p_array_data = ''
			)
			and insurance_type = @p_type
			and (
					code				like '%' + @p_keywords + '%'
					or	insurance_name	like '%' + @p_keywords + '%'
				) ;

		select		code
					,insurance_name
					,insurance_type
					,@rows_count 'rowcount'
		from		master_insurance
		where		(
						code in
						(
							select	stringvalue
							from	@temptable
							where	isnull(code, '') = 'insurance_code'
						)
						or	@p_array_data = ''
					)
					and insurance_type = @p_type
					and (
							code				like '%' + @p_keywords + '%'
							or	insurance_name	like '%' + @p_keywords + '%'
							or	insurance_type	like '%' + @p_keywords + '%'
						)

	order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then code
													when 2 then insurance_name
													when 3 then insurance_type
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then code
														when 2 then insurance_name
														when 3 then insurance_type
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;


