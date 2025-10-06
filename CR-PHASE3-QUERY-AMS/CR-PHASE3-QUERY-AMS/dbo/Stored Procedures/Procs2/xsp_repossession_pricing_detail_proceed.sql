CREATE procedure dbo.xsp_repossession_pricing_detail_proceed
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						   nvarchar(max)
			,@pricing_code				   nvarchar(50)
			,@branch_code				   nvarchar(50)
			,@branch_name				   nvarchar(250)
			,@contact_person_name		   nvarchar(250)
			,@contact_person_area_phone_no nvarchar(4)
			,@contact_person_phone_no	   nvarchar(15)
			,@collateral_location		   nvarchar(4000)
			,@collateral_description	   nvarchar(250)
			,@apparaisal_code			   nvarchar(50)
			,@remark					   nvarchar(4000)
			,@transaction_date			   datetime
			,@transaction_remark		   nvarchar(4000) ;

	begin try
		if exists
		(
			select	1
			from	dbo.repossession_pricing_detail
			where	id = @p_id
		)
		begin
			select	@pricing_code = rpd.pricing_code
					,@branch_code = rpc.branch_code
					,@branch_name = rpc.branch_name
					,@collateral_location = rpd.collateral_location
					,@collateral_description = rpd.collateral_description
					,@transaction_date = rpc.transaction_date
					,@transaction_remark = rpc.transaction_remarks
			from	repossession_pricing_detail rpd
					inner join repossession_pricing rpc on rpc.code = rpd.pricing_code
			where	id = @p_id ;

			set @remark = 'Request appraisal for Pricing , Branch : ' + @branch_name + ' - ' + @transaction_remark ;

			update	dbo.repossession_pricing_detail
			set		mod_date = @p_mod_date
					,mod_by = @p_mod_by
					,mod_ip_address = @p_mod_ip_address
			where	id = @p_id ;
		end ;
		else
		begin
			set @msg = 'Data already process' ;

			raiserror(@msg, 16, 1) ;
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
