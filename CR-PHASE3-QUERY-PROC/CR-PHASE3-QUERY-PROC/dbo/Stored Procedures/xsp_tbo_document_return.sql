

-- Louis Rabu, 09 Juli 2025 16.01.41 -- 
create PROCEDURE [dbo].[xsp_tbo_document_return]
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@application_no nvarchar(50)
			,@asset_no		 nvarchar(50) ;

	begin try
		select	@application_no = application_no
		from	dbo.tbo_document
		where	id = @p_id ;

		if exists
		(
			select	1
			from	tbo_document
			where	id		   = @p_id
					and status <> 'VERIFICATION'
		)
		begin
			set @msg = N'Data already Proceed' ;

			raiserror(@msg, 16, -1) ;
		end ; 

		--update status menjadi on process
		update	dbo.tbo_document
		set		status			= 'HOLD'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address 
		where	id			= @p_id
		
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
		-- insert application log
		begin
		
			declare @remark_log nvarchar(4000)
					,@id bigint 

			set @remark_log = 'TBO Document Return for Application No : ' + @application_no + ' - HOLD';

			exec dbo.xsp_application_log_insert @p_id				= @id output 
												,@p_application_no	= @application_no
												,@p_log_date		= @p_mod_date
												,@p_log_description	= @remark_log
												,@p_cre_date		= @p_mod_date	  
												,@p_cre_by			= @p_mod_by		  
												,@p_cre_ip_address	= @p_mod_ip_address
												,@p_mod_date		= @p_mod_date	  
												,@p_mod_by			= @p_mod_by		  
												,@p_mod_ip_address	= @p_mod_ip_address
		end
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
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
			if (
				   error_message() like '%V;%'
				   or	error_message() like '%E;%'
			   )
			begin
				set @msg = error_message() ;
			end ;
			else
			begin
				set @msg = 'E;' + dbo.xfn_get_msg_err_generic() + ';' + error_message() ;
			end ;
		end ;

		raiserror(@msg, 16, -1) ;

		return ;
	end catch ;
end ;
