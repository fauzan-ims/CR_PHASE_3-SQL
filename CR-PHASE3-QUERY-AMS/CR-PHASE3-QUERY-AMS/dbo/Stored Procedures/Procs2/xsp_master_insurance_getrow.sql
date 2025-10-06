

CREATE PROCEDURE dbo.xsp_master_insurance_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare	@editable nvarchar(1) = 1

	if exists(select 1 from dbo.master_insurance_coverage where insurance_code = @p_code)
	begin
		set @editable = '0'
	end
    
	if exists(select 1 from dbo.sppa_main where insurance_code = @p_code)
	begin
		set @editable = '0'
	end
    
	select	mi.code
			,insurance_no
			,insurance_name
			,contact_person_name
			,contact_person_area_phone_no
			,contact_person_phone_no
			--,case mi.insurance_type
			--	when 'LIFE' then 'LIFE'
			--	when 'CREDIT' then 'CREDIT'
			--	else 'COLLATERAL'
			--end 'insurance_type'
			,mi.insurance_type
			,tax_file_type
			,tax_file_no
			,tax_file_name
			,tax_file_address
			,insurance_business_unit
			,area_phone_no
			,phone_no
			,area_fax_no
			,fax_no
			,email
			,website
			,is_validate
			,nitku
			,npwp_ho
			,@editable 'editable'
			,mc.currency_code
			,mic.coverage_code
			,mc.coverage_name
	from	master_insurance mi
			left join dbo.master_insurance_coverage mic on (mic.insurance_code = mi.code)
			left join dbo.master_coverage mc on (mc.code = mic.coverage_code)
	where	mi.code = @p_code ;
end ;


