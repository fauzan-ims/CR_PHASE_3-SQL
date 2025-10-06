CREATE PROCEDURE dbo.xsp_application_main_for_golive_getrow
(
	@p_application_no nvarchar(50)
)
as
begin
	select	ap.application_no
			,ap.application_external_no
			,ap.application_status
			,ap.branch_name
			,ap.application_date
			,ap.client_code
			,ap.marketing_name
			,ap.facility_code
			,ap.currency_code
			,cm.client_name
			,cm.client_no
			,mf.description 'facility_name'
			,ap.agreement_external_no
	from	application_main ap
			left join dbo.client_main cm on (cm.code					= ap.client_code)
			left join dbo.master_facility mf on (mf.code				= ap.facility_code)
	where	ap.application_no = @p_application_no ;
end ;

