CREATE PROCEDURE dbo.xsp_master_coverage_getrow
(
	@p_code nvarchar(50)
)
as
begin
	declare @editable nvarchar(1) = 1 ;

	if exists
	(
		select	1
		from	dbo.endorsement_period
		where	coverage_code = @p_code
	)
	begin
		set @editable = '0' ;
	end ;

	if exists
	(
		select	1
		from	dbo.insurance_policy_main_period
		where	coverage_code = @p_code
	)
	begin
		set @editable = '0' ;
	end ;

	if exists
	(
		select	1
		from	dbo.insurance_register_period
		where	coverage_code = @p_code
	)
	begin
		set @editable = '0' ;
	end ;

	if exists
	(
		select	1
		from	dbo.master_insurance_coverage
		where	coverage_code = @p_code
	)
	begin
		set @editable = '0' ;
	end ; 

	if exists
	(
		select	1
		from	dbo.master_insurance_rate_non_life
		where	coverage_code = @p_code
	)
	begin
		set @editable = '0' ;
	end ;

	select	code
			,coverage_name
			,coverage_short_name
			,is_main_coverage
			,insurance_type
			,currency_code
			,is_active
			,@editable 'editable'
	from	master_coverage
	where	code = @p_code ;
end ;
