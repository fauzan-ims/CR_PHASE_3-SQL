--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_other_lease_getrow
(
	@p_application_survey_code	nvarchar(50)
	,@p_id						bigint
)
as
begin
	select	id
		   ,application_survey_code
		   ,rental_company
		   ,unit
		   ,jenis_kendaraan
		   ,os_periode
		   ,nilai_pinjaman
	from	dbo.application_survey_other_lease
	where	application_survey_code = @p_application_survey_code
			and id					= @p_id ;
end
