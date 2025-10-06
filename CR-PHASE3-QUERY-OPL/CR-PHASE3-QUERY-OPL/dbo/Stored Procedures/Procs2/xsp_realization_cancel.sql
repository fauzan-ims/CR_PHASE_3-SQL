CREATE PROCEDURE dbo.xsp_realization_cancel
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg	   nvarchar(max)
			,@id	   bigint
			,@asset_no nvarchar(50) ;

	begin try
		if exists
		(
			select	1
			from	dbo.realization
			where	code	   = @p_code
					and status = 'HOLD'
		)
		begin
			update	realization
			set		status			= 'CANCEL'
					--
					,mod_date		= @p_mod_date
					,mod_by			= @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	code			= @p_code ;

			if exists
			(
				select	1
				from	dbo.realization_detail
				where	realization_code = @p_code
			)
			begin
				declare realizationdetail cursor fast_forward read_only for
				select	asset_no
				from	dbo.realization_detail
				where	realization_code = @p_code ;

				open realizationDetail ;

				fetch next from realizationDetail
				into @asset_no ;

				while @@fetch_status = 0
				begin
					update	application_asset
					set		realization_code = null
							--
							,mod_date		 = @p_mod_date
							,mod_by			 = @p_mod_by
							,mod_ip_address  = @p_mod_ip_address
					where	asset_no		 = @asset_no ;

					fetch next from realizationDetail
					into @asset_no ;
				end ;

				close realizationDetail ;
				deallocate realizationDetail ;
			end ;
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
