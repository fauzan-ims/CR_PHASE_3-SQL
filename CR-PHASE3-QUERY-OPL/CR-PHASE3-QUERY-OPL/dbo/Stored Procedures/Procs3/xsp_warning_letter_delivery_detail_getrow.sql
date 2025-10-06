CREATE PROCEDURE dbo.xsp_warning_letter_delivery_detail_getrow
(
	@p_code nvarchar(10)
)
as
BEGIN

	declare @table_name nvarchar(250)
			,@sp_name	 nvarchar(250) ;

	select	 @table_name = table_name
			,@sp_name	 = sp_name
	from	dbo.sys_report
	where	table_name = 'RPT_TANDA_TERIMA_SURAT_PERINGATAN' ;

	select	id
			,delivery_code
			,letter_code
			--,receive_status
			--,receive_date
			--,receive_by
			--,receive_remark
			--,receive_file_name
			--,receive_paths
			,@table_name 'table_name'
			,@sp_name	 'sp_name'
	from	warning_letter_delivery_detail
	where	id = @p_code ;
end ;
