CREATE PROCEDURE dbo.xsp_generate_master_getrow
(
	@p_asset_code	nvarchar(50)
)
as
begin
	declare @msg	 nvarchar(max) 
			,@type	 nvarchar(50);


	select @type = type_code 
	from dbo.asset
	where code = @p_asset_code

	if(@type = 'VHCL')
	begin
		select merk_code
				,model_code 
		from  dbo.asset_vehicle
		where asset_code = @p_asset_code
	end
	else if (@type = 'ELCT')
	begin
		select merk_code
				,model_code
		from dbo.asset_electronic
		where asset_code = @p_asset_code
	end
	else if (@type = 'FNTR')
	begin
		select merk_code
				,model_code
		from dbo.asset_furniture
		where asset_code = @p_asset_code
	end
	else if (@type = 'MCHN')
	begin
		select merk_code
				,model_code
		from dbo.asset_machine
		where asset_code = @p_asset_code
	end
end ;
