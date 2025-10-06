create FUNCTION dbo.xfn_duplicate_collateral_and_asset_validation
(
	@p_reff_code				 nvarchar(50) = null
	,@p_reff_id					 bigint		  = null
	,@p_collateral_no			 nvarchar(50) = null
	,@p_asset_no				 nvarchar(50) = null
	,@p_asset_or_collateral_type nvarchar(10) = null
	,@p_chassis_no				 nvarchar(50) = null
	,@p_engine_no				 nvarchar(50) = null
	,@p_certificate_no			 nvarchar(50) = null
)
returns nvarchar(max)
as
begin
	declare @msg nvarchar(max) = '' ;

	if exists
	(
		select	1
		from	dbo.application_main
		where	application_no = @p_reff_code
	)
	begin
		if (@p_asset_or_collateral_type = 'VHCL')
		begin
			if (@p_asset_no <> null)
			begin
				if exists
				(
					select	1
					from	application_asset_vehicle aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	  aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_asset_vehicle aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	  aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_vehicle aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	engine_no			  = @p_engine_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_vehicle aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	chassis_no			  = @p_chassis_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;
			end ;
			else
			begin
				if exists
				(
					select	1
					from	application_collateral_vehicle aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	engine_no			  = @p_engine_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_vehicle aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	chassis_no			  = @p_chassis_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'HE')
		begin
			if (@p_asset_no <> null)
			begin
				if exists
				(
					select	1
					from	application_asset_he aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	  aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_asset_he aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	  aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_he aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	engine_no			  = @p_engine_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_he aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	chassis_no			  = @p_chassis_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;
			end ;
			else
			begin
				if exists
				(
					select	1
					from	application_collateral_he aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	engine_no			  = @p_engine_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_he aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	chassis_no			  = @p_chassis_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'MCHN')
		begin
			if (@p_asset_no <> null)
			begin
				if exists
				(
					select	1
					from	application_asset_machine aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	 aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_asset_machine aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	 aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_machine aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	engine_no			  = @p_engine_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_machine aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	chassis_no			  = @p_chassis_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;
			end ;
			else
			begin
				if exists
				(
					select	1
					from	application_collateral_machine aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	engine_no			  = @p_engine_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Engine No ' + @p_engine_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_machine aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	chassis_no			  = @p_chassis_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
				end ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'PROP')
		begin
			if (@p_asset_no <> null)
			begin
				if exists
				(
					select	1
					from	application_asset_property aav
							inner join dbo.application_asset aa on (aa.asset_no = aav.asset_no)
					where	certificate_no		  = @p_certificate_no
							and aav.asset_no	  <> @p_asset_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Certificate No ' + @p_certificate_no ;
				end ;

				if exists
				(
					select	1
					from	application_collateral_property aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	certificate_no		  = @p_certificate_no
							and aa.asset_no is null
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Certificate No ' + @p_certificate_no ;
				end ;
			end ;
			else
			begin
				if exists
				(
					select	1
					from	application_collateral_property aav
							inner join dbo.application_collateral aa on (aa.collateral_no = aav.collateral_no)
					where	certificate_no		  = @p_certificate_no
							and aav.collateral_no <> @p_collateral_no
							and aa.application_no = @p_reff_code
				)
				begin
					set @msg = 'Duplicate Certificate No ' + @p_certificate_no ;
				end ;
			end ;
		end ;
	end ;
	else if exists
	(
		select	1
		from	dbo.plafond_main
		where	code = @p_reff_code
	)
	begin
		if (@p_asset_or_collateral_type = 'VHCL')
		begin
			if exists
			(
				select	1
				from	plafond_collateral_vehicle aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	engine_no			  = @p_engine_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Engine No ' + @p_engine_no ;
			end ;

			if exists
			(
				select	1
				from	plafond_collateral_vehicle aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	chassis_no			  = @p_chassis_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'HE')
		begin
			if exists
			(
				select	1
				from	plafond_collateral_he aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	engine_no			  = @p_engine_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Engine No ' + @p_engine_no ;
			end ;

			if exists
			(
				select	1
				from	plafond_collateral_he aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	chassis_no			  = @p_chassis_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'MCHN')
		begin
			if exists
			(
				select	1
				from	plafond_collateral_machine aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	engine_no			  = @p_engine_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Engine No ' + @p_engine_no ;
			end ;

			if exists
			(
				select	1
				from	plafond_collateral_machine aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	chassis_no			  = @p_chassis_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'PROP')
		begin
			if exists
			(
				select	1
				from	plafond_collateral_property aav
						inner join dbo.plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	certificate_no		  = @p_certificate_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_code	  = @p_reff_code
			)
			begin
				set @msg = 'Duplicate Certificate No ' + @p_certificate_no ;
			end ;
		end ;
	end ;
	else
	begin
		if (@p_asset_or_collateral_type = 'VHCL')
		begin
			if exists
			(
				select	1
				from	adjustment_plafond_collateral_vehicle aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	engine_no			  = @p_engine_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Engine No ' + @p_engine_no ;
			end ;

			if exists
			(
				select	1
				from	adjustment_plafond_collateral_vehicle aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	chassis_no			  = @p_chassis_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'HE')
		begin
			if exists
			(
				select	1
				from	adjustment_plafond_collateral_he aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	engine_no			  = @p_engine_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Engine No ' + @p_engine_no ;
			end ;

			if exists
			(
				select	1
				from	adjustment_plafond_collateral_he aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	chassis_no			  = @p_chassis_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'MCHN')
		begin
			if exists
			(
				select	1
				from	adjustment_plafond_collateral_machine aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	engine_no			  = @p_engine_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Engine No ' + @p_engine_no ;
			end ;

			if exists
			(
				select	1
				from	adjustment_plafond_collateral_machine aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	chassis_no			  = @p_chassis_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Chasis No ' + @p_chassis_no ;
			end ;
		end ;
		else if (@p_asset_or_collateral_type = 'PROP')
		begin
			if exists
			(
				select	1
				from	adjustment_plafond_collateral_property aav
						inner join dbo.adjustment_plafond_collateral aa on (aa.collateral_no = aav.collateral_no)
				where	certificate_no		  = @p_certificate_no
						and aav.collateral_no <> @p_collateral_no
						and aa.plafond_id	  = @p_reff_id
			)
			begin
				set @msg = 'Duplicate Certificate No ' + @p_certificate_no ;
			end ;
		end ;
	end ;

	return @msg ;
end ;

