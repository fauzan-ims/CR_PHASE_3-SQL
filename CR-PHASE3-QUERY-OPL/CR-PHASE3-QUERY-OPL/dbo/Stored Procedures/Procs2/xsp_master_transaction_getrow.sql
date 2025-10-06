
CREATE PROCEDURE [dbo].[xsp_master_transaction_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
            ,transaction_name
            ,sp_name
            ,is_active
	from	master_transaction
	where	code = @p_code ;
end ;
