
CREATE PROCEDURE dbo.xsp_master_upload_tabel_column_getrow
(
	@p_code nvarchar(50)
)
as
begin
	
	select	upload_tabel_code
			,column_name
			,data_type
			,order_key
    from	dbo.master_upload_tabel_column 
	where	code = @p_code;

end ;
