CREATE PROCEDURE [dbo].[xsp_register_delivery_getrows]
(
     @p_keywords     NVARCHAR(50)
    ,@p_pagenumber   INT
    ,@p_rowspage     INT
    ,@p_order_by     INT
    ,@p_sort_by      NVARCHAR(5)
	,@p_status		 NVARCHAR(20)
	,@p_branch_code	 NVARCHAR(50)
)
AS
BEGIN
    DECLARE @rows_count INT = 0;

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

    SELECT
	@rows_count = COUNT(DISTINCT rd.code)
    FROM dbo.REGISTER_DELIVERY rd
	LEFT JOIN dbo.REGISTER_DELIVERY_DETAIL rdd ON rdd.delivery_code = rd.code
	LEFT JOIN dbo.REGISTER_MAIN rmn ON rmn.code COLLATE SQL_Latin1_General_CP1_CI_AS = rdd.register_code
	LEFT JOIN dbo.ASSET_VEHICLE avh ON avh.asset_code = rmn.fa_code
    WHERE	rd.status = case @p_status
							when 'ALL' then rd.status
							else @p_status
						END
            AND rd.branch_code = case @p_branch_code
									when 'ALL' then rd.branch_code
									else @p_branch_code
								end
			AND (
					rd.code											like '%' + @p_keywords + '%'
				  or rd.branch_code									like '%' + @p_keywords + '%'
				  or rd.branch_name									like '%' + @p_keywords + '%'
				  or rd.status										like '%' + @p_keywords + '%'
				  or convert(varchar(30), rd.date, 103)				like '%' + @p_keywords + '%'
				  or convert(varchar(30), rd.delivery_date, 103)	like '%' + @p_keywords + '%'
				  or rd.delivery_to_name							like '%' + @p_keywords + '%'
				  or rd.resi_no										like '%' + @p_keywords + '%'
				  or avh.plat_no                                    LIKE '%' + @p_keywords + '%'
				  or rd.remark										LIKE '%' + @p_keywords + '%'
				);

    SELECT 
         rd.code
        ,rd.branch_code
        ,rd.branch_name
        ,convert(varchar(30), rd.date, 103)				'date'
        ,rd.status
        ,convert(varchar(30), rd.delivery_date, 103)	'delivery_date'
        ,rd.deliver_by
        ,rd.delivery_to_name
        ,rd.delivery_to_area_no
        ,rd.delivery_to_phone_no
        ,rd.resi_no
		,rd.remark
		,STRING_AGG(avh.plat_no, ', ') AS plat_no
        ,@rows_count									'rowcount'
    FROM dbo.REGISTER_DELIVERY rd
	LEFT JOIN dbo.REGISTER_DELIVERY_DETAIL rdd ON rdd.delivery_code = rd.code
	LEFT JOIN dbo.REGISTER_MAIN rmn ON rmn.code COLLATE SQL_Latin1_General_CP1_CI_AS = rdd.register_code
	LEFT JOIN dbo.ASSET_VEHICLE avh ON avh.asset_code = rmn.fa_code

    WHERE	rd.status = case @p_status
							when 'ALL' then rd.status
							else @p_status
						END
            AND rd.branch_code = case @p_branch_code
									when 'ALL' then rd.branch_code
									else @p_branch_code
								end
			AND (
				  rd.code											like '%' + @p_keywords + '%'
				  or rd.branch_code									like '%' + @p_keywords + '%'
				  or rd.branch_name									like '%' + @p_keywords + '%'
				  or rd.status										like '%' + @p_keywords + '%'
				  or convert(varchar(30), rd.date, 103)				like '%' + @p_keywords + '%'
				  or convert(varchar(30), rd.delivery_date, 103)	like '%' + @p_keywords + '%'
				  or rd.delivery_to_name							like '%' + @p_keywords + '%'
				  or rd.resi_no										like '%' + @p_keywords + '%'
				  or avh.plat_no									LIKE '%' + @p_keywords + '%'
				  or rd.remark										LIKE '%' + @p_keywords + '%'
				)
	 GROUP BY
     rd.code
    ,rd.branch_code
    ,rd.branch_name
    ,rd.date
    ,rd.status
    ,rd.delivery_date
    ,rd.deliver_by
    ,rd.delivery_to_name
    ,rd.delivery_to_area_no
    ,rd.delivery_to_phone_no
    ,rd.resi_no
    ,rd.remark




   order by
    case when @p_sort_by = 'asc' then 
        case @p_order_by
            when 1 then rd.code
            when 2 then cast(rd.date as sql_variant)
            when 3 then rd.remark
            when 4 then rd.status
            else rd.code
        end
    end asc,

    case when @p_sort_by = 'desc' then 
        case @p_order_by
            when 1 then rd.code
            when 2 then cast(rd.date as sql_variant)
            when 3 then rd.remark
            when 4 then rd.status
            else rd.code
        end
    end desc



    offset ((@p_pagenumber - 1) * @p_rowspage) rows 
    fetch next @p_rowspage rows only;

	
END;
