CREATE PROCEDURE dbo.xsp_handover_asset_update
(
	@p_code							nvarchar(50)
	,@p_branch_code					nvarchar(50)
	,@p_branch_name					nvarchar(250)
	,@p_status						nvarchar(10)
	,@p_transaction_date			datetime
	,@p_handover_date				datetime
	,@p_type						nvarchar(20)
	,@p_remark						nvarchar(4000)
	,@p_fa_code						nvarchar(50)
	,@p_handover_from				nvarchar(250)	= ''
	,@p_handover_to					nvarchar(250)	= ''
	,@p_unit_condition				nvarchar(4000)
	,@p_reff_code					nvarchar(50)
	,@p_reff_name					nvarchar(250)
	,@p_process_status				nvarchar(50)	= ''
	,@p_plan_date					datetime		= null
    ,@p_km							int
	,@p_courier						nvarchar(50)	= null
	,@p_pic_handover_name			nvarchar(250)	= null
	,@p_pic_handover_address		nvarchar(4000)	= null
	,@p_pic_handover_phone_area		nvarchar(5)		= null
	,@p_pic_handover_phone_no		nvarchar(15)	= null
	,@p_pic_recipient_name			nvarchar(250)	= null
	,@p_pic_recipient_phone_area	nvarchar(5)		= null
	,@p_pic_recipient_phone_no		nvarchar(15)	= null
	--
	,@p_mod_date		 datetime
	,@p_mod_by			 nvarchar(15)
	,@p_mod_ip_address	 nvarchar(15)
)
as
begin
	declare @msg			nvarchar(max)
			,@condition		nvarchar(50)
			,@km			int

	begin try

		if	(@p_handover_date > dbo.xfn_get_system_date())
		begin
			set	@msg = 'Handover Date must be less than System Date'
			raiserror(@msg, 16, -1) ;
		end
			
		-- Louis Senin, 12 Agustus 2024 14.36.34 -- di tutup karena pengecekan ini pada saat pickup akan bermasalah dan seharusnya tidak digunakan
		--if (@p_handover_date <
		--	(
		--		select	ai.maturity_date
		--		from		ifinopl.dbo.agreement_information ai
		--				inner join ifinopl.dbo.agreement_asset aa on (aa.agreement_no = ai.agreement_no)
		--		where	isnull(fa_code, replacement_fa_code) = @p_fa_code
		--				and asset_status					 = 'RENTED'
		--	)
		--	)
		--begin
		--	select	@msg = N'Handover Date Must be More than or Equal to Maturity Date : ' + convert(nvarchar(15), ai.maturity_date, 103)
		--	from		ifinopl.dbo.agreement_information ai
		--			inner join ifinopl.dbo.agreement_asset aa on (aa.agreement_no = ai.agreement_no)
		--	where	isnull(fa_code, replacement_fa_code) = @p_fa_code
		--			and asset_status					 = 'RENTED' 

		--	raiserror(@msg, 16, -1) ;
		--end ;

		select	@condition	= condition
				,@km		= last_meter
		from	dbo.asset
				inner join dbo.handover_asset on asset.code = handover_asset.fa_code
		where	dbo.handover_asset.code = @p_code ;

		IF (@condition = 'USED') and (@p_km = 0)
		begin
			set	@msg = 'KM must be greater than 0'
			raiserror(@msg, 16, -1) ;
		end
        
		if (@p_km < @km)
		begin
			set	@msg = 'KM must be greater than last KM in asset.'
			raiserror(@msg, 16, -1) ;
		end

		update	handover_asset
		set		branch_code					= @p_branch_code
				,branch_name				= @p_branch_name
				,status						= @p_status
				,transaction_date			= @p_transaction_date
				,handover_date				= @p_handover_date
				,type						= @p_type
				,remark						= @p_remark
				,fa_code					= @p_fa_code
				,handover_from				= @p_handover_from
				,handover_to				= @p_handover_to
				,unit_condition				= @p_unit_condition
				,reff_code					= @p_reff_code
				,reff_name					= @p_reff_name
				,process_status				= @p_process_status
				,plan_date					= @p_plan_date
				,km							= @p_km
				,courier					= @p_courier
				,pic_handover_name			= @p_pic_handover_name		
				,pic_handover_address		= @p_pic_handover_address	
				,pic_handover_phone_area	= @p_pic_handover_phone_area		
				,pic_handover_phone_no		= @p_pic_handover_phone_no	
				,pic_recipient_name			= @p_pic_recipient_name		
				,pic_recipient_phone_area	= @p_pic_recipient_phone_area
				,pic_recipient_phone_no		= @p_pic_recipient_phone_no	
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code					= @p_code ;
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
