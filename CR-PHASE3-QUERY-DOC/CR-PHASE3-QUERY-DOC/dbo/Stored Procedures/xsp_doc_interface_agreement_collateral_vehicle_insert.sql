CREATE PROCEDURE dbo.xsp_doc_interface_agreement_collateral_vehicle_insert
(
	@p_id					  bigint = 0 output
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
		insert into doc_interface_agreement_collateral_vehicle
		(
			agreement_no
			,collateral_no
			,plafond_no
			,plafond_collateral_no
			,remarks
			,bpkb_no
			,bpkb_date
			,bpkb_name
			,bpkb_address
			,stnk_name
			,stnk_exp_date
			,stnk_tax_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_agreement_no
			,@p_collateral_no
			,@p_plafond_no
			,@p_plafond_collateral_no
			,@p_remarks
			,@p_bpkb_no
			,@p_bpkb_date
			,@p_bpkb_name
			,@p_bpkb_address
			,@p_stnk_name
			,@p_stnk_exp_date
			,@p_stnk_tax_date
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
