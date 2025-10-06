/*
exec dbo.xsp_agreement_information_getrow_for_thirdparty
*/
-- Louis Rabu, 02 Agustus 2023 15.39.24 -- 
CREATE PROCEDURE dbo.xsp_agreement_information_getrow_for_thirdparty
as
begin
	declare @url nvarchar(4000) ;

	select	@url = value
	from	dbo.sys_global_param
	where	code = 'ENFOU08' ;

	select	ai.agreement_no
			,am.client_no
			,am.client_name
			,'BAD' 'negative_type'
			,ai.blacklist_remark
			,'IFinancing' 'data_source'
			,am.client_type
			,ai.blacklist_date
			,@url 'URL'
	from	dbo.agreement_information ai
			inner join dbo.agreement_main am on (am.agreement_no = ai.agreement_no)
	where	ai.blacklist_status in
			(
				'NEW', 'FAILED'
			) ;
end ;
