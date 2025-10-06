CREATE PROCEDURE dbo.xsp_asset_and_collateral_validate
(
	@p_reff_no nvarchar(50)
)
as
begin
	declare @msg   nvarchar(max)
			,@type nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.plafond_collateral pc
			where	pc.plafond_code = @p_reff_no
		)
		begin
			select	@type = pc.collateral_type_code
			from	dbo.plafond_collateral pc
			where	pc.plafond_code = @p_reff_no ;

			if exists
			(
				select	1
				from	dbo.plafond_collateral_vehicle pcv
						inner join plafond_collateral pc on (pc.collateral_no = pcv.collateral_no)
				where	pc.plafond_code				   = @p_reff_no
						and pcv.collateral_description = ''
						and pc.collateral_type_code	   = @type
			)
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.plafond_collateral_property pcp
							inner join plafond_collateral pc on (pc.collateral_no = pcp.collateral_no)
					 where	pc.plafond_code				   = @p_reff_no
							and pcp.collateral_description = ''
							and pc.collateral_type_code	   = @type
				 )
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.plafond_collateral_he pch
							inner join plafond_collateral pc on (pc.collateral_no = pch.collateral_no)
					 where	pc.plafond_code				   = @p_reff_no
							and pch.collateral_description = ''
							and pc.collateral_type_code	   = @type
				 )
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.plafond_collateral_machine pcm
							inner join plafond_collateral pc on (pc.collateral_no = pcm.collateral_no)
					 where	pc.plafond_code				   = @p_reff_no
							and pcm.collateral_description = ''
							and pc.collateral_type_code	   = @type
				 )
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_asset aa
			where	aa.application_no = @p_reff_no
		)
		begin
			select	@type = aa.asset_type_code
			from	dbo.application_asset aa
			where	aa.application_no = @p_reff_no ;
			if exists
			(
				select	1
				from	dbo.application_asset_vehicle aav
						inner join application_asset aa on (aa.asset_no = aav.asset_no)
				where	aa.application_no		  = @p_reff_no 
						and aa.asset_type_code	  = @type
			)
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_asset_property aap
							inner join application_asset aa on (aa.asset_no = aap.asset_no)
					 where	aa.application_no		  = @p_reff_no
							and aap.asset_description = ''
							and aa.asset_type_code	  = @type
				 )
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_asset_he aah
							inner join application_asset aa on (aa.asset_no = aah.asset_no)
					 where	aa.application_no		  = @p_reff_no 
							and aa.asset_type_code	  = @type
				 )
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_asset_machine aam
							inner join application_asset aa on (aa.asset_no = aam.asset_no)
					 where	aa.application_no		  = @p_reff_no 
							and aa.asset_type_code	  = @type
				 )
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_asset_electronic aae
							inner join application_asset aa on (aa.asset_no = aae.asset_no)
					 where	aa.application_no		  = @p_reff_no 
							and aa.asset_type_code	  = @type
				 )
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_asset_furniture aaf
							inner join application_asset aa on (aa.asset_no = aaf.asset_no)
					 where	aa.application_no		  = @p_reff_no
							and aaf.asset_description = ''
							and aa.asset_type_code	  = @type
				 )
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_asset_others aao
							inner join application_asset aa on (aa.asset_no = aao.asset_no)
					 where	aa.application_no	   = @p_reff_no
							and aao.remarks		   = ''
							and aa.asset_type_code = @type
				 )
			begin
				set @msg = 'Asset Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
		else if exists
		(
			select	1
			from	dbo.application_collateral ac
			where	ac.application_no = @p_reff_no
		)
		begin
			select	@type = ac.collateral_type_code
			from	dbo.application_collateral ac
			where	ac.application_no = @p_reff_no ;

			if exists
			(
				select	1
				from	dbo.application_collateral_vehicle acv
						inner join application_collateral ac on (ac.collateral_no = acv.collateral_no)
				where	ac.application_no			   = @p_reff_no
						and acv.collateral_description = ''
						and ac.collateral_type_code	   = @type
			)
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_collateral_property acp
							inner join application_collateral ac on (ac.collateral_no = acp.collateral_no)
					 where	ac.application_no			   = @p_reff_no
							and acp.collateral_description = ''
							and ac.collateral_type_code	   = @type
				 )
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_collateral_he ach
							inner join application_collateral ac on (ac.collateral_no = ach.collateral_no)
					 where	ac.application_no			   = @p_reff_no
							and ach.collateral_description = ''
							and ac.collateral_type_code	   = @type
				 )
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
			else if exists
				 (
					 select 1
					 from	dbo.application_collateral_machine acm
							inner join application_collateral ac on (ac.collateral_no = acm.collateral_no)
					 where	ac.application_no			   = @p_reff_no
							and acm.collateral_description = ''
							and ac.collateral_type_code	   = @type
				 )
			begin
				set @msg = 'Collateral Info is not complete' ;

				raiserror(@msg, 16, 1) ;
			end ;
		end ;
	end try
	begin catch
		declare @error int ;

		set @error = @@error ;

		if (@error = 2627)
		begin
			set @msg = dbo.xfn_get_msg_err_code_already_exist() ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			if (error_message() like '%V;%' or error_message() like '%E;%')
			begin
				set @msg = error_message() ;
			end
			else 
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ; 
end ;
