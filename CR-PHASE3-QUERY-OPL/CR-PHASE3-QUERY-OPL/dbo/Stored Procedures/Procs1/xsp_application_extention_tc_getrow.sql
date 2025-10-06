-- Louis Selasa, 30 April 2024 18.54.48 --
CREATE procedure [dbo].[xsp_application_extention_tc_getrow]
(
	@p_main_contract_no nvarchar(50)
)
as
begin
	select	aet.id
			,aet.main_contract_no
			,aet.description
			,ae.application_no
			,ae.main_contract_status
	from	dbo.application_extention_tc aet
			left join dbo.application_extention ae on (ae.main_contract_no = aet.main_contract_no)
	where	aet.main_contract_no = @p_main_contract_no ;
end ;
