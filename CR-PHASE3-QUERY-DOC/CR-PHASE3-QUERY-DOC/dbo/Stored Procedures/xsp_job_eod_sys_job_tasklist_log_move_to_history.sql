CREATE PROCEDURE dbo.xsp_job_eod_sys_job_tasklist_log_move_to_history
AS
BEGIN

	declare @msg					nvarchar(max)
			--
			,@is_active				nvarchar(1)
			,@mod_date				datetime	= getdate()
			,@mod_by				nvarchar(15) = 'job'
			,@mod_ip_address		nvarchar(15) = '127.0.0.1';


        
	select	@is_active				= is_active
	from	dbo.sys_job_tasklist
	where	sp_name = 'xsp_job_eod_sys_job_tasklist_log_move_to_history' ;

	-- sesuai dengan nama sp ini

	--get prp prospect sales
	if (@is_active = '1')
	begin

		insert into dbo.sys_job_tasklist_log_history
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
		select	job_tasklist_code
				,status
				,start_date
				,end_date
				,log_description
				,run_by
				,from_id
				,to_id
				,number_of_rows
				--
				,@mod_date		
				,@mod_by		
				,@mod_ip_address
				,@mod_date		
				,@mod_by		
				,@mod_ip_address
		from	dbo.sys_job_tasklist_log

		delete	dbo.sys_job_tasklist_log

	END
end
