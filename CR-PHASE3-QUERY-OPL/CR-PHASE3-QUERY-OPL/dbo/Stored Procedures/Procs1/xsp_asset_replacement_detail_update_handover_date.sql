--created by, Rian at 03/03/2023 

CREATE PROCEDURE dbo.xsp_asset_replacement_detail_update_handover_date
(
	@p_code				nvarchar(50)
	,@p_asset_no		nvarchar(50)
	,@p_handover_date	datetime
	,@p_type			nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare	@msg				nvarchar(max)
			,@asset_no			nvarchar(50)
			,@replacemet_type	nvarchar(50)
			,@new_fa_code		nvarchar(50)
			,@new_fa_name		nvarchar(50)
			,@new_fa_reff_no_01	nvarchar(50)
			,@new_fa_reff_no_02	nvarchar(50)
			,@new_fa_reff_no_03	nvarchar(50)
	begin try

		select	@asset_no			= old_asset_no
				,@replacemet_type	= replacement_type
				,@new_fa_code		= new_fa_code
				,@new_fa_name		= new_fa_name
				,@new_fa_reff_no_01	= new_fa_ref_no_01
				,@new_fa_reff_no_02	= new_fa_ref_no_02
				,@new_fa_reff_no_03	= new_fa_ref_no_03
		from	dbo.asset_replacement_detail
		where	replacement_code	= @p_code ;
	
		if	(@p_type = 'REPLACE IN') --jika type nya replace in maka update old handover date pada asset old
		begin
			update	dbo.asset_replacement_detail
			set		old_handover_in_date	= @p_handover_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
					 
			where	replacement_code = @p_code
			and		old_asset_no = @asset_no
					
		end
		else if(@p_type = 'RETURN OUT') --jika type nya return out maka update old handover date nya pada asset yang lama
		begin
			update	dbo.asset_replacement_detail
			set		old_handover_out_date	= @p_handover_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
					 
			where	replacement_code = @p_code
			and		old_asset_no = @asset_no
		end
		else if (@p_type = 'REPLACE OUT') --jika type nya repace out maka update new handover out date pada asset yang baru
		begin
			update	dbo.asset_replacement_detail
			set		new_handover_out_date	= @p_handover_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	replacement_code		= @p_code
			and		new_fa_code				= @p_asset_no
		end
		else if	(@p_type = 'RETURN IN') --jika type nya return in maka update new handover in date nya pada asse yang baru
		begin
			update	dbo.asset_replacement_detail
			set		new_handover_in_date	= @p_handover_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address 
			where	replacement_code		= @p_code
			and		new_fa_code				= @p_asset_no
		end
		if	(@p_type = 'REPLACE GTS IN') --jika type nya replace gts in maka update old handover date pada asset old
		begin
			update	dbo.asset_replacement_detail
			set		old_handover_in_date	= @p_handover_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
					 
			where	replacement_code = @p_code
			and		old_asset_no = @asset_no
					
		end
		else if (@p_type = 'REPLACE GTS OUT') --jika type nya repace out maka update new handover out date pada asset yang baru
		begin
			update	dbo.asset_replacement_detail
			set		new_handover_out_date	= @p_handover_date
					--
					,mod_date				= @p_mod_date
					,mod_by					= @p_mod_by
					,mod_ip_address			= @p_mod_ip_address
			where	replacement_code		= @p_code
			and		new_fa_code				= @p_asset_no
		end
		
		--logic untuk update status replacement
		if (@replacemet_type IN ('TEMPORARY','MAINTENANCE'))
		begin
			if exists
			(
				select	1
				from	dbo.asset_replacement_detail
				where	replacement_code = @p_code
						and old_handover_in_date is not null
						and new_handover_out_date is not null
			)
			begin
				update	dbo.agreement_asset
				set		replacement_fa_code			= @new_fa_code
						,replacement_fa_name		= @new_fa_name
						,replacement_fa_reff_no_01	= @new_fa_reff_no_01
						,replacement_fa_reff_no_02	= @new_fa_reff_no_02
						,replacement_fa_reff_no_03	= @new_fa_reff_no_03
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	asset_no					= @asset_no
			end

			if exists
			(
				select	1 
				from	dbo.asset_replacement_detail
				where	replacement_code		= @p_code
				and		old_handover_out_date	is not null 
				and		new_handover_in_date	is not null
			)
			begin

				update	dbo.agreement_asset
				set		replacement_fa_code			= null
						,replacement_fa_name		= null
						,replacement_fa_reff_no_01	= null
						,replacement_fa_reff_no_02	= null
						,replacement_fa_reff_no_03	= null
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	asset_no					= @asset_no

				update	dbo.asset_replacement
				set		status	= 'DONE'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address	= @p_mod_ip_address 
				where	code = @p_code

				update	dbo.agreement_asset_replacement_history
				set		is_latest			= '0'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address 
				where	asset_no = @asset_no
			end
		end
		else
		begin
		select	1
				from	dbo.asset_replacement_detail
				where	replacement_code = @p_code
						and old_handover_in_date is not null
						and new_handover_out_date is not null
		
			if exists
			(
				select	1
				from	dbo.asset_replacement_detail
				where	replacement_code = @p_code
						and old_handover_in_date is not null
						and new_handover_out_date is not null
			)
			begin

				update	dbo.agreement_asset
				set		fa_code						= @new_fa_code
						,fa_name					= @new_fa_name
						,fa_reff_no_01				= @new_fa_reff_no_01
						,fa_reff_no_02				= @new_fa_reff_no_02
						,fa_reff_no_03				= @new_fa_reff_no_03
						,replacement_fa_code		= null
						,replacement_fa_name		= null
						,replacement_fa_reff_no_01	= null
						,replacement_fa_reff_no_02	= null
						,replacement_fa_reff_no_03	= null
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address 
				where	asset_no					= @asset_no

				update	dbo.asset_replacement
				set		status			= 'DONE'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address 
				where	code			= @p_code

				update	dbo.agreement_asset_replacement_history
				set		is_latest			= '0'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address	= @p_mod_ip_address 
				where	asset_no = @asset_no

				if exists 
				(
					select	1
					from	dbo.agreement_asset
					where	is_request_gts = '1'
				)
				begin
					update	dbo.agreement_asset
					set		is_request_gts		= '0'
							--
							,mod_date			= @p_mod_date
							,mod_by				= @p_mod_by
							,mod_ip_address		= @p_mod_ip_address 
					where	asset_no			= @asset_no
				end

			end
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
end