CREATE procedure [dbo].[xsp_masking_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	--
	,@p_user_id	   nvarchar(50)
)
as
begin
	if (@p_user_id <> 'ADMIN')
	begin
		create user MaskingTestUser without login ;

		grant select
		on schema::dbo
		to	MaskingTestUser ;

		execute as user = 'MaskingTestUser' ;
	end ;

	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.masking
	where	(
				name											like '%' + @p_keywords + '%'
				or	nik											like '%' + @p_keywords + '%'
				or	religion									like '%' + @p_keywords + '%'
				or	phone_no									like '%' + @p_keywords + '%'
				or	email										like '%' + @p_keywords + '%'
				or	convert(nvarchar(30), birthday_date, 103)	like '%' + @p_keywords + '%'
			) ;

	select		id
				,name
				,nik
				,religion
				,phone_no
				,email
				,convert(nvarchar(30), birthday_date, 103) 'birthday_date'
				,@rows_count							   'rowcount'
	from		dbo.masking
	where		(
					name											like '%' + @p_keywords + '%'
					or	nik											like '%' + @p_keywords + '%'
					or	religion									like '%' + @p_keywords + '%'
					or	phone_no									like '%' + @p_keywords + '%'
					or	email										like '%' + @p_keywords + '%'
					or	convert(nvarchar(30), birthday_date, 103)	like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then name
													 when 2 then nik
													 when 3 then religion
													 when 4 then phone_no
													 when 5 then email
													 when 6 then cast(birthday_date as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 1 then name
													 when 2 then nik
													 when 3 then religion
													 when 4 then phone_no
													 when 5 then email
													 when 6 then cast(birthday_date as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

	if (@p_user_id <> 'ADMIN')
	begin
		revert ;

		drop user MaskingTestUser ;
	end ;
end ;
