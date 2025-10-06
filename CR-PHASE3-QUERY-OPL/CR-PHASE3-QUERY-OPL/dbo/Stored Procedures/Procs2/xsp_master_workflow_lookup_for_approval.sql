CREATE PROCEDURE dbo.xsp_master_workflow_lookup_for_approval
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_flow_type  nvarchar(15)
	,@p_array_data varchar(max) = ''
)
as
begin
	declare @rows_count int = 0 ;

	declare @temptable table
	(
		position_name nvarchar(250)
		,stringvalue  nvarchar(250)
	) ;

	if isnull(@p_array_data, '') = ''
	begin
		insert into @temptable
		(
			position_name
			,stringvalue
		)
		values
		(	'' -- position_code - nvarchar(50)
			,'' -- stringvalue - nvarchar(250)
		) ;
	end ;
	else
	begin
		insert into @temptable
		(
			position_name
			,stringvalue
		)
		select	name
				,stringvalue
		from	dbo.parsejson(@p_array_data) ;
	end ;

	select	@rows_count = count(detail.code)
	from
			(
				select	mw.code
						,mw.description
				from	dbo.master_workflow mw
						inner join dbo.master_application_flow_detail mafd on (mafd.workflow_code = mw.code)
						inner join dbo.master_application_flow maf on (maf.code					  = mafd.application_flow_code)
						inner join dbo.master_workflow_position mwp on mwp.workflow_code		  = mw.code
				where	mw.is_active			  = '1'
						and mw.code not in
	(
		'GO LIVE', 'ENTRY'
	)
						--and maf.flow_type		  = @p_flow_type
						--and (
						--		mwp.position_code in
						--		(
						--			select	stringvalue
						--			from	@temptable
						--		)
						--		or	@p_array_data = ''
						--	)
						and (
								mw.code					like '%' + @p_keywords + '%'
								or	mw.description		like '%' + @p_keywords + '%'
							)
				group by mw.code,mw.description
			) detail ;

	select 
		*
	from
		(
			select		mw.code
						,mw.description
						,@rows_count as 'rowcount'
			from		dbo.master_workflow mw
						inner join dbo.master_application_flow_detail mafd on (mafd.workflow_code = mw.code)
						inner join dbo.master_application_flow maf on (maf.code					  = mafd.application_flow_code)
						inner join dbo.master_workflow_position mwp on mwp.workflow_code		  = mw.code
			where		mw.is_active			  = '1'
						and mw.code not in
	(
		'GO LIVE', 'ENTRY'
	)
						--and maf.flow_type		  = @p_flow_type
						--and (
						--		mwp.position_code in
						--		(
						--			select	stringvalue
						--			from	@temptable
						--		)
						--		or	@p_array_data = ''
						--	)
						and (
								mw.code				like '%' + @p_keywords + '%'
								or	mw.description	like '%' + @p_keywords + '%'
							)
			group by	mw.code,mw.description
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then mw.code
														when 2 then mw.description 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then mw.code
														when 2 then mw.description 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only 
			) detail ;
end ;
