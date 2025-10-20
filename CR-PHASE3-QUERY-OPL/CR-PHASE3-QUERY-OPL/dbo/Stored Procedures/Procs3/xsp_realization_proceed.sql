--created by, Rian at 29/05/2023 

CREATE PROCEDURE dbo.xsp_realization_proceed
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
			,@application_no nvarchar(50)
			,@asset_no		 nvarchar(50) ;

	begin try
		select @application_no = application_no from dbo.realization where code = @p_code
		
		--fauzan, soalnya input document realization dipindah ke status on process
		--validasi jika tbo blm di validated
		--if exists
		--(
		--	select	1
		--	from	dbo.realization_doc
		--	where	realization_code	= @p_code
		--			and is_required = '1' and promise_date is null  and isnull(is_received,'')<>'1'
		--)
		--begin
		--	set @msg = N'Please Input Promise Date : ' + (select top 1 sgd.document_name
		--	from	dbo.realization_doc ad
		--			inner join dbo.sys_general_document sgd on (sgd.code = ad.document_code)
		--	where	realization_code	= @p_code
		--			and is_required = '1' and promise_date is null and isnull(ad.is_received,'')<>'1')

		--	raiserror(@msg, 16, -1) ;
		--end ;
	 
		--validasi jika remark tidak di isi
		if exists
		(
			select	1
			from	dbo.realization
			where	code				   = @p_code
					and isnull(remark, '') = ''
		)
		begin
			set @msg = 'Please Insert Remark' ;

			raiserror(@msg, 16, -1) ;
		end ;

		--update status menjadi on process
		update	dbo.realization
		set		status			= 'ON PROCESS'
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

			set @remark_log = 'Realization Proceed : ' + @p_code + ' - ON PROCESS';

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