CREATE PROCEDURE dbo.xsp_master_insurance_validate
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg		     nvarchar(max)
	        ,@insurance_type nvarchar(10);

	begin try

		begin
			select @insurance_type = insurance_type
			from dbo.master_insurance
			where code = @p_code

			if not exists
			(
				select	1
				from	dbo.master_insurance_address
				where	insurance_code	= @p_code 
						and is_latest	= '1'
			)
			begin
				set @msg = 'Please input latest address';
				raiserror(@msg, 16, 1) ;
			end ;

			if not exists
			(
				select	1
				from	dbo.master_insurance_bank
				where	insurance_code = @p_code 
						and	is_default = '1'
			)
			begin
				set @msg = 'Please input default bank';
				raiserror(@msg, 16, 1) ;
			end ;

			if not exists
			(
				select	1
				from	dbo.master_insurance_fee
				where	insurance_code = @p_code 
			)
			begin
				set @msg = 'Please input Fee';
				raiserror(@msg, 16, 1) ;
			end ;

			if exists
			(
				select	1
				from	dbo.master_insurance_document
				where	isnull(file_name, '') = ''
						and	insurance_code = @p_code
			)
			begin
				set @msg = 'Please upload document';
				raiserror(@msg, 16, 1) ;
			end ;

			if @insurance_type <> 'LIFE'
			begin
 				if not exists
				(
					select	1
					from	dbo.master_insurance_depreciation
					where	insurance_code = @p_code 
				)
				begin
					set @msg = 'Please input Depreciation';
					raiserror(@msg, 16, 1) ;
				end ;
			end 

			update	dbo.master_insurance
			set		is_validate			= '1'
					--
					,mod_date			= @p_mod_date		
					,mod_by				= @p_mod_by			
					,mod_ip_address		= @p_mod_ip_address
			where	code				= @p_code
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

