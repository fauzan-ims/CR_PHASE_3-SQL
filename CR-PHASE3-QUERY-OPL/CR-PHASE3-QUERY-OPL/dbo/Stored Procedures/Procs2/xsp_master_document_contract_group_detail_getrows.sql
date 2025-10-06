---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.xsp_master_document_contract_group_detail_getrows
(
	@p_keywords							nvarchar(50)	
	,@p_pagenumber						int
	,@p_rowspage						int
	,@p_order_by						int
	,@p_sort_by							nvarchar(5)
	,@p_document_contract_group_code	nvarchar(50)
)
as
begin
	declare 	@rows_count int = 0 ;

	select 	@rows_count = count(1)
	from	master_document_contract_group_detail d
			inner join dbo.master_document_contract c on (c.code = d.document_contract_code)
	where	document_contract_group_code = @p_document_contract_group_code
			AND (
				id						like 	'%'+@p_keywords+'%'
				or	c.description		like 	'%'+@p_keywords+'%'
			);

		select	id
				,document_contract_group_code
				,c.description 'document_name'
				,@rows_count	 'rowcount'
		from	master_document_contract_group_detail d
				inner join dbo.master_document_contract c on (c.code = d.document_contract_code)
		where	document_contract_group_code = @p_document_contract_group_code 
				AND (
					id						like 	'%'+@p_keywords+'%'
					or	c.description		like 	'%'+@p_keywords+'%'
				)

	Order by case  
					when @p_sort_by = 'asc' then case @p_order_by
													when 1	then c.description 
												 end
				end asc 
				,case when @p_sort_by = 'desc' then case @p_order_by
														when 1	then c.description 
													end
		end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ; 
end

