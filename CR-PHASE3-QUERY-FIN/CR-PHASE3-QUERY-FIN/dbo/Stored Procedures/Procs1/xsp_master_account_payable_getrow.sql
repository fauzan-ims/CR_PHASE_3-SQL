create procedure dbo.xsp_master_account_payable_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
            ,ap_code
            ,remarks
            ,is_active
	from	dbo.master_account_payable
	where	code = @p_code ;
end ;
