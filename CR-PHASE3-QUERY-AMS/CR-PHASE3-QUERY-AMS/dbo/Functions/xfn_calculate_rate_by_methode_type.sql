CREATE function dbo.xfn_calculate_rate_by_methode_type
(
	@p_methode_type			nvarchar(20)
	,@p_use_full			int
)
returns decimal(18,2)
as
begin

	declare @rate			decimal(18,2)

	if (@p_methode_type='SL')
	begin
		
		set @rate = (100/@p_use_full) 

	end
	else
	begin
		set @rate = ((100/@p_use_full)*2)
	end

	return @rate
end ;


