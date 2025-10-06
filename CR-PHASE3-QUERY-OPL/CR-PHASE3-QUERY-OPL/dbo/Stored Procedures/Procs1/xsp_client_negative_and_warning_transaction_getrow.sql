
CREATE procedure [dbo].[xsp_client_negative_and_warning_transaction_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,status
			,date
			,remark
	from	client_negative_and_warning_transaction
	where	code = @p_code ;
end ;

