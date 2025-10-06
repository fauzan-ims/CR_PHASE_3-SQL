
create procedure xsp_master_transaction_getrow
(
	@p_code nvarchar(50)
)
as
begin
	select	code
			,company_code
			,transaction_name
			,module_code
			,module_name
			,api_url
			,sp_name
			,is_active
	from	master_transaction
	where	code = @p_code ;
end ;
