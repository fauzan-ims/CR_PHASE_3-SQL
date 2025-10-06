CREATE PROCEDURE [dbo].[xsp_register_main_for_realization_getrows]
(
	@p_keywords					NVARCHAR(50)
	,@p_pagenumber				INT
	,@p_rowspage				INT
	,@p_order_by				INT
	,@p_sort_by					NVARCHAR(5)
	,@p_branch_code				NVARCHAR(50)
	,@p_payment_status			NVARCHAR(20)
	,@p_register_status NVARCHAR(20)
)
AS
BEGIN
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
		code				 nvarchar(50)
		,register_date		 DATETIME
        ,register_status	 NVARCHAR(50)
		,payment_status		 nvarchar(50)
		,register_no		 nvarchar(50)
		,branch_name		 nvarchar(250)
		,fa_code			 nvarchar(50)
		,item_name			 nvarchar(250)
		,public_service_code nvarchar(50)
		,public_service_name nvarchar(250)
		,plat_no			 nvarchar(50)
		,engine_no			 nvarchar(50)
		,chassis_no			 nvarchar(50)
		,document_name		 nvarchar(4000)
		,client_name		 nvarchar(250)
	) ;

	insert into @register_main
	(
		code
		,register_date
		,register_status
		,payment_status
		,register_no
		,branch_name
		,fa_code
		,item_name
		,public_service_code
		,public_service_name
		,plat_no
		,engine_no
		,chassis_no
		,document_name
		,client_name
	)
	select	rmn.code
		,rmn.register_date
		,rmn.register_status
		,rmn.payment_status
		,rmn.register_no
		,rmn.branch_name
		,rmn.fa_code
		,asset.item_name
		,ordermain.public_service_code
		,public_service.public_service_name
		,vehicle.plat_no
		,vehicle.engine_no
		,vehicle.chassis_no
		,stuff((
				   select	distinct
							', ' + replace(sgs.description, '&', 'dan')
				   from		dbo.register_detail				   rd
							inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
				   where	rd.register_code = rmn.code
				   for xml path('')
			   ), 1, 1, ''
			  )
		,asset.client_name
	from	register_main rmn
			outer apply
	(
		select	ass.item_name
				,ass.client_name
		from	dbo.asset ass
		where	rmn.fa_code = ass.code
	)					  asset
			outer apply
	(
		select	avh.plat_no
				,avh.engine_no
				,avh.chassis_no
		from	dbo.asset_vehicle avh
		where	avh.asset_code = rmn.fa_code
	) vehicle
			outer apply
	(
		select	om.public_service_code
		from	dbo.order_main om
		where	om.code collate Latin1_General_CI_AS = rmn.order_code
	) ordermain
			outer apply
	(
		select	mps.public_service_name
		from	dbo.master_public_service mps
		where	mps.code = ordermain.public_service_code
	) public_service
	--select	rmn.code
	--		,rmn.register_date
	--		,rmn.payment_status
	--		,rmn.register_no
	--		,rmn.branch_name
	--		,rmn.fa_code
	--		,ass.item_name
	--		,om.public_service_code
	--		,mps.public_service_name
	--		,av.plat_no
	--		,av.engine_no
	--		,av.chassis_no
	--		,stuff((
	--				   select	distinct
	--							', ' + replace(sgs.description,'&','DAN')
	--				   from		dbo.register_detail				   rd
	--							inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
	--				   where	rd.register_code = rmn.code
	--				   for xml path('')
	--			   ), 1, 1, ''
	--			  )
	--from	register_main						 rmn
	--		inner join dbo.asset				 ass on (ass.code							 = rmn.fa_code)
	--		inner join dbo.asset_vehicle			 av on (ass.code							 = av.asset_code)
	--		inner join dbo.order_main			 om on (om.code collate Latin1_General_CI_AS = rmn.order_code)
	--		inner join dbo.master_public_service mps on (mps.code							 = om.public_service_code)
	where	rmn.branch_code		   = case @p_branch_code
										 when 'ALL' then rmn.branch_code
										 else @p_branch_code
									 end
			and rmn.payment_status = case @p_payment_status
										 when 'ALL' then rmn.payment_status
										 else @p_payment_status
									 END
            and rmn.register_status = case @p_register_status
										 when 'ALL' then rmn.register_status
										 else @p_register_status
									 end
			and
			(
				rmn.register_no												like '%' + @p_keywords + '%'
				or	convert(varchar(30), rmn.register_date, 103)			like '%' + @p_keywords + '%'
				or	rmn.register_status										like '%' + @p_keywords + '%'
				or	rmn.payment_status										like '%' + @p_keywords + '%'
				or	rmn.branch_name											like '%' + @p_keywords + '%'
				or	rmn.fa_code												like '%' + @p_keywords + '%'
				or	asset.item_name											like '%' + @p_keywords + '%'
				or	public_service.public_service_name						like '%' + @p_keywords + '%'
				or	vehicle.plat_no											like '%' + @p_keywords + '%'
				or	vehicle.engine_no										like '%' + @p_keywords + '%'
				or	vehicle.chassis_no										like '%' + @p_keywords + '%'
				or	asset.client_name										like '%' + @p_keywords + '%'
				or	rmn.faktur_no											like '%' + @p_keywords + '%'
				or	rmn.realization_invoice_no								like '%' + @p_keywords + '%'
				or	stuff((
							  select	distinct
										', ' + replace(sgs.description,'&','DAN')
							  from		dbo.register_detail				   rd
										inner join dbo.sys_general_subcode sgs on (sgs.code = rd.service_code)
							  where		rd.register_code = rmn.code
							  for xml path('')
						  ), 1, 1, ''
						 )													like '%' + @p_keywords + '%'
			) ;

	select	@rows_count = count(1)
	from	@register_main ;

	select		code
				,convert(nvarchar(30),register_date, 103) 'register_date'
				,register_status
				,payment_status
				,register_no
				,branch_name
				,fa_code
				,item_name
				,public_service_code
				,public_service_name
				,plat_no
				,engine_no
				,chassis_no
				,document_name
				,client_name
				,@rows_count 'rowcount'
	from		@register_main
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then code								
													 when 2 then register_no
													 when 3 then branch_name
													 when 4 then cast(register_date as sql_variant)
													 when 5 then public_service_name
													 when 6 then fa_code
													 when 7 then plat_no
													 when 8 then payment_status
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then code								
													   when 2 then register_no
													   when 3 then branch_name
													   when 4 then cast(register_date as sql_variant)
													   when 5 then public_service_name
													   when 6 then fa_code
													   when 7 then plat_no
													   WHEN 8 then payment_status
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
