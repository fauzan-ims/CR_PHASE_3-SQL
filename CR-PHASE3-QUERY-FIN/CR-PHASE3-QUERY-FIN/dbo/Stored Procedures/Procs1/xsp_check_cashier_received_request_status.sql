/*
exec dbo.xsp_check_cashier_received_request_status @p_doc_ref_code = N'' -- nvarchar(50)
*/

-- Louis Selasa, 20 Juni 2023 09.56.43 -- 

CREATE procedure dbo.xsp_check_cashier_received_request_status
(
	@p_doc_ref_code nvarchar(50)
)
as
begin
	declare @status			   nvarchar(250)
			,@transaction_code nvarchar(50)
			,@msg			   nvarchar(max) = '' ;

	select top 1
			@transaction_code = code
			,@status = isnull(request_status, '')
	from	dbo.cashier_received_request
	where	invoice_no		   = @p_doc_ref_code 
	order by cre_date desc

	if (isnull(@status, '') not in ('HOLD', 'CANCEL'))
	begin
		set @msg = 'This Invoice already in Transaction with status : ' + isnull(@status, '') ;
	end ;
	else if (isnull(@status, '') = 'HOLD')
	begin
		set @status = '' ;
		set @transaction_code = @transaction_code ;
		set @msg = '' ;
	end ;
	else
	begin
		set @status = '' ;
		set @transaction_code = '' ;
		set @msg = '' ;
	end ;

	select	isnull(@status, '') 'status'
			,@msg 'msg'
			,@transaction_code 'transaction_code' ;
end ;
