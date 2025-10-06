CREATE PROCEDURE dbo.xsp_document_pending_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_document_status nvarchar(10)
	,@p_from_date		datetime
	,@p_to_date			datetime
)
as
begin
	declare @rows_count int = 0 ;

	if exists
	(
		select	1
		from	sys_global_param
		where	code	  = 'HO'
				and value = @p_branch_code
	)
	begin
		set @p_branch_code = 'ALL' ;
	end ;

	select	@rows_count = count(1)
	from	document_pending dp
			left join dbo.fixed_asset_main fam on (fam.asset_no = dp.asset_no)
	where	document_status = case @p_document_status
								when 'ALL' then dp.document_status
								else @p_document_status
							  end
			and	dp.branch_code = case @p_branch_code
									  when 'ALL' then dp.branch_code
									  else @p_branch_code
								  end
			and dp.entry_date
			between @p_from_date and @p_to_date
			and (
					dp.branch_name								 like '%' + @p_keywords + '%' 
					or	dp.document_type						 like '%' + @p_keywords + '%'
					or	convert(varchar(30), dp.entry_date, 103) like '%' + @p_keywords + '%' 
					or	dp.asset_no								 like '%' + @p_keywords + '%' 
					or	dp.asset_name							 like '%' + @p_keywords + '%' 
					or	fam.reff_no_1							 like '%' + @p_keywords + '%' 
					or	fam.reff_no_2							 like '%' + @p_keywords + '%' 
					or	fam.reff_no_3							 like '%' + @p_keywords + '%' 
					or	dp.document_status						 like '%' + @p_keywords + '%' 
					or	dp.cover_note_no						 like '%' + @p_keywords + '%'
				) ;


		select		dp.code
					,dp.branch_name
					,dp.document_type
					,dp.asset_no
					,dp.asset_name
					,fam.reff_no_1
					,fam.reff_no_2
					,fam.reff_no_3
					,dp.cover_note_no
					,convert(varchar(30), dp.entry_date, 103) 'entry_date' 
					,dp.document_status
					,dp.initial_branch_name	
					,@rows_count 'rowcount'
		from		document_pending dp
					left join dbo.fixed_asset_main fam on (fam.asset_no = dp.asset_no)
		where		document_status = case @p_document_status
										when 'ALL' then dp.document_status
										else @p_document_status
									  end
					and	dp.branch_code = case @p_branch_code
											  when 'ALL' then dp.branch_code
											  else @p_branch_code
										  end 
					and dp.entry_date
					between @p_from_date and @p_to_date
					and (
							dp.branch_name								 like '%' + @p_keywords + '%' 
							or	dp.document_type						 like '%' + @p_keywords + '%'
							or	convert(varchar(30), dp.entry_date, 103) like '%' + @p_keywords + '%' 
							or	dp.asset_no								 like '%' + @p_keywords + '%' 
							or	dp.asset_name							 like '%' + @p_keywords + '%' 
							or	fam.reff_no_1							 like '%' + @p_keywords + '%' 
							or	fam.reff_no_2							 like '%' + @p_keywords + '%' 
							or	fam.reff_no_3							 like '%' + @p_keywords + '%' 
							or	dp.document_status						 like '%' + @p_keywords + '%'
							or	dp.cover_note_no						 like '%' + @p_keywords + '%'
						) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then dp.branch_name
													when 2 then dp.document_type
													when 3 then dp.cover_note_no
													when 4 then dp.asset_no
													when 5 then fam.reff_no_1
													when 6 then cast(dp.entry_date as sql_variant)
													when 7 then dp.document_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1 then dp.branch_name
													when 2 then dp.document_type
													when 3 then dp.cover_note_no
													when 4 then dp.asset_no
													when 5 then fam.reff_no_1
													when 6 then cast(dp.entry_date as sql_variant)
													when 7 then dp.document_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
