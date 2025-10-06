CREATE PROCEDURE dbo.xsp_application_main_cancel
(
	@p_application_no	   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max)
			,@id bigint ;

	begin try
		if exists
		(
			select	1
			from	dbo.application_main
			where	application_no			= @p_application_no
					and application_status  = 'HOLD'
		)
		begin
			update	application_main
			set		application_status	= 'CANCEL'
					--
					,mod_date			= @p_mod_date
					,mod_by				= @p_mod_by
					,mod_ip_address		= @p_mod_ip_address
			where	application_no		= @p_application_no ;

			exec dbo.xsp_application_log_insert @p_id = @id output
											,@p_application_no	= @p_application_no
											,@p_log_date		= @p_mod_date
											,@p_log_description	= 'CANCELED'
											,@p_cre_date		= @p_mod_date
											,@p_cre_by			= @p_mod_by
											,@p_cre_ip_address	= @p_mod_ip_address
											,@p_mod_date		= @p_mod_date
											,@p_mod_by			= @p_mod_by
											,@p_mod_ip_address	= @p_mod_ip_address ;


			--for update fixe asset status to Reserved when asset condition is USED
			declare @asset_no				 nvarchar(50)
					,@fa_code				 nvarchar(50)

			declare currapplicationasset cursor fast_forward read_only for
			select	asset_no
					,fa_code
			from	dbo.application_asset
			where	application_no		= @p_application_no
			and		unit_source	= 'STOCK'
					--and asset_condition = 'USED' ;

			open currapplicationasset ;

			fetch next from currapplicationasset
			into @asset_no 
				,@fa_code ;

			while @@fetch_status = 0
			begin

				exec ifinams.dbo.xsp_asset_update_rental_status @p_code				= @fa_code
																,@p_rental_reff_no	= @asset_no
																,@p_rental_status	= null
																,@p_reserved_by		= null
																,@p_is_cancel		= '1'
																,@p_mod_date		= @p_mod_date
																,@p_mod_by			= @p_mod_by
																,@p_mod_ip_address	= @p_mod_ip_address
				
				
				fetch next from currapplicationasset
				into @asset_no 
					,@fa_code ;
			end ;

			close currapplicationasset ;
			deallocate currapplicationasset ;

		end ;
		else
		begin
			raiserror('Data already proceed', 16, 1) ;
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

