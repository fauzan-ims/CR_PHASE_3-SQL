--created by, Rian at 17/02/2023 

CREATE PROCEDURE dbo.xsp_master_item_group_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_company_code	nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	master_item_group mig
			left join dbo.sys_general_subcode sgs on sgs.code = mig.transaction_type and sgs.company_code = mig.company_code collate Latin1_General_CI_AS
	where	mig.company_code = @p_company_code
	and		mig.transaction_type = 'FXDAST'
	and		(
					mig.description			like '%' + @p_keywords + '%'
					or	mig.group_level		like '%' + @p_keywords + '%'
					or	sgs.description		like '%' + @p_keywords + '%'
					or	case mig.is_active
							when '1' then 'Yes'
							else 'No'
						end					like '%' + @p_keywords + '%'
					or mig.code				like '%' + @p_keywords + '%'
			) ;

	select		mig.code collate Latin1_General_CI_AS 'code'
				,mig.company_code
				,mig.description
				,mig.group_level
				,mig.parent_code
				,mig.transaction_type
				,case mig.is_active
					 when '1' then 'Yes'
					 else 'No'
				 end 'is_active'
				,@rows_count 'rowcount'
				,sgs.description 'transaction_description' 
	from	master_item_group mig
			left join dbo.sys_general_subcode sgs on sgs.code = mig.transaction_type and sgs.company_code = mig.company_code collate Latin1_General_CI_AS
	where	mig.company_code = @p_company_code
	and		mig.transaction_type = 'FXDAST'
	and			( 
					mig.description				like '%' + @p_keywords + '%'
					or	mig.group_level			like '%' + @p_keywords + '%'
					or	sgs.description			like '%' + @p_keywords + '%'
					or	case mig.is_active
							when '1' then 'Yes'
							else 'No'
						end						like '%' + @p_keywords + '%'
					or mig.code					like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by 
													 when 1 then mig.CODE
													 when 2 then mig.description
													 when 3 then convert(nvarchar(1), mig.group_level)
													 when 4 then mig.is_active
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													  when 1 then mig.CODE
													  when 2 then mig.description
													  when 3 then convert(nvarchar(1), mig.group_level)
													  when 4 then mig.is_active
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
