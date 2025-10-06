CREATE PROCEDURE dbo.xsp_sys_job_tasklist_log_insert
(
	@p_job_tasklist_code			nvarchar(50)
	,@p_status						nvarchar(20)
	,@p_start_date					datetime
	,@p_end_date					datetime
	,@p_log_description				nvarchar(400) = ''
	,@p_run_by						nvarchar(20)
	,@p_from_id						bigint
	,@p_to_id						bigint
	,@p_number_of_rows				int
	--
	,@p_cre_date					datetime
	,@p_cre_by						nvarchar(15)
	,@p_cre_ip_address				nvarchar(15)
	,@p_mod_date					datetime
	,@p_mod_by						nvarchar(15)
	,@p_mod_ip_address				nvarchar(15)
)
as
BEGIN

    declare @msg nvarchar(max);

    begin TRY
    
        if @p_status = 'ERROR'
        BEGIN
        
            if not exists
            (
				-- check last status job tersebut, jika error belum ada akan di insert
                select 1
                from	dbo.sys_job_tasklist
                where	CODE				= @p_job_tasklist_code
				and		eod_status			= @p_status
                and		eod_remark			= @p_log_description

            )
            begin
				-- update ke job error nya apa
				update	dbo.sys_job_tasklist
				set		eod_status		= @p_status
						, eod_remark	= @p_log_description
				where	code			= @p_job_tasklist_code

				-- insert ke log
                insert into dbo.sys_job_tasklist_log
                (
					job_tasklist_code
					,status
					,start_date
					,end_date
					,log_description
					,run_by
					,from_id
					,to_id
					,number_of_rows
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
                )
                values
                (   
					@p_job_tasklist_code
					,@p_status          
					,@p_start_date      
					,@p_end_date        
					,@p_log_description 
					,@p_run_by          
					,@p_from_id         
					,@p_to_id           
					,@p_number_of_rows  
                    --
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
                );
            end;
        end;
        else -- jika success
        BEGIN
        
			if (@p_number_of_rows <> 0)
			begin
				-- update ke job success
				update	dbo.sys_job_tasklist
				set		eod_status		= @p_status
						, eod_remark	= ''
				where	code			= @p_job_tasklist_code;

				insert into dbo.sys_job_tasklist_log
				(
					job_tasklist_code
					,status
					,start_date
					,end_date
					,log_description
					,run_by
					,from_id
					,to_id
					,number_of_rows
					--
					,cre_date
					,cre_by
					,cre_ip_address
					,mod_date
					,mod_by
					,mod_ip_address
				)
				values
				(   
					@p_job_tasklist_code  -- job_tasklist_code - nvarchar(50)
					,@p_status            -- status - nvarchar(20)
					,@p_start_date        -- start_date - datetime
					,@p_end_date          -- end_date - datetime
					,@p_log_description   -- log_description - nvarchar(400)
					,@p_run_by            -- run_by - nvarchar(20)
					,@p_from_id           -- from_id - bigint
					,@p_to_id             -- to_id - bigint
					,@p_number_of_rows    -- number_of_rows - int
					--
					,@p_cre_date
					,@p_cre_by
					,@p_cre_ip_address
					,@p_mod_date
					,@p_mod_by
					,@p_mod_ip_address
				);
			end;
        end;
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
end;


