CREATE PROCEDURE [dbo].[xsp_realization_doc_update]
(
	@p_id			   bigint 
	,@p_promise_date   datetime = null 
	,@p_is_received	   NVARCHAR(1) = '0'
	,@p_is_valid	   NVARCHAR(1)
	,@p_remarks		   NVARCHAR(4000) = ''
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
) 
as
begin
	declare @msg		nvarchar(max) 
			,@asset_no	nvarchar(50) ; 

	begin try
		--if (@p_promise_date is null)
		--begin
		--	set @msg = 'Please fill Promise Date';
		--	raiserror(@msg, 16, -1) ;
		--end   
		
		if (@p_promise_date is not null) and (@p_promise_date <= dbo.xfn_get_system_date())
		begin
			set @msg = 'Promise Date must be greater than System Date';
			raiserror(@msg, 16, -1) ;
		end   

		update	dbo.realization_doc
		set		is_received			= @p_is_received
				,promise_date		= @p_promise_date 
				,remarks			= @p_remarks
				,is_valid			= @p_is_valid
				--
				,mod_date			= @p_mod_date
				,mod_by				= @p_mod_by
				,mod_ip_address		= @p_mod_ip_address
		where	id					= @p_id;  
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

