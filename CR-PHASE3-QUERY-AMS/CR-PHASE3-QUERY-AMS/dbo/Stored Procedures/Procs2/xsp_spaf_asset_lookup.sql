CREATE PROCEDURE dbo.xsp_spaf_asset_lookup
(
	@p_keywords		nvarchar(50)
	,@p_pagenumber	int
	,@p_rowspage	int
	,@p_order_by	int
	,@p_sort_by		nvarchar(5)
	,@p_code		nvarchar(50)
	,@p_claim_type	nvarchar(25)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.spaf_asset sa
	left join dbo.asset ass on (ass.code = sa.fa_code)
	where	validation_status = 'VALID'
	and		sa.code not in (select spaf_asset_code from dbo.spaf_claim_detail scd 
	left join dbo.spaf_claim sc on (sc.code = scd.spaf_claim_code) 
	where spaf_claim_code = @p_code and sc.status = 'HOLD')
	and	sa.claim_type = @p_claim_type
	and		(
				sa.fa_code						like '%' + @p_keywords + '%'
				or	ass.item_name				like '%' + @p_keywords + '%'
				or	sa.spaf_amount				like '%' + @p_keywords + '%'
			) ;

		select		sa.code
					,sa.fa_code
					,ass.item_name
					,sa.spaf_amount
					,ass.spaf_pct	
					,@rows_count 'rowcount'
		from		dbo.spaf_asset sa
		left join dbo.asset ass on (ass.code = sa.fa_code)
		where		sa.validation_status = 'VALID'
					and		sa.code not in (select spaf_asset_code from dbo.spaf_claim_detail scd 
					left join dbo.spaf_claim sc on (sc.code = scd.spaf_claim_code) 
					where spaf_claim_code = @p_code and sc.status = 'HOLD')
					and	sa.claim_type = @p_claim_type
					and (
							sa.fa_code						like '%' + @p_keywords + '%'
							or	ass.item_name				like '%' + @p_keywords + '%'
							or	sa.spaf_amount				like '%' + @p_keywords + '%'
						)
		order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 1 then sa.fa_code
													 when 2 then ass.item_name
													 when 3 then cast(sa.spaf_amount as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													   when 1 then sa.fa_code
													   when 2 then ass.item_name
													   when 3 then cast(sa.spaf_amount as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
