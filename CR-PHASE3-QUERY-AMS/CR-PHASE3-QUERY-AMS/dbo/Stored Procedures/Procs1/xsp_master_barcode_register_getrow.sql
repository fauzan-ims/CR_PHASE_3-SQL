create PROCEDURE dbo.xsp_master_barcode_register_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,register_date
			,start_date
			,end_date
			,status
	from	master_barcode_register
	where	code = @p_code ;
end ;
