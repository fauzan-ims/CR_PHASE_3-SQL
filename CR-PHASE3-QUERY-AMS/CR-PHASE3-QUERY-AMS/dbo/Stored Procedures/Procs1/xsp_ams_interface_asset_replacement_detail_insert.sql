
CREATE procedure [dbo].[xsp_ams_interface_asset_replacement_detail_insert]
(
	@p_id					  bigint output
	,@p_replacement_code	  nvarchar(50)
	,@p_old_asset_no		  nvarchar(50)
	,@p_new_fa_code			  nvarchar(50)
	,@p_new_fa_name			  nvarchar(250)
	,@p_new_fa_ref_no_01	  nvarchar(50)
	,@p_new_fa_ref_no_02	  nvarchar(50)
	,@p_new_fa_ref_no_03	  nvarchar(50)
	,@p_replacement_type	  nvarchar(50)
	,@p_reason_code			  nvarchar(50)
	,@p_estimate_return_date  datetime
	,@p_old_handover_in_date  datetime
	,@p_old_handover_out_date datetime
	,@p_new_handover_out_date datetime
	,@p_new_handover_in_date  datetime
	,@p_remark				  nvarchar(4000)
	,@p_ref_no				  nvarchar(50)
	,@p_delivery_address	  nvarchar(4000)
	,@p_contact_name		  nvarchar(250)
	,@p_contact_phone_no	  nvarchar(50)
	--
	,@p_cre_date			  datetime
	,@p_cre_by				  nvarchar(15)
	,@p_cre_ip_address		  nvarchar(15)
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.ams_interface_asset_replacement_detail
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
			,old_handover_in_date
			,old_handover_out_date
			,new_handover_out_date
			,new_handover_in_date
			,remark
			,ref_no
			,delivery_address
			,contact_name
			,contact_phone_no
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
			,@p_new_fa_ref_no_01
			,@p_new_fa_ref_no_02
			,@p_new_fa_ref_no_03
			,@p_replacement_type
			,@p_reason_code
			,@p_estimate_return_date
			,@p_old_handover_in_date
			,@p_old_handover_out_date
			,@p_new_handover_out_date
			,@p_new_handover_in_date
			,@p_remark
			,@p_ref_no
			,@p_delivery_address
			,@p_contact_name
			,@p_contact_phone_no
			--	 
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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
