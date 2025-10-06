---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE procedure [dbo].[xsp_master_machinery_subcategory_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mms.code
			,mms.machinery_category_code
			,mmc.description 'machinery_category_name'
			,mms.description
			,mms.is_active
	from	master_machinery_subcategory mms
			inner join dbo.master_machinery_category mmc on (mmc.CODE = mms.MACHINERY_CATEGORY_CODE)
	where	mms.code = @p_code ;
end ;



