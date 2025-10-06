CREATE PROCEDURE dbo.xsp_repossession_letter_collateral_getrows
(
	@p_keywords			 nvarchar(50)
	,@p_pagenumber		 int
	,@p_rowspage		 int
	,@p_order_by		 int
	,@p_sort_by			 nvarchar(5)
	,@p_skt_no			 nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	repossession_letter_collateral rlc
			left join dbo.agreement_asset ac on (ac.asset_no = rlc.asset_no)
			left join dbo.repossession_letter rl on rl.letter_no = rlc.letter_code
	where	rlc.letter_code		= @p_skt_no
	and		(
				rlc.id							like '%' + @p_keywords + '%'
				or	ac.asset_no					like '%' + @p_keywords + '%'
				or	ac.fa_name				like '%' + @p_keywords + '%'
				or	ac.asset_status				like '%' + @p_keywords + '%'
				or	ac.asset_amount				like '%' + @p_keywords + '%'
				or	rlc.is_success_repo			like '%' + @p_keywords + '%'
			) ;

		select		rlc.id
					,ac.asset_no
					,ac.fa_name 'asset_name'
					,ac.asset_status
					,ac.market_value
					,rlc.is_success_repo
					,ac.asset_amount
					,@rows_count 'rowcount'
		from	repossession_letter_collateral rlc
				left join dbo.agreement_asset ac on (ac.asset_no = rlc.asset_no)
				left join dbo.repossession_letter rl on rl.letter_no = rlc.letter_code
		where	rlc.letter_code		= @p_skt_no
		and		(
					rlc.id							like '%' + @p_keywords + '%'
					or	ac.fa_name					like '%' + @p_keywords + '%'
					or	ac.asset_name				like '%' + @p_keywords + '%'
					or	ac.asset_status				like '%' + @p_keywords + '%'
					or	ac.asset_amount				like '%' + @p_keywords + '%'
					or	rlc.is_success_repo			like '%' + @p_keywords + '%'
				)
		order by	case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ac.asset_no + ac.fa_name
													when 2 then ac.asset_status
													when 3 then cast(ac.asset_amount as sql_variant)
													when 4 then rlc.is_success_repo
												 end
					end asc 
					,case when @p_sort_by = 'desc' then case @p_order_by
															when 1 then ac.asset_no + ac.fa_name
															when 2 then ac.asset_status
															when 3 then cast(ac.asset_amount as sql_variant)
															when 4 then rlc.is_success_repo
														end
					end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end ;
