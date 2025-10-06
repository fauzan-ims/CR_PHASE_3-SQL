CREATE function [dbo].[xfn_deviation_check_vehicle_price_truk]
(
	@p_application_no nvarchar(50)
)
returns int
as
begin
	declare @number decimal(18, 2) = 0
			,@result int;

	select	@number = sum(asset_amount) 
	from	dbo.application_asset ast
			inner join ifinopl.dbo.application_asset_vehicle aav on ast.asset_no = aav.asset_no
			inner join dbo.master_vehicle_unit mvu on mvu.code					 = aav.vehicle_unit_code
	where	application_no = @p_application_no 
			and mvu.class_type_name not in ('LIGHT COMMERCIAL VEHCILE - NTR','PASSANGER MPV','PASSANGER SEDAN','PASSANGER SUV') ; 

	if @number is not null
	begin
		if @number > 0
		begin
			set @result = '1' ;
		end ;
		else
		begin
			set @result = '0' ;
		end ;
	end
	else
	begin
		set @result = '0' ;
	end ;
	
	return @result ;
end ;

