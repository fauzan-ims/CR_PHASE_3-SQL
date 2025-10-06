CREATE PROCEDURE dbo.xsp_endorsement_main_proceed 
(
	@p_code					nvarchar(50)
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
	declare @msg							nvarchar(max)
			,@endorsement_payment_amount	decimal(18,2)
			,@endorsement_received_amount	decimal(18,2)
			,@endorsement_type				nvarchar(15)
			,@history_remarks               nvarchar(4000)
			,@endorsement_remarks			nvarchar(4000)
			,@policy_code					nvarchar(50);

	begin try

		select	@endorsement_payment_amount		= endorsement_payment_amount
				,@endorsement_received_amount	= endorsement_received_amount
				,@endorsement_type				= endorsement_type
				,@policy_code					= em.policy_code
				,@history_remarks				= 'Endorsement Approve ' + em.code + ' ' + mi.insurance_name 
		from	dbo.endorsement_main em
				inner join dbo.insurance_policy_main ipm on (ipm.code = em.policy_code)
			    inner join dbo.master_insurance mi on (mi.code = ipm.insurance_code)
		where	em.code	= @p_code

		if exists (select 1 from dbo.endorsement_main where code = @p_code and endorsement_status = 'HOLD')
		begin
			-- nia - 16 Sep 2021 04:28 pm	 : or (2 data olos) and (salah satu lolos)
			if @endorsement_type = 'FN'
			begin
				if @endorsement_payment_amount < 0
				begin
					set @msg = 'Cannot be proceed, Endorsement Payment amount = 0' ;
					raiserror(@msg, 16, -1) ;
				end
				
				if @endorsement_received_amount < 0
				begin
					set @msg = 'Cannot be proceed, Endorsement Payment amount = 0' ;
					raiserror(@msg, 16, -1) ;
				end
			end

			if @endorsement_payment_amount = 0 or @endorsement_received_amount = 0 
			begin
				exec dbo.xsp_endorsement_main_paid @p_code			  = @p_code,    
													@p_mod_date		  = @p_mod_date,
													@p_mod_by		  = @p_mod_by,        
													@p_mod_ip_address = @p_mod_ip_address         
			end
			else
			begin
				update	dbo.endorsement_main 
				set		endorsement_status	= 'ON PROCESS'
						--
						,mod_date			= @p_mod_date		
						,mod_by				= @p_mod_by			
						,mod_ip_address		= @p_mod_ip_address
				where	code				= @p_code	
			end
				exec dbo.xsp_insurance_policy_main_history_insert @p_id					= 0,          
																  @p_policy_code		= @policy_code,          
																  @p_history_date		= @p_mod_date,
																  @p_history_type		= 'ENDORSEMENT ON PROCESS',    
																  @p_policy_status		= 'ACTIVE',              
																  @p_history_remarks	= @history_remarks,    
																  @p_cre_date			= @p_mod_date,
																  @p_cre_by				= @p_mod_by,
																  @p_cre_ip_address		= @p_mod_ip_address,
																  @p_mod_date			= @p_mod_date,
																  @p_mod_by				= @p_mod_by,
																  @p_mod_ip_address		= @p_mod_ip_address	    
			
		end
        else
		begin
		    raiserror('Error data already proceed',16,1) ;
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



