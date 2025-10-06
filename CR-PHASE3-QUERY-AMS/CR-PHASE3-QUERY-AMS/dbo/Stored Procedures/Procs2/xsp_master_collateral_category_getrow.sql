CREATE procedure [dbo].[xsp_master_collateral_category_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mcc.code
			,mcc.category_name
			,mcc.collateral_type_code
			,mcc.is_active
			,sgs.description
	from	master_collateral_category mcc
			inner join dbo.sys_general_subcode sgs on (sgs.code = mcc.collateral_type_code)
	where	mcc.code = @p_code ;
end ;


