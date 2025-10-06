/* Alter : Arif , 15 Des 2022 */

CREATE PROCEDURE dbo.xsp_faktur_cancelation_detail_generate
(
	@p_code								nvarchar(50)
	,@p_year							nvarchar(4)

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

	declare @msg			nvarchar(max)
		,@branch_code		nvarchar(50)
		

	begin try
		-- validasi tahun transaksi tidak boleh lebih besar dari tahun sekarang
		if (@p_year > (select year(dbo.xfn_get_system_date())))
		begin
			set @msg = 'Year must bee less than year now.'
			raiserror(@msg, 16, -1) ;
		end

		select branch_code = @branch_code
		from	faktur_cancelation
		where code = @p_code

		-- validasi hanya boleh 1 transaksi yang pending	
		if exists (select 1 from dbo.faktur_cancelation where status = 'HOLD' AND branch_code = @branch_code and code <> @p_code)
		begin
			set @msg = 'Please complete pending Faktur Cancelation transaction.'
			raiserror(@msg, 16, -1) ;
		end


		delete dbo.faktur_cancelation_detail 
		where cancelation_code = @p_code
			
		-- Insert Data dari fakturmain yang statusnya NEW dan year = param	
		insert into dbo.faktur_cancelation_detail
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
		select @p_code
			   ,faktur_no
               --
               ,cre_date
               ,cre_by
               ,cre_ip_address
               ,mod_date
               ,mod_by
               ,mod_ip_address 
		from dbo.faktur_main
		where status = 'NEW'
		and year = @p_year

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
