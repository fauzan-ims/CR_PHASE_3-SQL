create PROCEDURE dbo.cari_sp_mengandung_with_table (@keyword varchar(30), @table nvarchar(100))    
     		as    
     		begin    
     		select distinct o.name     
     		from sysobjects o, syscomments c    
     		where o.id=c.id    
     		and c.text like '%'+@keyword+'%'
     		and c.text like '%'+@table+'%'    
     		order by o.name
     		end 
