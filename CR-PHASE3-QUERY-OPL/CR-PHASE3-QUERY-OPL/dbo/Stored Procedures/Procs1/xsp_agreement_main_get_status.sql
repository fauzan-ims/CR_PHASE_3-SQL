create procedure dbo.xsp_agreement_main_get_status
(
	@p_agreement_no nvarchar(50)
)
as
begin
	declare @status nvarchar(250) ;

	select	@status = skt_status
	from	dbo.agreement_information
	where	agreement_no = @p_agreement_no ;

	if (isnull(@status, '') <> '')
	begin
		set @status = 'Agreement is in the process of ' + @status ;
	end ;

	select	@status 'status' ;
end ;
