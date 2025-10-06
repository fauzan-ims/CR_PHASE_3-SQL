CREATE PROCEDURE [dbo].[xsp_application_pdc_generate_getrow]
(
	@p_application_no nvarchar(50)
)
as
begin
	select	application_no
			,pdc_no_prefix
			,pdc_no_running
			,pdc_no_postfix
			,pdc_frequency_month
			,pdc_count
			,pdc_bank_code
			,pdc_bank_name
			,pdc_first_date
			,pdc_allocation_type
			,sgs.description 'pdc_allocation_desc'
			,pdc_currency_code
			,pdc_value_amount
			,pdc_inkaso_fee_amount
			,pdc_clearing_fee_amount
			,pdc_amount
	from	application_pdc_generate apg
			left join dbo.sys_general_subcode sgs on (sgs.code = apg.pdc_allocation_type)
	where	application_no = @p_application_no ;
end ;

