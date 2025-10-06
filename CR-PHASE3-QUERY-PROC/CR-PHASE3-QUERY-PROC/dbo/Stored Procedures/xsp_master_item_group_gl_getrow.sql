--created by, Rian at 17/02/2023 

CREATE PROCEDURE dbo.xsp_master_item_group_gl_getrow
(
	@p_id			 bigint
	,@p_company_code nvarchar(50)
)
as
begin
	select	id
			,mig.company_code
			,item_group_code
			--,currency_code
			--,sc.description	   'currency_name'
			,mig.category
			,gl_asset_code
			,isnull(jgla.gl_link_name, sgs.description)		   'gl_asset_name'
			,gl_expend_code
			,isnull(jgle.gl_link_name,sgs2.description)		   'gl_expend_name'
			,gl_inprogress_code
			,isnull(jgli.gl_link_name, sgs3.description)		   'gl_inprogress_name'
	from	master_item_group_gl		  mig
			--left join dbo.sys_currency	  sc on sc.code					= mig.currency_code
			--									and	 sc.company_code	= mig.company_code
			left join dbo.journal_gl_link jgla on jgla.code				= mig.gl_asset_code
			left join ifinams.dbo.sys_general_subcode sgs on sgs.code	= mig.gl_asset_code
			left join dbo.journal_gl_link jgle on jgle.code				= mig.gl_expend_code
			left join ifinams.dbo.sys_general_subcode sgs2 on sgs2.code	= mig.gl_expend_code
			left join dbo.journal_gl_link jgli on jgli.code				= mig.gl_inprogress_code
			left join ifinams.dbo.sys_general_subcode sgs3 on sgs.code	= mig.gl_inprogress_code
	where	id					 = @p_id
			and mig.company_code = @p_company_code ;
end ;
