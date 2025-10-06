--created by, Rian at 17/05/2023 

CREATE procedure dbo.xsp_application_asset_detail_getrow
(
	@p_id		 bigint
	,@p_asset_no nvarchar(50)
)
as
begin
	select	id
			,code
			,asset_no
			,type
			,description
			,amount
	from	dbo.application_asset_detail
	where	asset_no = @p_asset_no
			and id	 = @p_id ;
end ;
