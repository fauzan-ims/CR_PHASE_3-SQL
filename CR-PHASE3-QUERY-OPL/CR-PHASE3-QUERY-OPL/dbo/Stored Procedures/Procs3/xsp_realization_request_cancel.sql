CREATE PROCEDURE [dbo].[xsp_realization_request_cancel]
(
	@p_asset_no	nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@id			bigint
			,@remarks		nvarchar(4000)  
			,@purchase_status nvarchar(10) = 'NONE'

	begin try
	  
		begin   
			if exists
			(
				select	1
				from	dbo.application_asset
				where	asset_no	   = @p_asset_no
						and is_request_gts = '1'
			)
			begin
				select	@msg = N'Please Cancel request GTS first for asset : ' + asset_no
				from	dbo.application_asset
				where	asset_no	   = @p_asset_no
						and is_request_gts = '1' ;

				raiserror(@msg, 16, 1) ;

				return ;
			end ;

			if exists
			(
				select	1
				from	dbo.purchase_request
				where	asset_no = @p_asset_no
						and request_status not in ('CANCEL')
			)
			begin
				select	top 1
						@msg = N'Application already in Purchase Request Process, Cancel Purchase ' + case unit_from
																										  when 'RENT' then 'GTS '
																										  else ''
																									  end + N'Request First if Purchase Status is ' + request_status
				from	dbo.purchase_request
				where	asset_no = @p_asset_no
						and request_status not in ('CANCEL')
						order by cre_date desc

				raiserror(@msg, 16, 1) ;

				return ;
			end ; 

			--if exists (select	1
			--	from	dbo.purchase_request
			--	where	asset_no = @p_asset_no
			--			and request_status = 'POST' and unit_from = 'BUY')
			--begin
			--	set @purchase_status = 'DONE'
			--end

			update	dbo.application_asset
			set		purchase_status			= 'NONE'
					,purchase_gts_status	= 'NONE'
					,asset_status			= 'ALLOCATION'
			where	asset_no				= @p_asset_no ;
				 
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

