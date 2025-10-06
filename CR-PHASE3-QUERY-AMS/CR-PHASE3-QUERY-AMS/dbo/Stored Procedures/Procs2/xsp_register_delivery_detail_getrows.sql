CREATE PROCEDURE [dbo].[xsp_register_delivery_detail_getrows]
(
	@p_keywords	   nvarchar(50)
    ,@p_pagenumber		INT
    ,@p_rowspage		INT
    ,@p_order_by		INT
    ,@p_sort_by			NVARCHAR(5)
	--
	,@p_code	NVARCHAR(50)
)
AS
BEGIN
    declare @rows_count int = 0 ;

	declare @register_delivery_temp table
	(
		id					 BIGINT
		,code				 nvarchar(50)
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

	insert into @register_delivery_temp
	(
		id
		,code
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
	select	rdd.ID
		,rmn.code
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
	FROM dbo.REGISTER_DELIVERY_DETAIL rdd
		INNER JOIN dbo.REGISTER_MAIN rmn ON rmn.CODE = rdd.REGISTER_CODE COLLATE Latin1_General_CI_AS
			outer apply
	(
		select	ass.item_name
				,ass.client_name
				,ass.client_no
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
	where	rdd.DELIVERY_CODE = @p_code
			AND
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
	from	@register_delivery_temp ;

	select		id
				,code
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
	from		@register_delivery_temp
    ORDER BY
        CASE WHEN @p_sort_by = 'asc' THEN
            CASE @p_order_by
                when 1 then code								
				when 2 then public_service_name
				when 3 then client_name
				when 4 then item_name
				when 5 then plat_no
            END
        END ASC,
        CASE WHEN @p_sort_by = 'desc' THEN
            CASE @p_order_by
                when 1 then code								
				when 2 then public_service_name
				when 3 then client_name
				when 4 then item_name
				when 5 then plat_no
            END
        END DESC
    OFFSET ((@p_pagenumber - 1) * @p_rowspage) ROWS
    FETCH NEXT @p_rowspage ROWS ONLY;
END;
