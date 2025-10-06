---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_he_subcategory_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mhs.code
			,he_category_code
			,mhc.description 'he_category_name'
			,mhs.description
			,mhs.is_active
	from	master_he_subcategory mhs
			inner join dbo.master_he_category mhc on (mhc.code = mhs.he_category_code)
	where	mhs.code = @p_code ;
end ;


