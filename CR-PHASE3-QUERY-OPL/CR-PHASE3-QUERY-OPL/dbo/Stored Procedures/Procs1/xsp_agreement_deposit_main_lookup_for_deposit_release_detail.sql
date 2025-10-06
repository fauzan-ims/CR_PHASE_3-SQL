CREATE procedure dbo.xsp_agreement_deposit_main_lookup_for_deposit_release_detail
(
	@p_keywords				 nvarchar(50)
	,@p_pagenumber			 int
	,@p_rowspage			 int
	,@p_order_by			 int
	,@p_sort_by				 nvarchar(5)
	,@p_currency_code		 nvarchar(3)
	,@p_agreement_no		 nvarchar(50)
	,@p_array_data			 varchar(max) = null
)
as
begin
	declare @rows_count int = 0 ;

	declare @temptable table
	(
		code		 nvarchar(50)
		,stringvalue nvarchar(250)
	) ;

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
	from	dbo.agreement_deposit_main dm
		 inner join agreement_main am on (am.agreement_no = dm.agreement_no)
	where agreement_status in ('GO LIVE', 'TERMINATE')
	and   dm.code not in
			(
				select	stringvalue
				from	@temptable tt
				where	tt.stringvalue = dm.code
			)
			and dm.deposit_currency_code	= @p_currency_code
			and dm.agreement_no	= @p_agreement_no
			and deposit_amount > 0
			and 
			(
					dm.deposit_currency_code 	like '%' + @p_keywords + '%'
					or dm.deposit_type			like '%' + @p_keywords + '%'
					or dm.deposit_amount		like '%' + @p_keywords + '%'
				) ;

		select		dm.code
					,dm.agreement_no
					,dm.deposit_type
					,dm.deposit_amount	
					,dm.deposit_currency_code
					,@rows_count 'rowcount'
		from		agreement_deposit_main dm
		 inner join agreement_main am on (am.agreement_no = dm.agreement_no)
		where agreement_status in ('GO LIVE', 'TERMINATE')		
		and	  dm.code not in
					(
						select	stringvalue
						from	@temptable tt
						where	tt.stringvalue = dm.code
					)
					and dm.deposit_currency_code	= @p_currency_code
					and dm.agreement_no= @p_agreement_no
					and deposit_amount > 0
					and 
					(
							dm.deposit_currency_code 	like '%' + @p_keywords + '%'
							or dm.deposit_type			like '%' + @p_keywords + '%'
							or dm.deposit_amount		like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then dm.deposit_type
														when 2 then dm.deposit_currency_code
														when 3 then cast(dm.deposit_amount as sql_variant)
												 end
					end asc
					,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then dm.deposit_type
														when 2 then dm.deposit_currency_code
														when 3 then cast(dm.deposit_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
