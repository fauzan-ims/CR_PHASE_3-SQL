CREATE PROCEDURE dbo.xsp_asset_mutation_history_getrows
(
	@p_keywords			nvarchar(50)
	,@p_pagenumber		int
	,@p_rowspage		int
	,@p_order_by		int
	,@p_sort_by			nvarchar(5)
	,@p_asset_code		nvarchar(50)
)
as
begin
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	asset_mutation_history
	where	asset_code = @p_asset_code
	and		(
				document_refference_no					like '%' + @p_keywords + '%'
				or	case document_refference_type
					when 'GRN' then 'GOOD RECEIVE NOTE'
					when 'UPE' then 'UPLOAD ENTRY'
					when 'MNE' then 'ASSET REGISTER'
					when 'MTT' then 'MUTATION'
					when 'DSP' then 'DISPOSAL'
					when 'RDS' then 'REVERSE DISPOSAL'
					when 'SLL' then 'SELL'
					when 'RSL' then 'REVERSE SALE'
					when 'CIT' then 'CHANGE ITEM TYPE'
					when 'CTG' then 'CHANGE CATEGORY'
				else document_refference_type
				end										 like '%' + @p_keywords + '%'
				or	from_branch_name					 like '%' + @p_keywords + '%'
				or	to_branch_name						 like '%' + @p_keywords + '%'
				or convert(nvarchar(30), date, 103)		 like '%' + @p_keywords + '%'
				or	usage_duration						 like '%' + @p_keywords + '%'
			) ;

	select		id
				,asset_code
				,convert(nvarchar(30), date, 103) 'date'
				,case document_refference_type
					when 'GRN' then 'GOOD RECEIVE NOTE'
					when 'UPE' then 'UPLOAD ENTRY'
					when 'MNE' then 'ASSET REGISTER'
					when 'MTT' then 'MUTATION'
					when 'DSP' then 'DISPOSAL'
					when 'RDS' then 'REVERSE DISPOSAL'
					when 'SLL' then 'SELL'
					when 'RSL' then 'REVERSE SALE'
					when 'CIT' then 'CHANGE ITEM TYPE'
					when 'CTG' then 'CHANGE CATEGORY'
				else document_refference_type
				end 'document_refference_type'
				,document_refference_no
				,usage_duration
				,from_branch_code
				,from_branch_name
				,to_branch_code
				,to_branch_name
				,from_location_code
				,to_location_code
				,from_pic_code
				,to_pic_code
				,from_division_code
				,from_division_name
				,to_division_code
				,to_division_name
				,from_department_code
				,from_department_name
				,to_department_code
				,to_department_name
				,from_sub_department_code
				,from_sub_department_name
				,to_sub_department_code
				,to_sub_department_name
				,from_unit_code
				,from_unit_name
				,to_unit_code
				,to_unit_name
				,@rows_count 'rowcount'
	from		asset_mutation_history
	where		asset_code = @p_asset_code
	and			(
					document_refference_no					like '%' + @p_keywords + '%'
					or	case document_refference_type
						when 'GRN' then 'GOOD RECEIVE NOTE'
						when 'UPE' then 'UPLOAD ENTRY'
						when 'MNE' then 'ASSET REGISTER'
						when 'MTT' then 'MUTATION'
						when 'DSP' then 'DISPOSAL'
						when 'RDS' then 'REVERSE DISPOSAL'
						when 'SLL' then 'SELL'
						when 'RSL' then 'REVERSE SALE'
						when 'CIT' then 'CHANGE ITEM TYPE'
						when 'CTG' then 'CHANGE CATEGORY'
					else document_refference_type
					end										 like '%' + @p_keywords + '%'
					or	from_branch_name					 like '%' + @p_keywords + '%'
					or	to_branch_name						 like '%' + @p_keywords + '%'
					or convert(nvarchar(30), date, 103)		 like '%' + @p_keywords + '%'
					or	usage_duration						 like '%' + @p_keywords + '%'
				)
	order by	case
					when @p_sort_by = 'asc' then case @p_order_by
													 when 0 then document_refference_no
													 when 1 then document_refference_type
													 when 2 then from_branch_name
													 when 3 then to_branch_name
													 when 4 then cast(date as sql_variant)
													 when 5 then cast(usage_duration as sql_variant)
												 end
				end asc
				,case
					 when @p_sort_by = 'desc' then case @p_order_by
													 when 0 then document_refference_no
													 when 1 then document_refference_type
													 when 2 then from_branch_name
													 when 3 then to_branch_name
													 when 4 then cast(date as sql_variant)
													 when 5 then cast(usage_duration as sql_variant)
												   end
				 end desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;
end ;
