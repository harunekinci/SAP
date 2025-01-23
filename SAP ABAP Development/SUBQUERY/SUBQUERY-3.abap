SELECT SINGLE city, latitude, longitude 
         FROM sgeocity 
         WHERE city IN ( SELECT cityfrom 
                                FROM spfli 
                                WHERE carrid = @carr_id AND 
                                      connid = @conn_id ) 
         INTO (@city, @lati, @longi).  
