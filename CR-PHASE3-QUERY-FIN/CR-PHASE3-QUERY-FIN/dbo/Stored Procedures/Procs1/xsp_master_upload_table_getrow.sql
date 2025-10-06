
CREATE PROCEDURE dbo.xsp_master_upload_table_getrow
(
	@p_code nvarchar(50)
)
as
begin
	
	declare @header_name		nvarchar(250)
			,@tabel_name		nvarchar(250)



	select	@header_name = description
	from	dbo.master_upload_table
	where	code = @p_code ;

	SET @header_name = (select stuff((
						   select ' '+upper(left(T3.V, 1))+lower(stuff(T3.V, 1, 1, ''))
						   from (select cast(replace((select @header_name as '*' for xml path('')), ' ', '<X/>') as xml).query('.')) as T1(X)
							 cross apply T1.X.nodes('text()') as T2(X)
							 cross apply (select T2.X.value('.', 'varchar(250)')) as T3(V)
						   for xml path(''), type
						   ).value('text()[1]', 'varchar(250)'), 1, 1, '') as [Capitalize first letter only]);

	select	code
			,description
			,tabel_name
			,template_name
			,sp_validate_name
			,sp_post_name
			,sp_cancel_name
			,sp_upload_name
			,sp_getrows_name
			,@header_name 'header_name_upload_list'
			,is_active
	from	dbo.master_upload_table
	where	code = @p_code ;

end ;
