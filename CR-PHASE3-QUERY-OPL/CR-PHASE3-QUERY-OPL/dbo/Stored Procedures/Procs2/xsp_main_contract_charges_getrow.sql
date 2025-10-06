
CREATE PROCEDURE [dbo].[xsp_main_contract_charges_getrow]
(
	@p_id			   bigint
	,@p_main_contract_no nvarchar(50)
)
as
begin
	select	id
			,main_contract_no
			,charges_code
			,dafault_charges_rate
			,dafault_charges_amount
			,calculate_by
			,charges_rate
			,charges_amount
			,ac.new_calculate_by
			,ac.new_charges_rate
			,ac.new_charges_amount
			,mc.description 'charges_desc'
	from	main_contract_charges ac
			inner join dbo.master_charges mc on (mc.code = ac.charges_code)
	where	id				   = @p_id
			and main_contract_no = @p_main_contract_no ;
end ;

