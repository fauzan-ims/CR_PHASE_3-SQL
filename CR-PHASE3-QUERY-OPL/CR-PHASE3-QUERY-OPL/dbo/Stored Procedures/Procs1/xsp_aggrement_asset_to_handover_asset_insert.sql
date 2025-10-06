CREATE PROCEDURE [dbo].[xsp_aggrement_asset_to_handover_asset_insert]
(
	@p_code			   nvarchar(50)
	,@p_agreement_no   nvarchar(50)
	,@p_date		   nvarchar(50)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@asset_no				nvarchar(50)
			,@branch_code			nvarchar(50)
			,@branch_name			nvarchar(250)
			,@client_name			nvarchar(250)
			,@remark				nvarchar(4000)
			,@fa_name				nvarchar(250)
			,@fa_code				nvarchar(50)
			,@handover_asset_code	nvarchar(50)
			,@handover_address		nvarchar(4000)
			,@handover_phone_area	nvarchar(5)
			,@handover_phone_no		nvarchar(15)
			,@handover_eta_date		datetime 
			,@agreement_external_no	nvarchar(50)
			,@client_no				nvarchar(50)
			,@bbn_location			nvarchar(250)
			,@unit_condition		nvarchar(50)

	begin try
		declare agreementasset cursor fast_forward read_only for
			select	asset_no
					,am.branch_code
					,am.branch_name
					,isnull(aa.fa_code, aa.replacement_fa_code)
					,isnull(aa.fa_name, aa.replacement_fa_name)
					,am.client_name
					,aa.pickup_address
					,aa.pickup_phone_area_no
					,aa.pickup_phone_no
					,am.agreement_external_no
					,am.client_no
					,aa.bbn_location_description
					,aa.asset_condition
			from	agreement_asset aa
					inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
			where	aa.agreement_no	 = @p_agreement_no
					and asset_status = 'RENTED' 

		open agreementAsset ;

		fetch next from agreementAsset
		into @asset_no
			 ,@branch_code
			 ,@branch_name
			 ,@fa_code
			 ,@fa_name
			 ,@client_name
			 ,@handover_address	
			 ,@handover_phone_area
			 ,@handover_phone_no
			 ,@agreement_external_no
			 ,@client_no
			 ,@bbn_location
			 ,@unit_condition

		while @@fetch_status = 0
		begin
			
			set @remark = 'Penarikan Unit Sewa, Stop Billing Untuk Agreement No :  ' + @agreement_external_no + '. dari Asset : ' + @fa_code + ' - ' + @fa_name + '.'

			exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @handover_asset_code output
															 ,@p_branch_code			= @branch_code
															 ,@p_branch_name			= @branch_name
															 ,@p_status					= N'HOLD'  
															 ,@p_transaction_date		= @p_date
															 ,@p_type					= N'PICK UP'
															 ,@p_remark					= @remark
															 ,@p_fa_code				= @fa_code
															 ,@p_fa_name				= @fa_name
															 ,@p_handover_from			= @client_name
															 ,@p_handover_to			= N'INTERNAL'
															 ,@p_handover_address		= @handover_address  
															 ,@p_handover_phone_area	= @handover_phone_area
															 ,@p_handover_phone_no		= @handover_phone_no 
															 ,@p_handover_eta_date		= @handover_eta_date 
															 ,@p_unit_condition			= N''
															 ,@p_reff_no				= @asset_no
															 ,@p_reff_name				= N'STOP BILLING'
															 ,@p_agreement_external_no	= @agreement_external_no
															 ,@p_agreement_no			= @p_agreement_no
															 ,@p_asset_no				= @asset_no
															 ,@p_client_no				= @client_no
															 ,@p_client_name			= @client_name
															 ,@p_bbn_location			= @bbn_location
															 --						 
															 ,@p_cre_date				= @p_cre_date	   
															 ,@p_cre_by					= @p_cre_by		   
															 ,@p_cre_ip_address			= @p_cre_ip_address 
															 ,@p_mod_date				= @p_mod_date	   
															 ,@p_mod_by					= @p_mod_by		   
															 ,@p_mod_ip_address			= @p_mod_ip_address 
			
				update	dbo.agreement_asset
				set		asset_status		= 'TERMINATE'
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	asset_no			= @asset_no ;
				

			fetch next from agreementAsset
			into @asset_no
				 ,@branch_code
				 ,@branch_name
				 ,@fa_code
				 ,@fa_name
				 ,@client_name
				 ,@handover_address	
				 ,@handover_phone_area
				 ,@handover_phone_no
				 ,@agreement_external_no
				 ,@client_no
				 ,@bbn_location
				 ,@unit_condition
		end ;

		close agreementAsset ;
		deallocate agreementAsset ;

		if @msg <> ''
		begin
			raiserror(@msg, 16, 1) ;
		end ;
	end try
	begin catch
		begin -- close cursor
			if cursor_status('global', 'agreementasset') >= -1
			begin
				if cursor_status('global', 'agreementasset') > -1
				begin
					close agreementasset ;
				end ;

				deallocate agreementasset ;
			end ;
		end ;

		if (len(@msg) <> 0)
		begin
			set @msg = 'V' + ';' + @msg ;
		end ;
		else
		begin
			set @msg = 'E;There is an error.' + ';' + error_message() ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;


