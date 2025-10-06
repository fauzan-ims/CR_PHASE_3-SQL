CREATE PROCEDURE [dbo].[xsp_lookup_asset_for_controlcard]
(
	@p_keywords				nvarchar(50)
	,@p_pagenumber			int
	,@p_rowspage			int
	,@p_order_by			int
	,@p_sort_by				nvarchar(5)	
	--
	,@p_agreement_no		nvarchar(50)
	,@p_for_all			nvarchar(1) = ''
)
as
begin
	declare @rows_count int = 0 ;
	
	--begin
	--	set @p_agreement_no = 'ALL' ;
	--end ;

	if (@p_for_all <> '')
	BEGIN
		select	@rows_count = count(1)
		from
				(
					select	' ALL' as 'code'
							,' ALL' as 'plat_no'
							,' ALL' as 'name'
					union
					select	ast.code
							,avi.plat_no
							,ast.item_name
					from	dbo.asset ast
					left join dbo.ASSET_VEHICLE avi on avi.ASSET_CODE = ast.CODE
					where ISNULL(agreement_no,'ALL') = case @p_agreement_no
									when 'ALL' then ISNULL(agreement_no,'ALL')
									else @p_agreement_no
								 end					
				) as asset
		where	(
					asset.code		like '%' + @p_keywords + '%'
					or asset.plat_no  like '%' + @p_keywords + '%'	
					or	asset.name  like '%' + @p_keywords + '%'
				) ;

			select		*
			from
						(
							select	' ALL' as 'code'
									,' ALL' as 'plat_no'
									,' ALL' as 'name'
									,@rows_count 'rowcount'
							union
							select	ast.code
									,avi.plat_no
									,ast.item_name
									,@rows_count 'rowcount'
							from	dbo.asset ast
							left join dbo.ASSET_VEHICLE avi on avi.ASSET_CODE = ast.CODE
							where ISNULL(agreement_no,'ALL') = case @p_agreement_no
									when 'ALL' then ISNULL(agreement_no,'ALL')
									else @p_agreement_no
								 end	
						) as asset
			where		(
							asset.code		like '%' + @p_keywords + '%'
							or asset.plat_no  like '%' + @p_keywords + '%'	
							or	asset.name  like '%' + @p_keywords + '%'
						)

			order by 	case  
						when @p_sort_by = 'asc' then case @p_order_by
														when 1 then asset.code
														when 2 then asset.name
						  							end
					end asc 
					,case 
						when @p_sort_by = 'desc' then case @p_order_by
														when 1 then asset.code
														when 2 then asset.name
						  							end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	END
    ELSE
    begin
	select	@rows_count = count(1)
	from	dbo.asset
	where	isnull(agreement_no,'ALL') = case @p_agreement_no
									when 'ALL' then isnull(agreement_no,'ALL')
									else @p_agreement_no
								 end	
	and		(
				code 		like '%' + @p_keywords + '%'
				or	item_name	like '%' + @p_keywords + '%'
			) ;


	select	ast.code
									,avi.plat_no
									,ast.item_name
									,@rows_count 'rowcount'
							from	dbo.asset ast
							left join dbo.asset_vehicle avi on avi.asset_code = ast.code
							where ISNULL(agreement_no,'ALL') = case @p_agreement_no
									when 'ALL' then ISNULL(agreement_no,'ALL')
									else @p_agreement_no
								 end	
	and		(
				ast.CODE		like '%' + @p_keywords + '%'
				or avi.PLAT_NO like '%' + @p_keywords + '%'
				or	ast. item_name	like '%' + @p_keywords + '%'
			)
	order by	 case
						when @p_sort_by = 'asc' then case @p_order_by
							when 1 then ast.code
							when 2 then avi.plat_no
							when 3 then ast.item_name
					end
				end asc,
				case
						when @p_sort_by = 'desc' then case @p_order_by
							when 1 then ast.code
							when 2 then avi.plat_no
							when 3 then ast.item_name
					end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
	
end ;
end
