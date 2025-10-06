CREATE PROCEDURE dbo.xsp_plafond_collateral_release
(
	@p_plafond_no	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(250) = '' ;
	begin try
		if exists
		(
			select	1
			from	dbo.document_main
			where	plafond_no = @p_plafond_no
					and plafond_no in
						(
							select	plafond_no
							from	dbo.plafond_main
							where	(plafond_status				   = 'GO LIVE')
									--or	(
									--		agreement_status	   = 'TERMINATE'
									--		and termination_status = 'WO COLL'
									--	)
						)
		)
		begin
			set @msg = 'Plafond can not be release' ;

			raiserror(@msg, 16, 1) ;
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
