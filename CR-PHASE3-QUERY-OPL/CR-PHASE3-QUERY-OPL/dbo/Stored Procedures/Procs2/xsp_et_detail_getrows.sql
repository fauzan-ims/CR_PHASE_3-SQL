CREATE PROCEDURE [dbo].[xsp_et_detail_getrows]
(
	@p_keywords	   NVARCHAR(50)
	,@p_pagenumber INT
	,@p_rowspage   INT
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
	,@p_et_code	   nvarchar(50)
)
as
begin
	declare @rows_count int = 0
			,@et_status nvarchar(15) ;

	select	@et_status = et_status
	from	dbo.et_main
	where	code = @p_et_code ;

	select	@rows_count = count(1)
	from	et_detail ed
			inner join dbo.agreement_asset aa on (aa.asset_no = ed.asset_no)
	where	ed.et_code = @p_et_code
			and (
					aa.asset_name			like '%' + @p_keywords + '%'
					or aa.fa_reff_no_01		like '%' + @p_keywords + '%'
					or aa.fa_reff_no_02		like '%' + @p_keywords + '%'
					or aa.fa_reff_no_03		like '%' + @p_keywords + '%'
					or ed.os_rental_amount	like '%' + @p_keywords + '%' 
				) ;

	select		ed.id
				,is_terminate						
				,aa.asset_name		
				 + case when aa.replacement_fa_code is null then '' else 'GTS' end asset_name				
				,ed.os_rental_amount	 	
				,case is_terminate
					 when '1' then 'true'
					 else null
				 end 'is_terminate'
				 ,case is_terminate
					 when '1' then 'Yes'
					 else 'No'
				 end 'terminate'
				,@et_status 'et_status'
				--,case when aa.replacement_fa_code is null then aa.fa_reff_no_01 else aa.replacement_fa_reff_no_01 end fa_reff_no_01
				--,case when aa.replacement_fa_code is null then aa.fa_reff_no_02 else aa.replacement_fa_reff_no_02 end fa_reff_no_02
				--,case when aa.replacement_fa_code is null then aa.fa_reff_no_03 else aa.replacement_fa_reff_no_03 end fa_reff_no_03
				,case when aa.fa_reff_no_01 is null then aa.replacement_fa_reff_no_01 else aa.fa_reff_no_01 end fa_reff_no_01
				,case when aa.fa_reff_no_02 is null then aa.replacement_fa_reff_no_02 else aa.fa_reff_no_02 end fa_reff_no_02
				,case when aa.fa_reff_no_03 is null then aa.replacement_fa_reff_no_03 else aa.fa_reff_no_03 end fa_reff_no_03
				,ed.is_approve_to_sell
				,aa.pickup_address
				,aa.pickup_name
				,aa.monthly_rental_rounded_amount
				,ed.credit_amount
				,ed.refund_amount
				,@rows_count 'rowcount'
	from		et_detail ed
				inner join dbo.agreement_asset aa on (aa.asset_no = ed.asset_no)
	where		ed.et_code = @p_et_code
				and (
						aa.asset_name			like '%' + @p_keywords + '%'
						or aa.fa_reff_no_01		like '%' + @p_keywords + '%'
						or aa.fa_reff_no_02		like '%' + @p_keywords + '%'
						or aa.fa_reff_no_03		like '%' + @p_keywords + '%'
						or ed.os_rental_amount	like '%' + @p_keywords + '%' 
					)
					
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by 					
														when 1 then aa.asset_name					
														when 2 then aa.fa_reff_no_01				
														when 3 then aa.fa_reff_no_02				
														when 4 then aa.fa_reff_no_03				
														when 5 then cast(ed.os_rental_amount as sql_variant) 
													end
				end asc
				,case
						when @p_sort_by = 'desc' then case @p_order_by 							
														when 1 then aa.asset_name					
														when 2 then aa.fa_reff_no_01				
														when 3 then aa.fa_reff_no_02				
														when 4 then aa.fa_reff_no_03				
														when 5 then cast(ed.os_rental_amount as sql_variant) 
													end
				end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;

