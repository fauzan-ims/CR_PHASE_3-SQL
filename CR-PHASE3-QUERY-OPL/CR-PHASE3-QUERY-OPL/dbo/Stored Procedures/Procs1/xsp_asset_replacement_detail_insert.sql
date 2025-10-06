CREATE procedure [dbo].[xsp_asset_replacement_detail_insert]
(
	@p_id				  bigint		 = 0 output
	,@p_replacement_code  nvarchar(50)
	--
	,@p_old_asset_no	  nvarchar(50)
	,@p_new_fa_code		  nvarchar(50)	 = ''
	,@p_new_fa_name		  nvarchar(250)	 = ''
	,@p_new_fa_reff_no_01 nvarchar(50)	 = ''
	,@p_new_fa_reff_no_02 nvarchar(50)	 = ''
	,@p_new_fa_reff_no_03 nvarchar(50)	 = ''
	,@p_replacement_type  nvarchar(20)	 = 'TEMPORARY'
	,@p_reason_code		  nvarchar(50)	 = ''
	,@p_remark			  nvarchar(4000) = ''
	,@p_delivery_address  nvarchar(4000) = ''
	,@p_contact_name	  nvarchar(250)	 = ''
	,@p_contact_phone_no  nvarchar(50)	 = ''
	,@p_reff_no			  nvarchar(50)	 = ''
	--
	,@p_cre_date		  datetime
	,@p_cre_by			  nvarchar(15)
	,@p_cre_ip_address	  nvarchar(15)
	,@p_mod_date		  datetime
	,@p_mod_by			  nvarchar(15)
	,@p_mod_ip_address	  nvarchar(15)
)
as
begin
	declare @msg			   nvarchar(max)
			,@delivery_address nvarchar(4000)
			,@contact_name	   nvarchar(250)
			,@contact_phone_no nvarchar(50) ;

	begin try
		if (@p_replacement_type = 'TEMPORARY')
		begin
			if exists
			(
				select	1
				from	dbo.agreement_asset
				where	asset_no				= @p_old_asset_no
						and isnull(fa_code, '') = ''
			)
			begin
				set @msg = N'Replacement Cannot Proceed For Unit GTS' ;

				raiserror(@msg, 16, -1) ;
			end ;
		end ;

		insert into dbo.asset_replacement_detail
		(
			replacement_code
			,old_asset_no
			,new_fa_code
			,new_fa_name
			,new_fa_ref_no_01
			,new_fa_ref_no_02
			,new_fa_ref_no_03
			,replacement_type
			,reason_code
			,estimate_return_date
			,remark
			,delivery_address
			,contact_name
			,contact_phone_no
			,reff_no
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(
			@p_replacement_code
			,@p_old_asset_no
			,@p_new_fa_code
			,@p_new_fa_name
			,@p_new_fa_reff_no_01
			,@p_new_fa_reff_no_02
			,@p_new_fa_reff_no_03
			,@p_replacement_type
			,@p_reason_code
			,null
			,@p_remark
			,@p_delivery_address
			,@p_contact_name
			,@p_contact_phone_no
			,@p_reff_no
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;

		if (@p_reff_no = '')
		begin
			select	@delivery_address	= deliver_to_address
					,@contact_name		= deliver_to_name
					,@contact_phone_no	= deliver_to_phone_no
			from	dbo.agreement_asset
			where	asset_no = @p_old_asset_no ;

			update	dbo.asset_replacement_detail
			set		delivery_address	= @delivery_address
					,contact_name		= @contact_name
					,contact_phone_no	= @contact_phone_no
			where	id = @p_id ;
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
