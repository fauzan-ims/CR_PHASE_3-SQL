/*
	ALTERd : Yunus Muslim, 27 Mei 2020
*/
CREATE PROCEDURE dbo.xsp_sys_client_negative_and_warning_matching
(
	@p_client_type						nvarchar(10)
	,@p_personal_nationality_type_code	nvarchar(3)
	,@p_personal_doc_type_code			nvarchar(50)
	,@p_personal_id_no					nvarchar(50)
	,@p_personal_name					nvarchar(250)
	,@p_personal_alias_name				nvarchar(250)
	,@p_personal_mother_maiden_name		nvarchar(250)
	,@p_personal_dob					datetime
	,@p_corporate_name					nvarchar(250)
	,@p_corporate_tax_file_no			nvarchar(50)
	,@p_corporate_est_date				datetime
	,@p_status							nvarchar(1) output
)
as
begin
	declare @msg				nvarchar(max)					
			,@blacklist_type	nvarchar(10);

	begin try		
		if @p_client_type = 'PERSONAL'
		begin
		
			select	@blacklist_type					= blacklist_type 
			from	dbo.client_blacklist 
			where	personal_nationality_type_code	= @p_personal_nationality_type_code 
			and		personal_doc_type_code			= @p_personal_doc_type_code
			and		personal_id_no					= @p_personal_id_no
			and		personal_name					= @p_personal_name
			and		personal_alias_name				= @p_personal_alias_name
			and		personal_mother_maiden_name		= @p_personal_mother_maiden_name
			and		personal_dob					= @p_personal_dob
			and		is_active						= '1'
		
			if isnull(@blacklist_type,'') <> ''
			begin
				if @blacklist_type = 'NEGATIVE'
			    begin
					set @p_status = 1 ; 
			    end
				else
				begin
					set @p_status = 2 ;
				end
			end
			else
			begin
				set @p_status = 0 ;
			end
		end
		else
		begin
		    
			select	@blacklist_type			= blacklist_type 
			from	dbo.client_blacklist 
			where	corporate_name			= @p_corporate_name
			and		corporate_tax_file_no	= @p_corporate_tax_file_no
			and		corporate_est_date		= @p_corporate_est_date
			and		is_active				= '1'
			
			if isnull(@blacklist_type,'') = ''
			begin
				if @blacklist_type = 'NEGATIVE'
			    begin
					set @p_status = 1 ; 
			    end
				else
				begin
					set @p_status = 2 ;
				end			    
			end
			else
			begin
			    set @p_status = 0 ;
			end
		end
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

