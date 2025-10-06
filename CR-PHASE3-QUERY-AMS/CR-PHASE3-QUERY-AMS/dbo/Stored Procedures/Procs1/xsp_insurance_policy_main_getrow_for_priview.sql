CREATE procedure dbo.xsp_insurance_policy_main_getrow_for_priview
(
	@p_doc_no nvarchar(50)
)
as
begin
	select	fileDocResult 'doc_file'
	from	insurance_policy_main
			cross apply
	(
		select	doc_file '*'
		for xml path('')
	) t(fileDocResult)
	where	code = @p_doc_no ;
end ;
