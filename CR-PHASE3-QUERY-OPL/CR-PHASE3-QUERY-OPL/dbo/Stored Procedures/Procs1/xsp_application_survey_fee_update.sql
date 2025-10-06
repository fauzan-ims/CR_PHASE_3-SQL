CREATE PROCEDURE dbo.xsp_application_survey_fee_update
(
	@p_application_no  nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg						 nvarchar(max)
			,@total_survey				 decimal(18, 2)
			,@fee_paid_amount			 decimal(18, 2)
			,@fee_capitalize_amount		 decimal(18, 2)
			,@fee_reduce_disburse_amount decimal(18, 2)
			,@survey_remark				 nvarchar(250)
			,@currency_code				 nvarchar(3) ;

	begin try
		select	@total_survey = isnull(sum(survey_fee_amount), 0)
		from	dbo.application_survey_request
		where	application_no = @p_application_no
				and survey_status not in
		(
			'HOLD', 'CANCEL'
		) ;

		select	@survey_remark = survey_remarks
				,@currency_code = currency_code
		from	dbo.application_survey_request
		where	application_no = @p_application_no ; 

		if (@total_survey <> 0)
		begin
			if exists
			(
				select	1
				from	application_fee
				where	application_no = @p_application_no
						and fee_code   = 'SRVY'
			)
			begin 
				update	application_fee
				set		default_fee_amount			= @total_survey
						,fee_amount					= @total_survey 
						--
						,mod_date					= @p_mod_date
						,mod_by						= @p_mod_by
						,mod_ip_address				= @p_mod_ip_address
				where	application_no				= @p_application_no
						and fee_code				= 'SRVY' ;
			end ;
			else
			begin
				if not exists
				(
					select	1
					from	dbo.master_fee
					where	code = 'SRVY'
					and is_active = '1'
				)
				begin
					set @msg = 'Please setting SRVY - Survey Fee in Master Fee' ;

					raiserror(@msg, 16, 1) ;
				end ;
				insert into dbo.application_fee
				(
					application_no
					,fee_code
					,default_fee_rate
					,default_fee_amount
					,fee_amount 
					,remarks
					,is_calculated
					,currency_code
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(	@p_application_no
					,'SRVY'
					,0
					,@total_survey
					,@total_survey 
					,'Survey Fee For ' + @survey_remark
					,'1'
					,@currency_code
					--
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				) ;
			end ;
		end ;
		else
		begin
			delete application_fee
			where	application_no = @p_application_no
					and fee_code   = 'SRVY' ;
		end ;
	end try
	Begin catch
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



