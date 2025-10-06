CREATE PROCEDURE dbo.xsp_repossession_pricing_detail_update
(
	@p_id							   bigint
	,@p_pricing_code				   nvarchar(50)		= null
	,@p_request_amount				   decimal(18, 2)	= null
	,@p_approve_amount				   decimal(18, 2)	= null
	,@p_contact_person_name			   nvarchar(250)	= null
	,@p_contact_person_area_phone_no   nvarchar(4)		= null
	,@p_contact_person_phone_no		   nvarchar(15)		= null
	,@p_collateral_location			   nvarchar(4000)	= null
	,@p_collateral_description		   nvarchar(250)	= null
	--
	,@p_mod_date					   datetime
	,@p_mod_by						   nvarchar(15)
	,@p_mod_ip_address				   nvarchar(15)
)
as
begin
	declare @msg					   nvarchar(max) 
			,@status				   nvarchar(10)
			,@repossession_code		   nvarchar(50);

	begin try
		if (@p_request_amount <= 0)
		begin
			set @msg = 'Request amount must be greater than 0';
			raiserror(@msg ,16,-1)
		end

		select	@repossession_code	= rpd.asset_code
		from	repossession_pricing_detail rpd
				inner join repossession_main rmn on rmn.code = rpd.asset_code 
		where	id					= @p_id

		if exists (	select 1 
					from	dbo.repossession_pricing_detail rpd
							inner join repossession_pricing rpc on rpc.code = rpd.pricing_code
					where	rpd.asset_code = @repossession_code 
							and rpc.transaction_status = 'ON PROCESS')
		begin
			if (@p_approve_amount <= 0)
			begin
				set @msg = 'Approve amount must be greater than 0';
				raiserror(@msg ,16,-1)
			end

			if (@p_approve_amount < @p_request_amount)
			begin
				set @msg = 'Approve amount must be greater or equal than Request Amount';
				raiserror(@msg ,16,-1)
			end
		end

		update	repossession_pricing_detail
		set		request_amount					= @p_request_amount
				,approve_amount					= @p_approve_amount		
				,collateral_location			= @p_collateral_location			
				,collateral_description			= @p_collateral_description			
				--
				,mod_date						= @p_mod_date
				,mod_by							= @p_mod_by
				,mod_ip_address					= @p_mod_ip_address
		where	id								= @p_id ;
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
