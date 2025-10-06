CREATE PROCEDURE dbo.xsp_document_storage_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	ds.code
			,ds.branch_code
			,ds.branch_name
			,ds.locker_code
			,ds.drawer_code
			,ds.row_code
			,ds.storage_status
			,ds.storage_date
			,ds.storage_type
			,ds.remark
			,ml.locker_name
			,md.drawer_name
			,mr.row_name
	from	document_storage ds
			left join dbo.master_locker ml on (ds.locker_code = ml.code)
			left join dbo.master_drawer md on (ds.drawer_code = md.code)
			left join dbo.master_row mr on (ds.row_code = mr.code)
	where	ds.code = @p_code ;
end ;
