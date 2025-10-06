--created by, Rian at 17/02/2023 

CREATE PROCEDURE dbo.xsp_master_item_group_getrow
(
	@p_code			 nvarchar(50)
	,@p_company_code nvarchar(50)
)
as
begin
	select	mig.code
			,mig.company_code
			,mig.description
			,mig.group_level
			,mig.parent_code
			,mig.transaction_type
			,mig.is_active
			,sgs.description  'transaction_description'
			,mig2.description 'parent_description'
			,mgl.gl_asset_code
			,mgl.gl_asset_name
			,mgl.gl_asset_rent_code
			,mgl.gl_asset_rent_name
	from	master_item_group				   mig
			left join dbo.sys_general_subcode sgs on sgs.code	 = mig.transaction_type	and sgs.company_code = 'DSF'
			left join dbo.master_item_group   mig2 on mig2.code = mig.parent_code
			left join dbo.master_item_group_gl mgl on (mgl.item_group_code = mig.code)
			left join dbo.journal_gl_link jgl on (jgl.code = mgl.gl_asset_code)
	where	mig.code			 = @p_code
			and mig.company_code = @p_company_code ;
end ;
