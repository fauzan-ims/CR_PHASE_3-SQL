CREATE FUNCTION dbo.xfn_register_main_get_realization_pph
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount				decimal(18,2)
			,@realization_pph			bigint

		select		--@realization_pph	= ceiling(abs(realization_service_fee * realization_service_tax_pph_pct / 100))
					@realization_pph = service_pph_amount
		from		dbo.register_main rm
		inner join	dbo.order_main om on (om.code collate Latin1_General_CI_AS = rm.order_code)
		inner join	dbo.master_public_service mps on mps.code = om.public_service_code
		where		rm.code = @p_code 
					AND mps.TAX_FILE_TYPE = 'P23'
        
	set @return_amount = isnull(@realization_pph,0)

	return @return_amount
end
