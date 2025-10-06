-- Louis Selasa, 06 Juni 2023 15.06.48 -- 

CREATE PROCEDURE [dbo].[xsp_realization_proceed_to_legal]
(
	@p_code			   nvarchar(50)
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg			 nvarchar(max)
			,@agreement_no	 nvarchar(50)
			,@application_no nvarchar(50)
			,@asset_no		 nvarchar(50) ;

	begin try

		select @application_no = application_no, @agreement_no = agreement_external_no from dbo.realization where code = @p_code

		--Valiasi jika file tidak di upload
		if exists
		(
			select	1
			from	dbo.realization
			where	code	= @p_code
			and		isnull(agreement_no, '') = '' 
		)
		begin
			set @msg = 'Please Print Contract' ;

			raiserror(@msg, 16, 1) ;
		end

		if exists
		(
			select	1
			from	dbo.realization
			where	code					  = @p_code
					and isnull(file_path, '') = ''
		)
		begin
			set @msg = 'Please Upload Document' ;

			raiserror(@msg, 16, -1) ;
		end ; 
			
		----validasi jika tbo blm di validated
		--if exists
		--(
		--	select	1
		--	from	dbo.application_doc
		--	where	application_no	= @application_no
		--			and is_required = '1' and promise_date is null 
		--)
		--begin
		--	set @msg = N'Please Input Promise Date : ' + (select top 1 sgd.document_name
		--	from	dbo.application_doc ad
		--			inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
		--	where	application_no	= @application_no
		--			and is_required = '1' and promise_date is null)

		--	raiserror(@msg, 16, -1) ;
		--end ;

		--kebutuhan data maintenance
		begin
			exec dbo.xsp_mtn_realization_contract @p_realization_no		= @p_code
													,@p_mod_date	    = @p_mod_date
													,@p_mod_by			= @p_mod_by
													,@p_mod_ip_address	= @p_mod_ip_address
			
		end 

		--update status menjadi on process
		update	dbo.realization
		set		status			= 'VERIFICATION'
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address 
		where	code			= @p_code

		
		-- Louis Selasa, 08 Juli 2025 10.32.39 -- 
		-- insert application log
		begin
		
			declare @remark_log nvarchar(4000)
					,@id bigint 
                    
			set @remark_log = 'Realization Verification Process : ' + @p_code + ' for Agreement : ' + @agreement_no;

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
