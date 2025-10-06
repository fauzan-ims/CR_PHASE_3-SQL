--created by, Rian at 22/05/2023	

CREATE PROCEDURE [dbo].[xsp_application_extention_getrows]
(
	@p_keywords	   nvarchar(50)
	,@p_pagenumber int
	,@p_rowspage   int
	,@p_order_by   int
	,@p_sort_by	   nvarchar(5)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	dbo.application_extention ae
	where	(
				ae.application_no										 like '%' + @p_keywords + '%'
				or	ae.main_contract_status								 like '%' + @p_keywords + '%'
				or	ae.main_contract_no									 like '%' + @p_keywords + '%'
				or	ae.remarks											 like '%' + @p_keywords + '%'
				or	case when ae.is_valid = '1' then 'Yes' else 'No' end like '%' + @p_keywords + '%'
			) 

	select		ae.id
			   ,ae.application_no
			   ,ae.main_contract_status
			   ,ae.main_contract_no
			   ,ae.main_contract_file_name
			   ,ae.main_contract_file_path
			   ,ae.remarks
			   ,case when ae.is_valid = '1' then 'Yes' else 'No' end 'is_valid'
			   ,@rows_count 'rowcount'
	from		dbo.application_extention ae
	where		(
					ae.application_no										 like '%' + @p_keywords + '%'
					or	ae.main_contract_status								 like '%' + @p_keywords + '%'
					or	ae.main_contract_no									 like '%' + @p_keywords + '%'
					or	ae.remarks											 like '%' + @p_keywords + '%'
					or	case when ae.is_valid = '1' then 'Yes' else 'No' end like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then ae.application_no
														when 2 then ae.main_contract_no
														when 3 then ae.main_contract_status
														when 4 then ae.remarks
														when 5 then case when ae.is_valid = '1' then 'Yes' else 'No' end
													end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
														when 1 then ae.application_no
														when 2 then ae.main_contract_status
														when 3 then ae.main_contract_no
														when 4 then ae.remarks
														when 5 then case when ae.is_valid = '1' then 'Yes' else 'No' end
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
