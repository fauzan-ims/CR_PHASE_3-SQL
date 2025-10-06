/* Alter : Arif , 15 Des 2022 */

CREATE PROCEDURE dbo.xsp_faktur_cancelation_detail_insert
(
	@p_id								bigint output
	,@p_canceltion_code					nvarchar(50)
	,@p_faktur_no						nvarchar(50)
	--
	,@p_cre_date						datetime
	,@p_cre_by							nvarchar(15)
	,@p_cre_ip_address					nvarchar(15)
	,@p_mod_date						datetime
	,@p_mod_by							nvarchar(15)
	,@p_mod_ip_address					nvarchar(15)
)
as
begin

	declare @code			nvarchar(50)
			,@year			nvarchar(4)
			,@month			nvarchar(2)
			,@status		nvarchar(10)
			,@msg			nvarchar(max) ;

	begin try
	
		--set @year = substring(cast(datepart(year, @p_cre_date) as nvarchar), 3, 2);

		select	faktur_no = @p_faktur_no
				,year = @year
		from	dbo.faktur_main
		where	year = @year
		and		status = 'NEW'

		SELECT code = @p_canceltion_code
		FROM dbo.faktur_cancelation



		insert into faktur_cancelation_detail
		(
			
			cancelation_code
			,faktur_no
		
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
			@p_canceltion_code
			,@p_faktur_no
		
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
end 
