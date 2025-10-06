
-- Stored Procedure

-- Stored Procedure

CREATE PROCEDURE [dbo].[xsp_proc_asset_lookup_clear]
(
	@p_asset_code	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin TRY

	IF EXISTS
	(
		select	1
		from	ifinopl.dbo.application_asset aa
		inner join ifinopl.dbo.realization_detail rd on rd.asset_no = aa.asset_no
		inner join ifinopl.dbo.realization r on r.code = rd.realization_code
		where	(fa_code = @p_asset_code or replacement_fa_code = @p_asset_code) 
				and r.status <> 'CANCEL'
	)
	begin
		set @msg = 'Unable to clear asset, realization in progress'
		raiserror (@msg, 16, -1)
	end
	else
    begin


		-- sepria 13082025: ganti konsep karena cr priority
		--update	dbo.proc_asset_lookup
		--set		asset_no		= ''
		--		,mod_by			= @p_mod_by
		--		,mod_date		= @p_mod_date
		--		,mod_ip_address = @p_mod_ip_address
		--where	asset_code = @p_asset_code ;

		update	ifinams.dbo.asset
		set		fisical_status			= 'ON HAND'
				,rental_status			= ''
				,agreement_no			= null
				,agreement_external_no	= null
				,client_no				= null
				,client_name			= null
				,asset_no				= null
				,re_rent_status			= null
				--
				,mod_date				= @p_mod_date	  
				,mod_by					= @p_mod_by		  
				,mod_ip_address			= @p_mod_ip_address
		where	code = @p_asset_code ;


	end
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
