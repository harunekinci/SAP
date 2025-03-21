  METHOD get_banka_ogs_hareket BY DATABASE FUNCTION
                                   FOR HDB LANGUAGE SQLSCRIPT OPTIONS READ-ONLY
                                 USING znet_eho_t_c_064 zeppm_t010.


    RETURN select *
             from (SELECT bankahareket.mandt,
                          (SELECT sysuuid FROM dummy) AS tasit_hgs_id,
                          trim(SUBSTRING( bankahareket.aciklama, locate( bankahareket.aciklama, ' Plaka ' ) - 8, 8 ) ) as plaka,
                          to_char( substring( bankahareket.aciklama, locate( bankahareket.aciklama, ' Nolu Ürün ile ' ) + 15, locate( bankahareket.aciklama, ' de ' ) - locate( bankahareket.aciklama, ' Nolu Ürün ile ' ) - 15 ), 'YYYYMMDDHH24MISS' )
                          as gecis_zamani,
                          case when gecisnokta.islem_aciklama is not null then gecisnokta.islem_aciklama
                               else bankahareket.islem_tipi end  as gecis_noktasi,
                          case when gecisnokta.iade = 'X' THEN bankahareket.tutar * -1
                               else bankahareket.tutar end as tutar,
                          bankahareket.aciklama
                     from znet_eho_t_c_064        as bankahareket left outer join
                          zeppm_t010              as gecisnokta   on bankahareket.hkont = gecisnokta.hkont
                                                                 and bankahareket.islem_tipi = gecisnokta.islem_tipi
                    where bankahareket.hkont in ( select hkont from zeppm_t010 )
                      and locate( bankahareket.aciklama, ' Plaka ' ) <> 0
                      and bankahareket.fiziksel_islem_tarihi < '20220401'
                      and bankahareket.islem_tipi not in ('GECURUNSATIS','GECURUNSATISIPTAL')
                   )
              order by gecis_zamani desc;
  endmethod.
  