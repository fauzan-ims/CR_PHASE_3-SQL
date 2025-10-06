-- Louis Rabu, 09 Juli 2025 16.01.41 -- 
CREATE PROCEDURE dbo.xsp_tbo_document_post
(
	@p_id			   bigint
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg				nvarchar(max)
			,@application_no	nvarchar(50)
			,@asset_no			nvarchar(50) 
			,@transaction_name	NVARCHAR(250)
			,@document_code		NVARCHAR(50)
			,@reff_code			NVARCHAR(50)
			,@is_received		NVARCHAR(1)
			,@is_valid			NVARCHAR(1);

	begin try
		select	@application_no = application_no
				,@reff_code		= transaction_no
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
	 
		--validasi jika tbo blm di validated
		if exists
		(
			select	1
			from	dbo.tbo_document_detail
			where	tbo_document_id				   = @p_id
					and is_valid <> '1' --and is_required = '1'
		)
		begin
			SET @msg = 'Please Complete Validate Document';
			--set @msg = N'Please validate : ' + 
			--(
			--    select stuff((
			--        select	', ' + isnull(sgd.document_name,'')
			--        from	dbo.tbo_document_detail ad
			--        inner join dbo.sys_general_document sgd on sgd.code = ad.document_code
			--        where	ad.REFF_CODE = @reff_code
			--				and isnull(is_valid,'') <> 1
			--        for xml path(''), type
			--    ).value('.', 'nvarchar(max)'), 1, 2, '')   -- buang koma pertama
			--);

			raiserror(@msg, 16, -1) ;
		end ;
		
		-- update checkboc valid dan received
		DECLARE curr_tbodoc cursor fast_forward read_only FOR
        select	tdd.application_no
				,tdd.reff_code
				,td.transaction_name
				,tdd.document_code
				,tdd.is_received
				,tdd.is_valid
		from	dbo.tbo_document_detail tdd
		inner join dbo.tbo_document td on td.id = tdd.tbo_document_id
		where	td.id = @p_id

		OPEN curr_tbodoc;
		
		FETCH next from curr_tbodoc
		into	@application_no
				,@reff_code
				,@transaction_name
				,@document_code	
				,@is_received
				,@is_valid;

		while @@fetch_status = 0
		begin
			
			if (@transaction_name = 'MASTER CONTRACT')
			begin
				update dbo.application_doc
				set		is_received			= @is_received
						,is_valid			= @is_valid
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	application_no		= @application_no
						and document_code	= @document_code
			end
			else
            begin
				update dbo.realization_doc
				set		is_received			= @is_received
						,is_valid			= @is_valid
						--
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	realization_code	= @reff_code
						and document_code	= @document_code

				update	dbo.realization
				set		status = 'DONE'
						,mod_date			= @p_mod_date
						,mod_by				= @p_mod_by
						,mod_ip_address		= @p_mod_ip_address
				where	code	= @reff_code
			end

		FETCH next from curr_tbodoc
			into @application_no
				,@reff_code
				,@transaction_name
				,@document_code	
				,@is_received
				,@is_valid;
		end ;

		close curr_tbodoc ;
		deallocate curr_tbodoc ;

		--update status menjadi on process
		update	dbo.tbo_document
		set		status			= 'POST'
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

			set @remark_log = 'TBO Document Post for Application No : ' + @application_no + ' - POST';

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