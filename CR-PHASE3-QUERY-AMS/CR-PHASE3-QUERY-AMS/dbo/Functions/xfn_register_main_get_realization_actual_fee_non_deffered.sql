CREATE FUNCTION dbo.xfn_register_main_get_realization_actual_fee_non_deffered
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount				decimal(18,2)
			,@realization_actual_fee	decimal(18, 2)
		
		if not exists (select 1 from dbo.register_detail where service_code in ('PBSPKEUR' , 'PBSPSTN') and register_code = @p_code)
		BEGIN
			SELECT	@realization_actual_fee	= ABS(realization_actual_fee) 
			FROM	dbo.register_main rm
			INNER JOIN dbo.register_detail rd ON (rd.register_code = rm.code)
			WHERE	rm.code = @p_code
			AND rd.service_code NOT IN ('PBSPKEUR' , 'PBSPSTN')
		END

	set @return_amount = isnull(@realization_actual_fee,0)

	return @return_amount
end
