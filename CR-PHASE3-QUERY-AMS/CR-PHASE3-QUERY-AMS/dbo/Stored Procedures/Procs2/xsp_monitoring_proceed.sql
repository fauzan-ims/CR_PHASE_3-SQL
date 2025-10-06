/*
	Created : Arif 22-02-2023
*/

CREATE PROCEDURE [dbo].[xsp_monitoring_proceed]
(
	@p_code			   nvarchar(50)
	,@p_document_type  nvarchar(50)
	--
	,@p_cre_date			datetime
	,@p_cre_by				nvarchar(15)
	,@p_cre_ip_address		nvarchar(15)
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max) 
			,@fa_code				nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@register_date			datetime
			,@register_code			nvarchar(50)
			,@stnk_no				nvarchar(50)
			,@stnk_tax_date			datetime
			,@stnk_expired_date		datetime
			,@keur_no				nvarchar(50)
			,@keur_date				datetime
			,@keur_expired_date		DATETIME
			,@plat_no				nvarchar(50)
            ,@chassis_no			nvarchar(50)
			,@engine_no				nvarchar(50)
			,@register_remark		nvarchar(4000)
			,@code					nvarchar(50)

	begin try

		select	@branch_code  = value
				,@branch_name = description
		from	dbo.sys_global_param
		where	code = 'HO' ;

		-- select data yang tidak ada di tabel register_main
		select	@fa_code				= ass.code
				--,@branch_code			= ass.branch_code
				--,@branch_name			= ass.branch_name
				,@stnk_no				= av.stnk_no
				,@stnk_tax_date			= av.stnk_tax_date
				,@stnk_expired_date		= av.stnk_expired_date
				,@keur_no				= av.keur_no
				,@keur_date				= av.keur_date
				,@keur_expired_date		= av.keur_expired_date
				,@plat_no				= av.plat_no
				,@chassis_no			= av.chassis_no
				,@engine_no				= av.engine_no
		from	dbo.asset ass
				left join	dbo.asset_vehicle av on (ass.code = av.asset_code)
		where	
		--ass.code not in ( 
		--								select	rm.fa_code from dbo.register_main rm 
		--								where	rm.register_status not in ('PAID','CANCEL')
		--							)
		--and 
			ass.code = @p_code

		-- insert ke register_main
		if(@p_document_type = 'STNK')
		begin
			set @register_date = dbo.xfn_get_system_date()
			set @register_remark = 'Perpanjangan STNK untuk asset' + ' ' + isnull(@fa_code,'') + ' ' + isnull(@plat_no,'') + ' ' + isnull(@chassis_no,'') + ' ' + isnull(@engine_no,'')
					
			exec dbo.xsp_register_main_insert @p_code					= @code output
											  ,@p_branch_code			= @branch_code 
											  ,@p_branch_name			= @branch_name
											  ,@p_register_date			= @register_date
											  ,@p_register_status		= N'HOLD'
											  ,@p_register_process_by	= N'INTERNAL' 
											  ,@p_service_code			= N'PBSPSTN' 
											  ,@p_register_remarks		= @register_remark
											  ,@p_stnk_no				= @stnk_no
											  ,@p_stnk_tax_date			= @stnk_tax_date
											  ,@p_stnk_expired_date		= @stnk_expired_date
											  ,@p_keur_no				= @keur_no
											  ,@p_keur_date				= @keur_date
											  ,@p_keur_expired_date		= @keur_expired_date
											  ,@p_is_reimburse			= '0'
											  --
											  ,@p_fa_code				= @fa_code
											  ,@p_cre_date				= @p_cre_date		
											  ,@p_cre_by				= @p_cre_by			
											  ,@p_cre_ip_address		= @p_cre_ip_address
											  ,@p_mod_date				= @p_mod_date		
											  ,@p_mod_by				= @p_mod_by			
											  ,@p_mod_ip_address		= @p_mod_ip_address
			
		end
		else
		begin

			set @register_date = dbo.xfn_get_system_date()
			set @register_remark = 'Perpanjangan KEUR untuk asset' + ' ' + isnull(@fa_code,'') + ' ' + isnull(@plat_no,'') + ' ' + isnull(@chassis_no,'') + ' ' + isnull(@engine_no,'')

			exec dbo.xsp_register_main_insert @p_code					= @code output
											  ,@p_branch_code			= @branch_code 
											  ,@p_branch_name			= @branch_name
											  ,@p_register_date			= @register_date
											  ,@p_register_status		= N'HOLD'
											  ,@p_register_process_by	= N'INTERNAL' 
											  ,@p_service_code			= N'PBSPKEUR' 
											  ,@p_register_remarks		= @register_remark
											  ,@p_stnk_no				= @stnk_no
											  ,@p_stnk_tax_date			= @stnk_tax_date
											  ,@p_stnk_expired_date		= @stnk_expired_date
											  ,@p_keur_no				= @keur_no
											  ,@p_keur_date				= @keur_date
											  ,@p_keur_expired_date		= @keur_expired_date
											  ,@p_is_reimburse			= '0'
											  --
											  ,@p_fa_code				= @fa_code
											  ,@p_cre_date				= @p_cre_date		
											  ,@p_cre_by				= @p_cre_by			
											  ,@p_cre_ip_address		= @p_cre_ip_address
											  ,@p_mod_date				= @p_mod_date		
											  ,@p_mod_by				= @p_mod_by			
											  ,@p_mod_ip_address		= @p_mod_ip_address
			

		end

		-- langsung proceed
		--select	@register_code =  code
		--from	dbo.register_main
		--where	fa_code = @fa_code 
		--		and register_status = 'HOLD'

		exec dbo.xsp_register_main_proceed	  @p_code					= @code
											  ,@p_cre_date				= @p_cre_date		
											  ,@p_cre_by				= @p_cre_by			
											  ,@p_cre_ip_address		= @p_cre_ip_address
											  ,@p_mod_date				= @p_mod_date		
											  ,@p_mod_by				= @p_mod_by			
											  ,@p_mod_ip_address		= @p_mod_ip_address
		
		
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
