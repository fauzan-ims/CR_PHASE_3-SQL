CREATE PROCEDURE dbo.xsp_check_asset_status
(
	@p_asset_no nvarchar(50) = null
)
as
begin
	declare @status nvarchar(250)
			,@msg	nvarchar(max) = '' ;

	--if exists
	--(
	--	select	1
	--	from	asset
	--	where	code	   = @p_asset_no
	--			and status <> 'SOLD'
	--)
	--begin
	--	set @status = 'exists' ;
	--	set @msg = 'Please finish SOLD Process for Asset : ' + @p_asset_no + ' for Release the Document' ;
	--end ;

	select	isnull(@status, '') 'status'
			,@msg 'msg' ;
end ;
