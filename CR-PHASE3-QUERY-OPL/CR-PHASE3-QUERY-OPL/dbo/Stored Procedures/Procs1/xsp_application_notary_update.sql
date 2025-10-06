CREATE PROCEDURE dbo.xsp_application_notary_update
(
	@p_id					bigint
	,@p_application_no		nvarchar(50)
	,@p_notary_service_code nvarchar(50)
	,@p_notary_service_name nvarchar(250)
	,@p_fee_admin_amount	decimal(18, 2)
	,@p_fee_bnbp_amount		decimal(18, 2)
	,@p_notary_fee_amount	decimal(18, 2)
	,@p_total_notary_amount decimal(18, 2)
	,@p_remarks				nvarchar(4000)
	--
	,@p_mod_date			datetime
	,@p_mod_by				nvarchar(15)
	,@p_mod_ip_address		nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
	
		if exists (select 1 from application_notary where application_no = @p_application_no and notary_service_code = @p_notary_service_code and id <> @p_id)
		begin
			set @msg = 'Service already exists';
			raiserror(@msg, 16, -1) ;
		end 

		update	application_notary
		set		notary_service_code		= @p_notary_service_code
				,notary_service_name	= @p_notary_service_name
				,fee_admin_amount		= @p_fee_admin_amount
				,fee_bnbp_amount		= @p_fee_bnbp_amount
				,notary_fee_amount		= @p_notary_fee_amount
				,total_notary_amount	= @p_total_notary_amount
				,remarks				= @p_remarks
				--
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id						= @p_id
				and application_no		= @p_application_no ;
				
		exec dbo.xsp_application_notary_fee_update @p_application_no	= @p_application_no
													,@p_mod_date		= @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address
	
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


