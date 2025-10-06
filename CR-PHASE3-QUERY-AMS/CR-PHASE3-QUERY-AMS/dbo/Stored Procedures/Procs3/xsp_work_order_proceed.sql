CREATE PROCEDURE [dbo].[xsp_work_order_proceed]
(
	@p_code							nvarchar(50)
	--,@p_is_claim_approve			nvarchar(1) = ''
	--,@p_claim_approve_claim_date	datetime	= null
	--
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
begin
	declare @msg					nvarchar(max)
			,@status				nvarchar(20)
			,@maintenance_code		nvarchar(50)
			,@asset_code			nvarchar(50)
			,@claim_type			nvarchar(50)
			,@last_meter			int
            ,@is_reimburse			nvarchar(1)
			,@agreement_no			nvarchar(50)
			,@is_claim_approve		nvarchar(1)
			,@claim_date			datetime

	begin try
		--if @p_is_claim_approve = 'T'
		--	set @p_is_claim_approve = '1' ;
		--else
		--	set @p_is_claim_approve = '0' ;

		select	@status				= wo.status	
				,@maintenance_code	= wo.maintenance_code
				,@asset_code		= wo.asset_code
				,@claim_type		= mtn.service_type
				,@last_meter		= ass.last_meter
				,@is_reimburse		= mtn.is_reimburse
				,@agreement_no		= ass.agreement_no
				,@is_claim_approve	= wo.is_claim_approve
				,@claim_date		= wo.claim_approve_claim_date
		from	dbo.work_order wo
		left join dbo.maintenance mtn on (mtn.code = wo.maintenance_code)
		left join dbo.asset ass on ass.code = mtn.asset_code
		where	wo.code = @p_code ;

		--(+) sepria 28-05-2025: validasi jika di reimburse tp status asset tidak di rental
		if(@is_reimburse = '1' and isnull(@agreement_no,'') = '')
		begin
		    set @msg = N'Work Order Cannot Be Reimburse Because Asset Is Not Leased' ;
			raiserror(@msg, 16, -1) ;
		end

		if (@claim_type = 'CLAIM')
		begin
			if(@is_claim_approve = '0')
			begin
				set @msg = 'Please confirm the claim has been approved by insurance company.';
				raiserror(@msg ,16,-1);
			end
			
			if(@is_claim_approve = '1')
			begin
				if(@claim_date is null)
				begin
					set @msg = 'Please input insurance approve date.';
					raiserror(@msg ,16,-1);
				end
				else
				begin
					if(@claim_date > dbo.xfn_get_system_date())
					begin
						set @msg = 'Insurance Approve date must be lest or equal than system date.';
						raiserror(@msg ,16,-1);
					end
				end
			end


		end
		
		if (@status = 'HOLD')
		BEGIN
				PRINT @p_mod_by
			    update	dbo.work_order
				set		status						= 'ON PROCESS'
						,is_claim_approve			= @is_claim_approve
						,claim_approve_claim_date	= @claim_date
						,proced_by					= @p_mod_by
						,last_meter					= @last_meter
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	code						= @p_code ;
				
				update dbo.asset
				set		wo_no			= @maintenance_code
						,wo_status		= 'ON WORKSHOP'
						--
						,mod_date		= @p_mod_date
						,mod_by			= @p_mod_by
						,mod_ip_address = @p_mod_ip_address
				where	code			= @asset_code ;


				exec dbo.xsp_work_order_approve @p_code = @p_code
												,@p_mod_date = @p_mod_date
												,@p_mod_by = @p_mod_by
												,@p_mod_ip_address = @p_mod_ip_address
				
				
				
		end
		else
		begin
			set @msg = 'Data Already Proceed';
			raiserror(@msg ,16,-1);
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
end ;
