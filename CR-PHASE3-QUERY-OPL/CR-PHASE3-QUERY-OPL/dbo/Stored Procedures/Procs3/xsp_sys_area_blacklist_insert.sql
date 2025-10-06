--created by, Rian at 16/05/2023 

CREATE PROCEDURE dbo.xsp_sys_area_blacklist_insert
(
	@p_code			   nvarchar(50)
	,@p_status		   nvarchar(10)
	,@p_source		   nvarchar(250)
	,@p_zip_code	   nvarchar(50)
	,@p_sub_district   nvarchar(50)
	,@p_village		   nvarchar(50)
	,@p_entry_date	   datetime
	,@p_entry_reason   nvarchar(4000)
	,@p_exit_date	   datetime
	,@p_exit_reason	   nvarchar(4000)
	--
	,@p_cre_date	   datetime
	,@p_cre_by		   nvarchar(15)
	,@p_cre_ip_address nvarchar(15)
	,@p_mod_date	   datetime
	,@p_mod_by		   nvarchar(15)
	,@p_mod_ip_address nvarchar(15)
)
as
begin
	declare @msg nvarchar(max) ;

	begin try
		insert into sys_area_blacklist
		(
			code
			,status
			,source
			,zip_code
			,sub_district
			,village
			,entry_date
			,entry_reason
			,exit_date
			,exit_reason
			--
			,cre_date
			,cre_by
			,cre_ip_address
			,mod_date
			,mod_by
			,mod_ip_address
		)
		values
		(	@p_code
			,@p_status
			,@p_source
			,@p_zip_code
			,@p_sub_district
			,@p_village
			,@p_entry_date
			,@p_entry_reason
			,@p_exit_date
			,@p_exit_reason
			--
			,@p_cre_date
			,@p_cre_by
			,@p_cre_ip_address
			,@p_mod_date
			,@p_mod_by
			,@p_mod_ip_address
		) ;
	end try
	begin catch
		set @msg = 'something went wrong! : ' + error_message() ;

		raiserror(@msg, 16, -1) ;

		return @msg ;
	end catch ;
end ;
