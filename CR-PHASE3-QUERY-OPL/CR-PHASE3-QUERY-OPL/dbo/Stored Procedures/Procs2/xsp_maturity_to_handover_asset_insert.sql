
create PROCEDURE [dbo].[xsp_maturity_to_handover_asset_insert]
(
	@p_code			   nvarchar(50)
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
	declare @msg						nvarchar(max)
			,@handover_code				nvarchar(50)
			,@branch_code				nvarchar(50)
			,@branch_name				nvarchar(50)
			,@remark					nvarchar(4000)
			,@fa_code					nvarchar(50)
			,@fa_name					nvarchar(50)
			,@handover_from				nvarchar(50)
			,@unit_condition			nvarchar(50)
			,@reff_no					nvarchar(50)
			,@reff_name					nvarchar(50)
			,@asset_no					nvarchar(50)
			,@handover_address			nvarchar(4000)
			,@handover_phone_area		nvarchar(5)
			,@handover_phone_no			nvarchar(15)
			,@handover_eta_date			datetime
			,@agreement_no				nvarchar(50)
			,@agreement_external_no		nvarchar(50)
			,@client_no					nvarchar(50)
			,@client_name				nvarchar(250)
			,@bbn_location				nvarchar(250)
			,@max_request_handover_days int ;

	begin try
		declare curr_maturity cursor fast_forward read_only for
		select	ma.branch_code
				,ma.branch_name
				,md.asset_no
				,aa.fa_code
				,isnull(aa.fa_name, '')
				,aa.asset_no
				,aa.asset_name
				,aa.asset_condition
				,isnull(aa.pickup_name, am.client_name)
				,isnull(aa.pickup_phone_area_no, '')
				,isnull(aa.pickup_phone_no, '')
				,isnull(aa.pickup_address, '')
				,ma.pickup_date
				,am.agreement_no
				,am.agreement_external_no
				,am.client_no
				,am.client_name
				,aa.bbn_location_description
		from	dbo.maturity ma
				inner join dbo.maturity_detail md on (ma.code		 = md.maturity_code)
				inner join dbo.agreement_asset aa on (aa.asset_no	 = md.asset_no)
				inner join dbo.agreement_main am on (am.agreement_no = aa.agreement_no)
		where   ma.code = @p_code

		open curr_maturity ;

		fetch next from curr_maturity
		into	@branch_code
				,@branch_name
				,@asset_no
				,@fa_code
				,@fa_name
				,@reff_no
				,@reff_name
				,@unit_condition
				,@handover_from
				,@handover_phone_area
				,@handover_phone_no 
				,@handover_address
				,@handover_eta_date 
				,@agreement_no			
				,@agreement_external_no	
				,@client_no				
				,@client_name			
				,@bbn_location			

		while @@fetch_status = 0
		begin
			
			
			set @remark = 'Pengembalian Unit Sewa, Maturity Stop Untuk Agreement No :  ' + @agreement_external_no + '. dari Asset : ' + @fa_code + ' - ' + @fa_name + '.'

			

			exec dbo.xsp_opl_interface_handover_asset_insert @p_code					= @handover_code output
															 ,@p_branch_code			= @branch_code
															 ,@p_branch_name			= @branch_name
															 ,@p_status					= N'HOLD'  
															 ,@p_transaction_date		= @p_cre_date
															 ,@p_type					= N'PICK UP'
															 ,@p_remark					= @remark
															 ,@p_fa_code				= @fa_code
															 ,@p_fa_name				= @fa_name
															 ,@p_handover_from			= @handover_from
															 ,@p_handover_to			= N'INTERNAL'
															 ,@p_handover_address		= @handover_address  
															 ,@p_handover_phone_area	= @handover_phone_area
															 ,@p_handover_phone_no		= @handover_phone_no 
															 ,@p_handover_eta_date		= @handover_eta_date 
															 ,@p_unit_condition			= @unit_condition
															 ,@p_reff_no				= @reff_no
															 ,@p_reff_name				= @reff_name
															 ,@p_agreement_external_no	= @agreement_external_no
															 ,@p_agreement_no			= @agreement_no
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

			fetch next from curr_maturity
			into	@branch_code
					,@branch_name
					,@asset_no
					,@fa_code
					,@fa_name
					,@reff_no
					,@reff_name
					,@unit_condition
					,@handover_from
					,@handover_phone_area
					,@handover_phone_no 
					,@handover_address
					,@handover_eta_date 
					,@agreement_no			
					,@agreement_external_no	
					,@client_no				
					,@client_name			
					,@bbn_location	
		end ;

		close curr_maturity ;
		deallocate curr_maturity ;

		if @msg <> ''
		begin
			raiserror(@msg, 16, 1) ;
		end ;
	end try
	begin catch
		begin -- close cursor
			if cursor_status('global', 'curr_maturity') >= -1
			begin
				if cursor_status('global', 'curr_maturity') > -1
				begin
					close curr_maturity ;
				end ;

				deallocate curr_maturity ;
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

