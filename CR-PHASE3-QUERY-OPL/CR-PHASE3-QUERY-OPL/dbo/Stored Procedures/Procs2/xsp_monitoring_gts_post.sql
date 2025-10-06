--created by, Rian at 02/06/2023 

CREATE PROCEDURE dbo.xsp_monitoring_gts_post
(
	@p_asset_no			nvarchar(50)
	--
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare	@msg							nvarchar(max)
			,@code							nvarchar(50)
			,@system_dte					datetime
			,@branch_code					nvarchar(50)
			,@branch_name					nvarchar(250)
			,@agreement_no					nvarchar(50)
			,@id							bigint
			,@fa_code						nvarchar(50)
			,@fa_name						nvarchar(250)
			,@fa_reff_no_01					nvarchar(50)
			,@fa_reff_no_02					nvarchar(50)
			,@fa_reff_no_03					nvarchar(50)
			,@replacement_fa_code			nvarchar(50)
			,@replacement_fa_name			nvarchar(250)
			,@replacement_fa_reff_no_01		nvarchar(50)
			,@replacement_fa_reff_no_02		nvarchar(50)
			,@replacement_fa_reff_no_03		nvarchar(50)
			,@remarks						nvarchar(4000)

	begin try

		select	@agreement_no					= aas.agreement_no
				,@fa_code						= aps.fa_code
				,@fa_name						= aps.fa_name
				,@fa_reff_no_01					= aps.fa_reff_no_01
				,@fa_reff_no_02					= aps.fa_reff_no_02
				,@fa_reff_no_03					= aps.fa_reff_no_03
				,@replacement_fa_code			= aas.replacement_fa_code
				,@replacement_fa_name			= aas.replacement_fa_name
				,@branch_code					= am.branch_code
				,@branch_name					= am.branch_name
				,@replacement_fa_reff_no_01		= aas.replacement_fa_reff_no_01
				,@replacement_fa_reff_no_02		= aas.replacement_fa_reff_no_02
				,@replacement_fa_reff_no_03		= aas.replacement_fa_reff_no_03
		from	dbo.agreement_asset aas
				inner join dbo.agreement_main am on (am.agreement_no  = aas.agreement_no)
				inner join dbo.application_asset aps on (aps.asset_no = aas.asset_no)
		where	aas.asset_no = @p_asset_no ;
		
		set	@system_dte = dbo.xfn_get_system_date()

		-- melakukan insert replacement
		begin
			exec dbo.xsp_asset_replacement_insert @p_code				= @code output
												  ,@p_agreement_no		= @agreement_no
												  ,@p_date				= @system_dte
												  ,@p_branch_code		= @branch_code
												  ,@p_branch_name		= @branch_name
												  ,@p_remark			= 'Replacement For Asset GTS'
												  ,@p_from_monitoring	= '1'
												  --
												  ,@p_cre_date			= @p_mod_date
												  ,@p_cre_by			= @p_mod_by
												  ,@p_cre_ip_address	= @p_mod_ip_address
												  ,@p_mod_date			= @p_mod_date
												  ,@p_mod_by			= @p_mod_by
												  ,@p_mod_ip_address	= @p_mod_ip_address
		
			set @remarks = 'Replacement For Asset GTS : ' + @replacement_fa_code + ' Plat No : ' + @replacement_fa_reff_no_01 + ' Chasis No : ' + @replacement_fa_reff_no_02 + ' Engine No : ' + @replacement_fa_reff_no_03
			exec dbo.xsp_asset_replacement_detail_insert @p_id					= @id output 
														 ,@p_replacement_code	= @code
														 ,@p_old_asset_no		= @p_asset_no
														 ,@p_new_fa_code		= @fa_code
														 ,@p_new_fa_name		= @fa_name
														 ,@p_new_fa_reff_no_01	= @fa_reff_no_01
														 ,@p_new_fa_reff_no_02	= @fa_reff_no_02
														 ,@p_new_fa_reff_no_03	= @fa_reff_no_03
														 ,@p_replacement_type	= 'PERMANENT' 
														 ,@p_reason_code		= 'ARGTS'
														 ,@p_remark				= @remarks
														 --
														 ,@p_cre_date			= @p_mod_date
														 ,@p_cre_by				= @p_mod_by
														 ,@p_cre_ip_address		= @p_mod_ip_address
														 ,@p_mod_date			= @p_mod_date
														 ,@p_mod_by				= @p_mod_by
														 ,@p_mod_ip_address		= @p_mod_ip_address
		end
		
		-- dilakukan setelah insert replacement
		begin
			-- proceed replacement
			exec dbo.xsp_asset_replacement_proceed  @p_code				= @code
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address
			
			-- post replacement
			exec dbo.xsp_asset_replacement_post @p_code				= @code
												,@p_mod_date		= @p_mod_date
												,@p_mod_by			= @p_mod_by
												,@p_mod_ip_address	= @p_mod_ip_address
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
