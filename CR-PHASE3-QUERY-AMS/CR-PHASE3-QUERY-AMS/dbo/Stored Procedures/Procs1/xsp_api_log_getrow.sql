
create procedure xsp_api_log_getrow
(
	@p_transaction_no nvarchar(250)
)
as
begin
	select	transaction_no
			,log_date
			,url_request
			,json_content
			,response_code
			,response_message
			,response_json
	from	api_log
	where	transaction_no = @p_transaction_no ;
end ;
