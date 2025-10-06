CREATE procedure dbo.xsp_all_sys_general_validation
(
	@p_code			  nvarchar(50)
	,@p_movement_code nvarchar(50)
)
as
begin
	declare @asset_no nvarchar(50) ;

	select top 1
			@asset_no = dm.asset_no
	from	dbo.document_movement dmm
			inner join dbo.document_movement_detail dmd on (dmd.MOVEMENT_CODE = dmm.CODE)
			inner join dbo.document_main dm on (dm.code						  = dmd.document_code)
	where	dmm.code = @p_movement_code ;

	select  
			sgv.id 'id'
			,sgv.code 'code'
			,sgv.api_name 'api_name'
			,@asset_no 'asset_no'
	from	dbo.sys_general_validation sgv
	where	sgv.code		  = @p_code
			and sgv.is_active = '1' ;
end ;
