CREATE FUNCTION dbo.xfn_register_main_get_realization_service_fee
(
	@p_code nvarchar(50)
)returns decimal(18, 2)
as
begin
	
	declare @return_amount				bigint--decimal(18,2)
			,@realization_service_fee	bigint--decimal(18, 2)

		select	@realization_service_fee	= abs(realization_service_fee) 
		from	dbo.register_main rm
		inner join dbo.register_detail rd on (rd.register_code = rm.code)
		where	rm.code = @p_code
		and rd.service_code in ('PBSPKEUR' , 'PBSPSTN')

	set @return_amount = isnull(@realization_service_fee,0)

	return @return_amount
end
