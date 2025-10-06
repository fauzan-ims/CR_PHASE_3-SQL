CREATE procedure dbo.xsp_check_application_status
(
	@p_doc_no	 nvarchar(50)
	,@p_doc_type nvarchar(50)
)
as
begin
	declare @status nvarchar(250)
			,@msg	nvarchar(max) = '' ;

	if (@p_doc_type = 'NPWP')
	begin
		set @p_doc_type = 'TAXID' ;
	end ;

	select top 1
			@status = isnull(am.application_status, '')
	from	dbo.application_main am
			inner join dbo.client_main cm on (cm.code		= am.client_code)
			inner join dbo.client_doc cd on (cd.client_code = cm.code)
	where	cd.document_no		 = @p_doc_no
			and cd.doc_type_code = @p_doc_type
			and am.application_status in
	(
		'ON PROCESS', 'APPROVE', 'HOLD'
	) ;

	if (@status is not null)
	begin
		set @msg = 'This Client is in Process of Registration Application with Status ' + isnull(@status, '') ;
	end ;

	select	isnull(@status, '') 'status'
			,@msg 'msg' ;
end ;
