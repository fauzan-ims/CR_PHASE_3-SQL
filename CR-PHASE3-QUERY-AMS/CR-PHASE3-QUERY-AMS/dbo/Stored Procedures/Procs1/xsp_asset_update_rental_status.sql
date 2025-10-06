CREATE PROCEDURE [dbo].[xsp_asset_update_rental_status]
(
	@p_code			   nvarchar(50)
	,@p_rental_reff_no nvarchar(50) = null
	,@p_rental_status  nvarchar(25) = null
	,@p_reserved_by	   nvarchar(15) = null
	,@p_is_cancel	   nvarchar(1)	= '0' -- (+) Ari 2023-12-01 ket : add jika dicancel dari application
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg	  nvarchar(max)
			,@reff_no nvarchar(50) ;

	begin TRY
	
		if exists
		(
			select	1
			from	dbo.asset
			where	code						   = @p_code
					and isnull(re_rent_status, '') = ''
		)
		begin
			if (isnull(@p_rental_reff_no, '') <> '')
			begin
				if exists
				(
					select	1
					from	dbo.asset
					where	code						  = @p_code
							and rental_reff_no			  <> @p_rental_reff_no
							and isnull(rental_status, '') <> ''
							and isnull(@p_is_cancel, '0') <> '1' -- (+) Ari 2023-12-01 ket : jika dicancel dari apk, tidak perlu kena validasi
							
				)
				begin
					set @msg = N'Assets have been Reserved' ;

					raiserror(@msg, 16, 1) ;
				end ;
			end ;

			--set @reff_no = @p_rental_reff_no ;
			
			--if exists
			--(
			--	select	1
			--	from	dbo.asset
			--	where	code			   = @p_code
			--			and rental_reff_no = @p_rental_reff_no
			--)
			--begin
			--	set @reff_no = null ;
			--end ;

			update	asset
			set		rental_status		= @p_rental_status
					,rental_reff_no		= @p_rental_reff_no
					,reserved_by		= @p_reserved_by
					--					
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code 
			--and	rental_reff_no		= @reff_no ;

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
			set @msg = N'V' + N';' + @msg ;
		end ;
		else
		begin
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
