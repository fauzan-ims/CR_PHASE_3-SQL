CREATE PROCEDURE dbo.xsp_master_upload_table_column_lookup_for_master_upload_table_detail
(
	@p_keywords						nvarchar(50)
	,@p_pagenumber					int
	,@p_rowspage					int
	,@p_order_by					int
	,@p_sort_by						nvarchar(5)
	,@p_table_name					nvarchar(250)
	,@p_upload_table_code			nvarchar(50)
)
as
begin
	
	declare @rows_count int = 0 ;

	select	@rows_count = count(1)
	from	information_schema.columns 
	where	table_name like  '' + @p_table_name + ''
	and		column_name not in	(
									select	mutc.column_name 
									from	dbo.master_upload_table_column mutc
									where	upload_table_code = @p_upload_table_code
									and		mutc.column_name = column_name
								)
	and		column_name not in ('ID','CODE','CRE_DATE','CRE_BY','CRE_IP_ADDRESS','MOD_DATE','MOD_BY','MOD_IP_ADDRESS','MANUAL_UPLOAD_STATUS','MANUAL_UPLOAD_REMARKS')
	and		(
				column_name	 like '%' + @p_keywords + '%'
			) ;
	
	select	column_name	
			,data_type
			,isnull(character_maximum_length,0) 'max_length'
			,@rows_count 'rowcount'
	from	information_schema.columns 
	where	table_name like  '' + @p_table_name + ''
	and		column_name not in	(
									select	mutc.column_name 
									from	dbo.master_upload_table_column mutc
									where	upload_table_code = @p_upload_table_code
									and		mutc.column_name = column_name
								)
	and		column_name not in ('ID','CODE','CRE_DATE','CRE_BY','CRE_IP_ADDRESS','MOD_DATE','MOD_BY','MOD_IP_ADDRESS','MANUAL_UPLOAD_STATUS','MANUAL_UPLOAD_REMARKS')
	and		(
				column_name	 like '%' + @p_keywords + '%'
			)
	order by	case 
					when @p_sort_by = 'asc' then case @p_order_by
														when 1 then column_name
														when 2 then data_type
														when 3 then isnull(character_maximum_length,0)
													end
													end asc
												, case 
					when @p_sort_by = 'desc' then case @p_order_by
															when 1 then column_name
															when 2 then data_type
															when 3 then isnull(character_maximum_length,0)
														end
													end
				desc offset ((@p_pagenumber - 1) * @p_rowspage) rows fetch next @p_rowspage rows only ;

end ;
