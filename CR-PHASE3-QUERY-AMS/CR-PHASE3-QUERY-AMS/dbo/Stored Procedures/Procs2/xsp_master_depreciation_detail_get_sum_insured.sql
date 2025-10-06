CREATE PROCEDURE [dbo].[xsp_master_depreciation_detail_get_sum_insured]
(
	@p_depreciation_code nvarchar(50)
	,@p_tenor			 int
	,@p_sum_insured		 decimal(18, 2)
)
as
BEGIN
	SET @p_tenor = @p_tenor * 12

	if @p_depreciation_code = ''
	begin
		set @p_depreciation_code = 'TETAP'
	end

	--ini digunakan apabila dari module lain untuk mengambil nilai rate dan suminsured yang tidak menggunakan depreciation
	if (@p_depreciation_code = 'TETAP')
	begin
		select	@p_sum_insured 'sum_insured_amount_from_depreciation'
				,100.00 'rate' ;
	end
	else if exists
	(
		select	1
		from	master_depreciation_detail
		where	depreciation_code = @p_depreciation_code
				and tenor		  = @p_tenor
	)
	begin
		select	cast(((@p_sum_insured * rate) / 100) as decimal(18, 2)) 'sum_insured_amount_from_depreciation'
				,rate
		from	master_depreciation_detail
		where	depreciation_code = @p_depreciation_code
				and tenor		  = @p_tenor ;
	end ;
	else
	begin
		raiserror('V;Depreciation rate setting not found!', 16, 1) ;
	end ;
end ;


