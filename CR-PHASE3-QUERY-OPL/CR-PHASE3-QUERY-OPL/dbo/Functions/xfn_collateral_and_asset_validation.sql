CREATE FUNCTION dbo.xfn_collateral_and_asset_validation
(
	@p_reff_code nvarchar(50)
)
returns nvarchar(max)
as
begin
	declare @msg					 nvarchar(max) = ''
			,@asset_or_collateral_no nvarchar(50) ;

	if exists
	(
		select	1
		from	dbo.application_main
		where	application_no = @p_reff_code
	)
	begin 
		--asset info
		begin
			if exists
			(
				select	1
				from	dbo.application_asset ac
						inner join dbo.application_asset_machine acm on (
																			acm.asset_no						  = ac.asset_no 
																			and  isnull(acm.machinery_unit_code, '') = ''
																		)
				where	application_no = @p_reff_code
			)
			begin
				select	@msg = 'Asset Info is not Complete ' + ac.asset_no
				from	dbo.application_asset ac
						inner join dbo.application_asset_machine acm on (
																			acm.asset_no						  = ac.asset_no 
																			and  isnull(acm.machinery_unit_code, '') = ''
																		)
				where	application_no = @p_reff_code ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset ac
						inner join dbo.application_asset_he acm on (
																	   acm.asset_no							 = ac.asset_no 
																	   and  isnull(acm.he_unit_code, '') = ''
																   )
				where	application_no = @p_reff_code
			)
			begin
				select	@msg = 'Asset Info is not Complete ' + ac.asset_no
				from	dbo.application_asset ac
						inner join dbo.application_asset_he acm on (
																	   acm.asset_no							 = ac.asset_no 
																	   and  isnull(acm.he_unit_code, '') = ''
																   )
				where	application_no = @p_reff_code ;
			end ;
			--else if exists
			--(
			--	select	1
			--	from	dbo.application_asset ac
			--			inner join dbo.application_asset_furniture acm on (
			--																  acm.asset_no							 = ac.asset_no
			--																  and  isnull(acm.asset_description, '') = ''
			--															  )
			--	where	application_no = @p_reff_code
			--)
			--begin
			--	select	@msg = 'Asset Info is not Complete ' + ac.asset_no
			--	from	dbo.application_asset ac
			--			inner join dbo.application_asset_furniture acm on (
			--																  acm.asset_no							 = ac.asset_no
			--																  and  isnull(acm.asset_description, '') = ''
			--															  )
			--	where	application_no = @p_reff_code ;
			--end ;
			--else if exists
			--(
			--	select	1
			--	from	dbo.application_asset ac
			--			inner join dbo.application_asset_property acm on (
			--																 acm.asset_no							 = ac.asset_no
			--																 and   isnull(acm.asset_description, '') = ''
			--															 )
			--	where	application_no = @p_reff_code
			--)
			--begin
			--	select	@msg = 'Asset Info is not Complete ' + ac.asset_no
			--	from	dbo.application_asset ac
			--			inner join dbo.application_asset_property acm on (
			--																 acm.asset_no							 = ac.asset_no
			--																 and   isnull(acm.asset_description, '') = ''
			--															 )
			--	where	application_no = @p_reff_code ;
			--end ;
			else if exists
			(
				select	1
				from	dbo.application_asset ac
						inner join dbo.application_asset_vehicle acm on (
																			acm.asset_no						  = ac.asset_no 
																	   and  isnull(acm.vehicle_unit_code, '') = ''
																		)
				where	application_no = @p_reff_code
			)
			begin
				select	@msg = 'Asset Info is not Complete ' + ac.asset_no
				from	dbo.application_asset ac
						inner join dbo.application_asset_vehicle acm on (
																			acm.asset_no						  = ac.asset_no 
																	   and  isnull(acm.vehicle_unit_code, '') = ''
																		)
				where	application_no = @p_reff_code ;
			end ;
			else if exists
			(
				select	1
				from	dbo.application_asset ac
						inner join dbo.application_asset_electronic acm on (
																			   acm.asset_no							 = ac.asset_no 
																	   and  isnull(acm.electronic_unit_code, '') = ''
																		   )
				where	application_no = @p_reff_code
			)
			begin
				select	@msg = 'Asset Info is not Complete ' + ac.asset_no
				from	dbo.application_asset ac
						inner join dbo.application_asset_electronic acm on (
																			   acm.asset_no							 = ac.asset_no 
																	   and  isnull(acm.electronic_unit_code, '') = ''
																		   )
				where	application_no = @p_reff_code ;
			end ;
		end ;

		if exists
		(
			select	1
			from	dbo.application_asset_doc aad
					inner join dbo.application_asset aa on (aa.asset_no = aad.asset_no)
			where	application_no		  = @p_reff_code
					and is_required		  = '1'
					and isnull(paths, '') = ''
					and promise_date is null
		)
		begin
			set @msg = 'Application Asset Document is not complete, please upload mandatory Document' ;
		end ; 
	end ; 

	return @msg ;
end ;

