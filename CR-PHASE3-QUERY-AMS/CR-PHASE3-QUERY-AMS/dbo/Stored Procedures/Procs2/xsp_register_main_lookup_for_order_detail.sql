CREATE PROCEDURE dbo.xsp_register_main_lookup_for_order_detail
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_order_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;
	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	register_main rmn
			inner join dbo.asset ass on (ass.code = rmn.fa_code)
			inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
	where	rmn.register_status = 'ON PROCESS'
			and isnull(rmn.order_status,'') = ''
			and isnull(rmn.order_code,'') = ''
			--and rmn.register_process_by = 'INTERNAL'
	and		not exists
			(
				select	od.order_code
				from	dbo.order_detail od
				where	od.register_code = rmn.code
						and od.order_code	  = @p_order_code
			) 
			and rmn.branch_code = case @p_branch_code
								  when 'ALL' then rmn.branch_code
								  else @p_branch_code
							  end
			and	(
					rmn.register_no										like '%' + @p_keywords + '%'
					or	rmn.fa_code										like '%' + @p_keywords + '%'
					or	ass.item_name									like '%' + @p_keywords + '%'
					or	convert(varchar(50), rmn.register_date, 103)	like '%' + @p_keywords + '%'
					or	avh.plat_no										like '%' + @p_keywords + '%'

				) ;

		select		rmn.code
					,rmn.fa_code
					,ass.item_name
					,rmn.register_no
					,convert(varchar(50), rmn.register_date, 103)	'register_date'
					,avh.plat_no
					,@rows_count 'rowcount'
		from		register_main rmn
					inner join dbo.asset ass on (ass.code = rmn.fa_code)
					inner join dbo.asset_vehicle avh on (avh.asset_code = ass.code)
		where		rmn.register_status = 'ON PROCESS'
					and isnull(rmn.order_status,'') = ''
					and isnull(rmn.order_code,'') = ''
					--and rmn.register_process_by = 'INTERNAL'
		and			not exists
					(
						select	od.order_code
						from	dbo.order_detail od
						where	od.register_code = rmn.code
								and od.order_code	  = @p_order_code
					) 
					and rmn.branch_code = case @p_branch_code
								  when 'ALL' then rmn.branch_code
								  else @p_branch_code
							  end
					and	(
					rmn.register_no										like '%' + @p_keywords + '%'
					or	rmn.fa_code										like '%' + @p_keywords + '%'
					or	ass.item_name									like '%' + @p_keywords + '%'
					or	convert(varchar(50), rmn.register_date, 103)	like '%' + @p_keywords + '%'
					or	avh.plat_no										like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then rmn.register_no
													when 2 then cast(rmn.register_date as sql_variant) 
													when 3 then rmn.fa_code
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rmn.register_no
														when 2 then cast(rmn.register_date as sql_variant) 
														when 3 then rmn.fa_code
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
