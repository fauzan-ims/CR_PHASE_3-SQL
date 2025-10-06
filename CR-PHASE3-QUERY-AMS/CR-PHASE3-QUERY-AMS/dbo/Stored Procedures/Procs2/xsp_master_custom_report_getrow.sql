CREATE PROCEDURE dbo.xsp_master_custom_report_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	mcr.code
			,mcr.company_code
			,mcr.description
			,asset_type
			,transaction_type
			,mcr.is_active
	from	master_custom_report mcr
	where	mcr.code = @p_code ;
end ;
