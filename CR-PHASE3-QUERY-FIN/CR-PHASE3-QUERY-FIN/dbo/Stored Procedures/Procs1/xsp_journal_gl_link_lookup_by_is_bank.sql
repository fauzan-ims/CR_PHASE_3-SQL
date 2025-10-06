CREATE PROCEDURE dbo.xsp_journal_gl_link_lookup_by_is_bank
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_is_bank	   nvarchar(1)
	,@p_array_data varchar(max) = ''
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

	select	@rows_count = count(1)
	from	dbo.journal_gl_link
	where	is_bank		= @p_is_bank
	and		code not in (
							select stringvalue
							from @temptable
							where isnull(code, '') = CODE
						)
	and		(
				gl_link_name			like '%' + @p_keywords + '%'
			) ;

		select	code
				,gl_link_name
				,@rows_count 'rowcount'
		from	dbo.journal_gl_link
		where	is_bank		= @p_is_bank
		and		code not in (
								select stringvalue
								from @temptable
								where isnull(code, '') = CODE
							)
		and		(
					gl_link_name				like '%' + @p_keywords + '%'
				)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then gl_link_name
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then gl_link_name
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
