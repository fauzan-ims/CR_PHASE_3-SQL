CREATE PROCEDURE dbo.xsp_doc_interface_agreement_collateral_vehicle_update
(
	@p_id					  bigint
	,@p_agreement_no		  nvarchar(50)
	,@p_collateral_no		  nvarchar(50)
	,@p_plafond_no			  nvarchar(50)
	,@p_plafond_collateral_no nvarchar(50)
	,@p_remarks				  nvarchar(4000)
	,@p_bpkb_no				  nvarchar(50)
	,@p_bpkb_date			  datetime
	,@p_bpkb_name			  nvarchar(250)
	,@p_bpkb_address		  nvarchar(4000)
	,@p_stnk_name			  nvarchar(250)
	,@p_stnk_exp_date		  datetime
	,@p_stnk_tax_date		  datetime
	--
	,@p_mod_date			  datetime
	,@p_mod_by				  nvarchar(15)
	,@p_mod_ip_address		  nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		update	doc_interface_agreement_collateral_vehicle
		set		agreement_no			= @p_agreement_no
				,collateral_no			= @p_collateral_no
				,plafond_no				= @p_plafond_no
				,plafond_collateral_no	= @p_plafond_collateral_no
				,remarks				= @p_remarks
				,bpkb_no				= @p_bpkb_no
				,bpkb_date				= @p_bpkb_date
				,bpkb_name				= @p_bpkb_name
				,bpkb_address			= @p_bpkb_address
				,stnk_name				= @p_stnk_name
				,stnk_exp_date			= @p_stnk_exp_date
				,stnk_tax_date			= @p_stnk_tax_date
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id ;
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
