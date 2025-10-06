CREATE PROCEDURE [dbo].[xsp_gps_unsubcribe_request_insert]
(
    @p_request_no				nvarchar(50) output 
    ,@p_id						bigint
    ,@p_source_reff_name		nvarchar(250) ='MONITORING'
    ,@p_cre_date				datetime
    ,@p_cre_by					nvarchar(15)
    ,@p_cre_ip_address			nvarchar(15)
    ,@p_mod_date				datetime
    ,@p_mod_by					nvarchar(15)
    ,@p_mod_ip_address			nvarchar(15)
    ,@p_source_reff_no			nvarchar(50) = ''
	,@p_remarks					NVARCHAR(4000)=''
)
AS
BEGIN
    DECLARE @msg				NVARCHAR(MAX),
            @year				NVARCHAR(2),
            @month				NVARCHAR(2),
			@branch_code		NVARCHAR(50),
			@branch_name		NVARCHAR(250),
			@final_branch_code	NVARCHAR(50),
			@final_branch_name	NVARCHAR(250),
			@remark             NVARCHAR(250),
			@source_reff_name   NVARCHAR(250),
			@unsubscribe_date   DATETIME,
			@asset_code			NVARCHAR(50) 

    set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2) ;
	set @month = replace(str(cast(datepart(month, @p_cre_date) as nvarchar), 2, 0), ' ', '0') ;

    exec dbo.xsp_get_next_unique_code_for_table 
								@p_unique_code 			= @p_request_no output
								,@p_branch_code 		= ''
								,@p_sys_document_code 	= ''
								,@p_custom_prefix 		= 'UNGPS'
								,@p_year 				= @year
								,@p_month 				= @month
								,@p_table_name 			= 'GPS_UNSUBCRIBE_REQUEST'
								,@p_run_number_length 	= 6
								,@p_delimiter 			= '.'
								,@p_run_number_only 	= N'0' ;
		
	select @branch_code		= ast.branch_code
			,@branch_name	= ast.branch_name
			,@asset_code	= mg.fa_code
	from  dbo.monitoring_gps mg
	inner join dbo.asset ast on ast.code = mg.fa_code
	where mg.id = @p_id

	if isnull(@p_source_reff_no,'') = '' set @p_source_reff_no = @asset_code

    begin try
        insert into dbo.gps_unsubcribe_request 
		(
            request_no
            ,fa_code
            ,request_date
            ,source_reff_no
            ,source_reff_name
            ,remark
            ,status
			,branch_code
			,branch_name
			,id_monitoring_gps
			,unsubscribe_date
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
        )
        VALUES (
            @p_request_no
            ,@asset_code
            ,@p_cre_date
            ,@p_source_reff_no--@p_id
            ,@p_source_reff_name
            ,@p_remarks
            ,'HOLD'
			,@branch_code
			,@branch_name
			,@p_id
			,@p_cre_date
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
        );

		update	dbo.monitoring_gps
		set		status					= 'ONPROCESS UNSUBSCRIBE'
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	id	= @p_id;

		update	dbo.asset
		set		gps_status				= 'ONPROCESS UNSUBSCRIBE'
				,mod_date				= @p_mod_date
				,mod_by					= @p_mod_by
				,mod_ip_address			= @p_mod_ip_address
		where	code	= @asset_code;
    end try

    begin catch
        declare @error int = @@error;

        if (@error = 2627)
        begin
            set @msg = dbo.xfn_get_msg_err_code_already_exist();
        end;

        IF (LEN(@msg) <> 0)
        BEGIN
            SET @msg = N'V;' + @msg;
        END
        ELSE IF (LEFT(ERROR_MESSAGE(), 2) = 'V;')
        BEGIN
            SET @msg = ERROR_MESSAGE();
        END
        ELSE
        BEGIN
            SET @msg = N'E;' + dbo.xfn_get_msg_err_generic() + N';' + ERROR_MESSAGE();
        END

        RAISERROR(@msg, 16, -1);
        RETURN;
    END CATCH;
END;
