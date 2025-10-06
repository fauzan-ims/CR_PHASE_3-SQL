--created by, Rian at 24/05/2023 

CREATE PROCEDURE dbo.xsp_application_survey_getrow
(
	@p_application_no nvarchar(50)
)
as
begin

	declare	@total_amount		decimal(18,2)
			,@average_amount	decimal(18,2)
			,@table_name		nvarchar(250)
			,@sp_name			nvarchar(250)

	select	@total_amount = sum(asp.ni_amount)
	from	dbo.application_survey aps
			left join dbo.application_survey_plan asp on (asp.application_survey_code = aps.code)
	where	aps.application_no = @p_application_no ;

	select	@average_amount = avg(asbd.monthly_amount)
	from	dbo.application_survey aps
			left join dbo.application_survey_bank asb on (asb.application_survey_code			  = aps.code)
			left join dbo.application_survey_bank_detail asbd on (asbd.application_survey_bank_id = asb.id)
	where	aps.application_no = @p_application_no ;

	select	@table_name	= table_name
			,@sp_name	= sp_name
	from	dbo.sys_report
	where	table_name	  = 'RPT_SURVEY'
			and is_active = '1' ;

	select	aps.code
			,aps.application_no
			,aps.nama
			,aps.application_type
			,aps.group_name
			,aps.alamat_kantor
			,aps.alamat_kantor_kota
			,aps.alamat_kantor_provinsi
			,aps.alamat_usaha
			,aps.alamat_usaha_kota
			,aps.alamat_usaha_provinsi
			,aps.alamat_sejak_usaha
			,aps.komoditi
			,aps.tujuan_pengadaan_unit
			,aps.as_of_date
			,aps.monthly_sales
			,aps.total_monthly_expense
			,aps.total_monthly_installment
			,aps.total_monthly_installment_other
			,aps.net_income
			,aps.overall_assessment
			,aps.notes
			,aps.economic_sector_evaluation
			,aps.pemberi_kerja
			,aps.kelas_pemberi_kerja
			,aps.management_style
			,aps.lokasi_area_kerja
			,aps.no_of_client
			,aps.no_of_employee
			,aps.credit_line_of_bank
			,aps.business_expansion
			,aps.mo_summary
			,aps.capacity
			,aps.character
			,aps.strength
			,aps.weakness
			,aps.date_of_visit
			,aps.time
			,aps.survey_method
			,aps.venue_1
			,aps.venue_2
			,aps.project
			,aps.category
			,aps.trade_checking_date
			,aps.interview_name
			,aps.area_phone_number
			,aps.phone_number
			,aps.trade_checking_result
			,aps.trade_checking_notes
			,cb.bank_name + ' - ' + cb.bank_account_no + ' - ' + cb.bank_account_name 'rekening'
			,@total_amount 'total_amount'
			,@average_amount 'average'
			,@table_name 'table_name'
			,@sp_name 'sp_name'
	from	dbo.application_survey aps
	left join dbo.application_main am on (am.application_no = aps.application_no)
	left join dbo.client_bank cb on (cb.client_code = am.client_code)
	where	aps.application_no = @p_application_no ;
end ;
