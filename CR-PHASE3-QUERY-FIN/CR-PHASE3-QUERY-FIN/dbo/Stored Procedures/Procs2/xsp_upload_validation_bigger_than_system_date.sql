create procedure dbo.xsp_upload_validation_bigger_than_system_date
(
    @p_tabel_name					nvarchar(250)
    ,@p_column_name					nvarchar(250)
    ,@p_value_check					nvarchar(4000)
    ,@p_primary_key					nvarchar(250)
    --
    ,@p_cre_date					datetime
    ,@p_cre_by						nvarchar(15)
    ,@p_cre_ip_address				nvarchar(15)
    ,@p_mod_date					datetime
    ,@p_mod_by						nvarchar(15)
    ,@p_mod_ip_address				nvarchar(15)
)
as
begin

    declare @date_check					int
            ,@error_msg					nvarchar(4000)
            ,@value_date				datetime
			,@system_date				date=cast(dbo.xfn_get_system_date() as date);
	
	set dateformat ymd;
    set @system_date = @system_date;

    set dateformat dmy;
    set @date_check = isdate(@p_value_check);

    -- karena date cek dulu value nya apakah sebuah tanggal
    if (@date_check = 0) -- jika ini bukan tanggal
    BEGIN

        set @error_msg = @p_column_name + ' Invalid Format Date';
        exec	dbo.xsp_upload_error_log_insert 
				@p_tabel_name
				,@p_column_name
				,@error_msg
				,@p_primary_key
				--				
				,@p_cre_date
				,@p_cre_by
				,@p_cre_ip_address
				,@p_mod_date
				,@p_mod_by
				,@p_mod_ip_address
    end;
    else -- jika ini adalah tanggal
    BEGIN
    
    -- validasi melebihi system date

		--set dateformat ymd;
        if (convert(date, @p_value_check, 103) > @system_date)
        begin

            set @error_msg = @p_column_name + ' must be lower than or equal to System Date.';

            exec	dbo.xsp_upload_error_log_insert 
					@p_tabel_name
                    ,@p_column_name
                    ,@error_msg
                    ,@p_primary_key
                    --				
                    ,@p_cre_date
                    ,@p_cre_by
                    ,@p_cre_ip_address
                    ,@p_mod_date
                    ,@p_mod_by
                    ,@p_mod_ip_address
        end;
    end;

end;

