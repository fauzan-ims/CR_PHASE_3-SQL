---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_document_contract_multiple_contract
(
	@p_keywords						  nvarchar(50)
	,@p_pagenumber					  int
	,@p_rowspage					  int
	,@p_order_by					  int
	,@p_sort_by						  nvarchar(5)
	,@p_document_contract_group_code  NVARCHAR(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	master_document_contract
	where	code not in (
					select	document_contract_code
					from	dbo.MASTER_DOCUMENT_CONTRACT_GROUP_DETAIL
					where	document_contract_code = code
							and document_contract_group_code = @p_document_contract_group_code
			)
			and(
				code				like 	'%'+@p_keywords+'%'
				or	description		like 	'%'+@p_keywords+'%'
				or	document_type	like 	'%'+@p_keywords+'%'
			); 
		select	code
				,description
				,document_type
				,@rows_count	 'rowcount'
		from	master_document_contract
		where	code not in (
					select	document_contract_code
					from	dbo.MASTER_DOCUMENT_CONTRACT_GROUP_DETAIL
					where	document_contract_code = code
							and document_contract_group_code = @p_document_contract_group_code
				)
				and(
					code				like 	'%'+@p_keywords+'%'
					or	description		like 	'%'+@p_keywords+'%'
					or	document_type	like 	'%'+@p_keywords+'%'
				) 
		order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then code
													when 2	then description
													when 3	then document_type
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
													when 1	then code
													when 2	then description
													when 3	then document_type
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;	
end

