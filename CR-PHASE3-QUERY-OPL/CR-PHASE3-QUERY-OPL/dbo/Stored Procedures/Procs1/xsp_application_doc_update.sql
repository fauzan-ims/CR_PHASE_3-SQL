CREATE PROCEDURE [dbo].[xsp_application_doc_update]
(
	@p_id			   bigint
	,@p_received_date  datetime   = null
	,@p_promise_date   datetime	   = null
	,@p_is_tbo		   nvarchar(1) = '0'
	,@p_is_received	   nvarchar(1) = '0'
	,@p_is_valid	   nvarchar(1)
	,@p_remarks_doc	   nvarchar(4000) = '' -- 03092025: ini parameternya diganti dari @p_remark, karena sama dengan remark di header. butuh set param yg sama di angular ya Raffyanda
	--
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;


        DECLARE @doc_code nvarchar(50), @doc_name nvarchar(100), @is_required nvarchar(1)


		--SELECT 
		--@doc_code = ad.document_code,
		--@is_required = CASE ad.is_required WHEN '1' THEN '*' ELSE '' END,
		--@doc_name = sgd.document_name
		--FROM application_doc ad
		--INNER JOIN sys_general_document sgd ON sgd.code = ad.document_code
		--WHERE ad.id = @p_id;



	BEGIN TRY 
		BEGIN
		IF @p_promise_date is not null and isnull(@p_is_received,'') = '1' --sepria 03092025
		begin
			raiserror ('Cannot Promise And Receive Documents At The Same Time, Please Choose One Of Them',16,1)
			return
		END
        

		--if (@is_required = '*' and @p_is_received = '0' and @p_promise_date is NULL )
		--	BEGIN
		--		RAISERROR('Please Insert Promise Date Or Received For Required Documents: %s', 16, 1, @doc_name)
		--		RETURN
		--	END

  

		IF (@p_promise_date <= dbo.xfn_get_system_date())
		BEGIN
			SET @msg = 'Promise Date must be greater than System Date' ;

			raiserror(@msg, 16, -1) ;
		end ;


	end ;

		update	application_doc
		set		received_date	= @p_received_date
				,promise_date	= @p_promise_date
				,is_received	= @p_is_received
				,remarks		= @p_remarks_doc
				,is_valid		= @p_is_valid
				--
				,mod_date		= @p_mod_date
				,mod_by			= @p_mod_by
				,mod_ip_address = @p_mod_ip_address
		where	id				= @p_id ;
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
