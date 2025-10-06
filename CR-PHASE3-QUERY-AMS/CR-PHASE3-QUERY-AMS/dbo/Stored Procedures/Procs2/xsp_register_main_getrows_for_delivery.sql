CREATE PROCEDURE dbo.xsp_register_main_getrows_for_delivery
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

	declare @register_main table
	(
		code					nvarchar(50)
		,register_date			nvarchar(30)
		,register_status		nvarchar(50)
		,register_no			nvarchar(50)
		,branch_name			nvarchar(250)
		,fa_code				nvarchar(50)
		,item_name				nvarchar(250)
		,order_code				nvarchar(50)
		,public_service_code	nvarchar(50)
		,public_service_name	nvarchar(250)
		,plat_no				nvarchar(50)
		,engine_no				nvarchar(50)
		,chassis_no				nvarchar(50)
		,document_name			nvarchar(4000)
		,client_name			nvarchar(250)
		,receive_remarks		nvarchar(4000)
	) ;

	insert into @register_main
	(
		code
		,register_date
		,register_status
		,register_no
		,branch_name
		,fa_code
		,item_name
		,order_code
		,public_service_code
		,public_service_name
		,plat_no
		,engine_no
		,chassis_no
		,document_name
		,client_name
		,receive_remarks
	)
	select		rmn.code
				,convert(nvarchar(30), rmn.register_date, 103) 'register_date'		
				,rmn.register_status			
				,rmn.register_no		
				,rmn.branch_name
				,rmn.fa_code
				,ass.item_name
				,rmn.order_code
				,om.public_service_code
				,mps.public_service_name
				,av.plat_no
				,av.engine_no
				,av.chassis_no
				,stuff((
				   select	distinct
							', ' + replace(sgs.description, '&', 'dan')
				   from		dbo.register_detail				   rd
							inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
				   where	rd.register_code = rmn.code
				   for xml path('')
			   ), 1, 1, ''
			  )
			  ,ass.client_name
			  ,rmn.receive_remarks
	from		register_main rmn
	inner join dbo.asset ass on (ass.code = rmn.fa_code)
	inner join dbo.asset_vehicle av on (ass.code = av.asset_code)
	left join dbo.order_main om on (om.code collate Latin1_General_CI_AS = rmn.order_code)
	left join dbo.master_public_service mps on (mps.code = om.public_service_code)
	where		rmn.register_status <> 'CANCEL'
				AND rmn.branch_code = case @p_branch_code
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
						or	rmn.order_code									like '%' + @p_keywords + '%'
						or	mps.public_service_name							like '%' + @p_keywords + '%'
						or	av.plat_no										like '%' + @p_keywords + '%'
						or	av.engine_no									like '%' + @p_keywords + '%'
						or	av.chassis_no									like '%' + @p_keywords + '%'
						or	rmn.receive_remarks								like '%' + @p_keywords + '%'
				) ;

	select	@rows_count = count(1)
	from	@register_main

	
		select		code
					,convert(nvarchar(30), register_date, 103) 'register_date'		
					,register_status			
					,register_no		
					,branch_name
					,fa_code
					,item_name
					,order_code
					,public_service_code
					,public_service_name
					,plat_no
					,engine_no
					,chassis_no
					,receive_remarks
					,document_name
					,@rows_count 'rowcount'
		from		@register_main
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then register_no
													when 2 then branch_name
													when 3 then cast(register_date as sql_variant)
													when 4 then fa_code
													when 5 then plat_no
													when 6 then register_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then register_no
														when 2 then branch_name
														when 3 then cast(register_date as sql_variant)
														when 4 then fa_code
														when 5 then plat_no
														when 6 then register_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;
