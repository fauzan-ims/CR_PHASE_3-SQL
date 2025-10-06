CREATE PROCEDURE dbo.xsp_master_upload_table_column_getrow
(
	@p_code nvarchar(50)
)
as
begin
	
	select	upload_table_code
			,column_name
			,max_length
			,case data_type
				WHEN 'nvarchar' THEN 'STRING'
				WHEN 'int' THEN 'NUMBER'
				WHEN 'datetime' THEN 'DATE'
				WHEN 'decimal' THEN 'DECIMAL'
				else data_type end 'data_type'
    from	dbo.master_upload_table_column
	where	code = @p_code;

end ;
