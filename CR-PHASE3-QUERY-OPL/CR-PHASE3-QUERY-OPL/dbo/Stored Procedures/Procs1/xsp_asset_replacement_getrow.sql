CREATE PROCEDURE dbo.xsp_asset_replacement_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare @replacement nvarchar(50) ;

	begin
		select	@replacement = count(replacement_type)
		from	dbo.asset_replacement_detail
		where	replacement_code	 = @p_code
				and replacement_type = 'TEMPORARY' 

		select	arm.code
				,arm.agreement_no
				,am.agreement_external_no
				,am.client_name
				,arm.date
				,arm.branch_code
				,arm.branch_name
				,arm.remark
				,arm.status
				,@replacement 'replacement'
		from	asset_replacement arm
				inner join dbo.agreement_main am on (am.agreement_no = arm.agreement_no)
		where	arm.code = @p_code ;
	end ;
end ;
