CREATE PROCEDURE dbo.xsp_register_main_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_register_status nvarchar(20)
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
	from	register_main rmn
	inner join dbo.asset ass on (ass.code = rmn.fa_code)
	left join dbo.asset_vehicle av on (ass.code = av.asset_code)
	inner join dbo.order_main om on (om.code collate Latin1_General_CI_AS = rmn.order_code)
	inner join dbo.master_public_service mps on (mps.code = om.public_service_code)
	where	rmn.branch_code = case @p_branch_code
								  when 'ALL' then rmn.branch_code
								  else @p_branch_code
							  end
			and rmn.register_status = case @p_register_status
										  when 'ALL' then rmn.register_status
										  else @p_register_status
									  end
			and (
					rmn.register_no										like '%' + @p_keywords + '%'
					or	convert(varchar(30), rmn.register_date, 103)	like '%' + @p_keywords + '%'
					or	rmn.register_status								like '%' + @p_keywords + '%'
					or	rmn.branch_name									like '%' + @p_keywords + '%'
					or	rmn.fa_code										like '%' + @p_keywords + '%'
					or	ass.item_name									like '%' + @p_keywords + '%'
					or	mps.public_service_name							like '%' + @p_keywords + '%'
					or	av.plat_no										like '%' + @p_keywords + '%'
					or	av.engine_no									like '%' + @p_keywords + '%'
					or	av.chassis_no									like '%' + @p_keywords + '%'
				) ;


		select		rmn.code
					,convert(varchar(30), rmn.register_date, 103) 'register_date'		
					,rmn.register_status			
					,rmn.register_no		
					,rmn.branch_name
					,rmn.fa_code
					,ass.item_name
					,om.public_service_code
					,mps.public_service_name
					,av.plat_no
					,av.engine_no
					,av.chassis_no
					,@rows_count 'rowcount'
		from		register_main rmn
		inner join dbo.asset ass on (ass.code = rmn.fa_code)
		left join dbo.asset_vehicle av on (ass.code = av.asset_code)
		inner join dbo.order_main om on (om.code collate Latin1_General_CI_AS = rmn.order_code)
		inner join dbo.master_public_service mps on (mps.code = om.public_service_code)
		where		rmn.branch_code = case @p_branch_code
										  when 'ALL' then rmn.branch_code
										  else @p_branch_code
									  end
					and rmn.register_status = case @p_register_status
												  when 'ALL' then rmn.register_status
												  else @p_register_status
											  end
					and (
							rmn.register_no										like '%' + @p_keywords + '%'
							or	convert(varchar(30), rmn.register_date, 103)	like '%' + @p_keywords + '%'
							or	rmn.register_status								like '%' + @p_keywords + '%'
							or	rmn.branch_name									like '%' + @p_keywords + '%'
							or	rmn.fa_code										like '%' + @p_keywords + '%'
							or	ass.item_name									like '%' + @p_keywords + '%'
							or	mps.public_service_name							like '%' + @p_keywords + '%'
							or	av.plat_no										like '%' + @p_keywords + '%'
							or	av.engine_no									like '%' + @p_keywords + '%'
							or	av.chassis_no									like '%' + @p_keywords + '%'
						)

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then rmn.register_no
													when 2 then rmn.branch_name
													when 3 then cast(rmn.register_date as sql_variant)
													when 4 then mps.public_service_name
													when 5 then rmn.fa_code + ass.item_name
													when 6 then av.plat_no
													when 7 then rmn.register_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then rmn.register_no
														when 2 then rmn.branch_name
														when 3 then cast(rmn.register_date as sql_variant)
														when 4 then mps.public_service_name
														when 5 then rmn.fa_code + ass.item_name
														when 6 then av.plat_no
														when 7 then rmn.register_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
