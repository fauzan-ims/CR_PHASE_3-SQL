CREATE PROCEDURE [dbo].[xsp_master_upload_table_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	
	declare @header_name		nvarchar(250)
			,@table_name		nvarchar(250)



	--select	@header_name = description
	--from	dbo.master_upload_table
	--where	code = @p_code ;

	--SET @header_name = (select stuff((
	--					   select ' '+upper(left(T3.V, 1))+lower(stuff(T3.V, 1, 1, ''))
	--					   from (select cast(replace((select @header_name as '*' for xml path('')), ' ', '<X/>') as xml).query('.')) as T1(X)
	--						 cross apply T1.X.nodes('text()') as T2(X)
	--						 cross apply (select T2.X.value('.', 'varchar(250)')) as T3(V)
	--					   for xml path(''), type
	--					   ).value('text()[1]', 'varchar(250)'), 1, 1, '') as [Capitalize first letter only]);

	select	code
			,description
			,table_name
			,is_active
	from	dbo.master_upload_table
	where	code = @p_code ;

end ;
