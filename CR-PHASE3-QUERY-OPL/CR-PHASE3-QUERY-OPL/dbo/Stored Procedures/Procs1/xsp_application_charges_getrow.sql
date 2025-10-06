CREATE PROCEDURE [dbo].[xsp_application_charges_getrow]
(
	@p_id			   bigint
	,@p_application_no nvarchar(50)
)
as
begin
	select	id
			,application_no
			,charges_code
			,dafault_charges_rate
			,dafault_charges_amount
			,calculate_by
			,charges_rate
			,charges_amount
			,mc.description 'charges_desc'
	from	application_charges ac
			inner join dbo.master_charges mc on (mc.code = ac.charges_code)
	where	id				   = @p_id
			and application_no = @p_application_no ;
end ;

