---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure [dbo].[xsp_master_electronic_subcategory_getrow]
(
	@p_code nvarchar(50)
)
as
begin
	select	mes.code
			,electronic_category_code
			,mvc.description 'electronic_category_name'
			,mes.description
			,mes.is_active
	from	master_electronic_subcategory mes
			inner join dbo.master_electronic_category mvc on (mvc.code = mes.electronic_category_code)
	where	mes.code = @p_code ;
end ;


