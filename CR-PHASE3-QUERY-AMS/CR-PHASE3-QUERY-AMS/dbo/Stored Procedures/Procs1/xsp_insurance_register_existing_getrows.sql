CREATE PROCEDURE dbo.xsp_insurance_register_existing_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_branch_code		nvarchar(50)
	,@p_register_status nvarchar(10)
	,@p_insurance_type  nvarchar(10)
)
as
begin
	declare @rows_count int = 0 ;

	if exists ( select 1 from sys_global_param where code ='HO' and value = @p_branch_code)	begin		set @p_branch_code = 'ALL'	end

	select	@rows_count = count(1)
	from	insurance_register_existing ire
			LEFT join dbo.master_insurance mi on (mi.code = ire.insurance_code)
			outer apply(select count(id) 'id' from dbo.insurance_register_existing_asset irea where irea.register_code = ire.code) asset
	where	ire.branch_code			= case @p_branch_code
										  when 'all' then ire.branch_code
										  else @p_branch_code
									  end
			and ire.register_status = case @p_register_status
										  when 'all' then ire.register_status
										  else @p_register_status
									  end
			and ire.insurance_type = case @p_insurance_type
										  when 'all' then ire.insurance_type
										  else @p_insurance_type
									  end
		    and (
					ire.register_no				like '%' + @p_keywords + '%'
					or	ire.branch_name			like '%' + @p_keywords + '%'
					or	ire.policy_name			like '%' + @p_keywords + '%'
					or	ire.register_status		like '%' + @p_keywords + '%'
					or	ire.sum_insured_amount	like '%' + @p_keywords + '%'
					or  mi.insurance_name		like '%' + @p_keywords + '%'
					or  asset.id				like '%' + @p_keywords + '%'
				) ;

		select		ire.code
					,ire.register_no
					,ire.branch_name
					,ire.policy_name
					,ire.register_status
					,ire.policy_object_name
					,ire.sum_insured_amount
					,mi.insurance_name
					,asset.id
					,@rows_count 'rowcount'
		from		insurance_register_existing ire
					LEFT join dbo.master_insurance mi on (mi.code = ire.insurance_code)
					outer apply(select count(id) 'id' from dbo.insurance_register_existing_asset irea where irea.register_code = ire.code) asset
		where	ire.branch_code			= case @p_branch_code
											  when 'all' then ire.branch_code
											  else @p_branch_code
										  end
				and ire.register_status = case @p_register_status
											  when 'all' then ire.register_status
											  else @p_register_status
										  end
				and ire.insurance_type = case @p_insurance_type
											  when 'all' then ire.insurance_type
											  else @p_insurance_type
										  end
				and (
						ire.register_no				like '%' + @p_keywords + '%'
						or	ire.branch_name			like '%' + @p_keywords + '%'
						or	ire.policy_name			like '%' + @p_keywords + '%'
						or	ire.register_status		like '%' + @p_keywords + '%'
						or	ire.sum_insured_amount	like '%' + @p_keywords + '%'
						or  mi.insurance_name		like '%' + @p_keywords + '%'
						or  asset.id				like '%' + @p_keywords + '%'
					) 

		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1 then ire.register_no
													when 2 then ire.branch_name
													when 3 then cast(ire.sum_insured_amount as sql_variant)
													when 4 then mi.insurance_name
													when 5 then ire.register_status
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ire.register_no
														when 2 then ire.branch_name
														when 3 then cast(ire.sum_insured_amount as sql_variant)
														when 4 then mi.insurance_name
														when 5 then ire.register_status
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end ;

