CREATE PROCEDURE [dbo].[xsp_tbo_document_detail_insert]
(
	@p_id				bigint = 0 output
	,@p_reff_code		NVARCHAR(50)
	,@p_document_code	nvarchar(50)
	,@p_promise_date	datetime
	,@p_is_required		nvarchar(1)
	,@p_is_valid		NVARCHAR(1)
	,@p_is_receveid		NVARCHAR(1)
	,@p_remarks			NVARCHAR(4000)
	,@p_application_no	NVARCHAR(50)
	,@p_tbo_document_id	bigint
	--
	,@p_cre_date		datetime
	,@p_cre_by			nvarchar(15)
	,@p_cre_ip_address	nvarchar(15)
	,@p_mod_date		datetime
	,@p_mod_by			nvarchar(15)
	,@p_mod_ip_address	nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into dbo.tbo_document_detail
		(
		    reff_code,
		    document_code,
		    application_no,
		    tbo_document_id,
		    promise_date,
		    is_required,
		    is_valid,
		    is_received,
		    remarks,
			--
		    cre_date,
		    cre_by,
		    cre_ip_address,
		    mod_date,
		    mod_by,
		    mod_ip_address
		)
		values
		(	@p_reff_code
			,@p_document_code
			,@p_application_no
			,@p_tbo_document_id
			,@p_promise_date
			,@p_is_required
			,@p_is_valid
			,@p_is_receveid
			,@p_remarks
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;

		set @p_id = @@identity ;
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

