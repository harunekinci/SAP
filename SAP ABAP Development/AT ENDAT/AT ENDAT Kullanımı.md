METHOD get_data.

    DATA : ls_out     TYPE zepre_s423,
           lv_aliciad TYPE char100.

    SELECT DISTINCT vib~swenr,
           v~xwetext        ,
           vib~smenr        ,
           vib~zzbbvekalet  ,
           vib~block_no     ,
           vib~apartmentno  ,
           ddl002~blok_index ,
           ddl002~parcel     ,
           ddl002~usage_typ  ,
           ddl002~neighborh1 ,
           ddl002~partner    ,
           ddl004~zm1_14     ,
           ddl004~zm1_13     ,
           t057~exp_value ,
           t072~zm__1    ,
           t072~zm3_1  ,
           t072~zm__2  ,
           t072~zm3_2  ,
           t072~zm__3  ,
           t072~zm3_3  ,
           t072~zm1_80 ,
           t072~zm1_83 ,
           t072~zm1_77 ,
           t072~zm1_7  ,
           t032~bb_fiyat_s   ,
           t032~indtutar  ,
           t032~kdvorani,
           t032~vade,
           t020~satsek_txt,
           ddl002~bukrs
       FROM vibdro AS vib
      LEFT OUTER JOIN vibdbe        AS v      ON vib~swenr        EQ v~swenr
      LEFT OUTER JOIN zepre_ddl002  AS ddl002 ON vib~swenr        EQ ddl002~swenr
                                    AND          vib~smenr        EQ ddl002~smenr
      LEFT OUTER JOIN zepre_ddl004  AS ddl004 ON vib~swenr        EQ ddl004~swenr
                                    AND          vib~smenr        EQ ddl004~smenr
      LEFT OUTER JOIN zepre_t057    AS t057   ON vib~swenr        EQ t057~swenr
                                    AND          vib~smenr        EQ t057~smenr
      LEFT OUTER JOIN zepre_t072    AS t072   ON ddl002~rointreno EQ t072~intreno
      LEFT OUTER JOIN zepre_t032   AS t032    ON vib~swenr        EQ t032~proje
                                    AND          vib~smenr        EQ t032~bbolum
      LEFT OUTER JOIN zepre_t020    AS t020    ON t032~satsek     EQ t020~satsek
       INTO TABLE @DATA(lt_data)
      WHERE vib~swenr       EQ @p_swenr
      AND   vib~bukrs       EQ @p_bukrs
      AND   vib~zzbbvekalet EQ '01'.

    SORT  lt_data BY smenr ASCENDING.
    DATA: lr_smenr TYPE RANGE OF smenr.

    LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<fs_data>).

      APPEND VALUE #( sign = 'I' option = 'EQ'  low = <fs_data>-smenr ) TO lr_smenr[].

      AT NEW smenr.

        MOVE-CORRESPONDING <fs_data> TO ls_out.

        ls_out-zeksm2oran     = COND #( WHEN  ls_out-zm1_14 NE 0 THEN ( ls_out-exp_value / ls_out-zm1_14 ) ELSE 0 ).
        ls_out-zindstsfiyatzm = COND #( WHEN  ls_out-zm1_14 NE 0 THEN ( ls_out-zindstsfiyat / ls_out-zm1_14 ) ELSE 0 ).
        ls_out-zeksstsoran    = COND #( WHEN  ls_out-zindstsfiyat NE 0 THEN ( ls_out-exp_value / ls_out-zindstsfiyat ) * 100 ELSE 0 ).
        ls_out-zindstsfiyat   = ( ls_out-bb_fiyat_s - ls_out-indtutar ).

        LOOP AT gt_acdoca ASSIGNING FIELD-SYMBOL(<fs_acdoca>) WHERE zuonr EQ ls_out-swenr.
          ls_out-tsl = ls_out-tsl + <fs_acdoca>-tsl.
        ENDLOOP.

      ENDAT.

      READ TABLE gt_but000 ASSIGNING FIELD-SYMBOL(<fs_but00>) WITH KEY partner = <fs_data>-partner.

      IF sy-subrc IS INITIAL.

        lv_aliciad = <fs_but00>-name_org1 && <fs_but00>-name_org2 && <fs_but00>-name_org3.

        IF lv_aliciad IS INITIAL.
          lv_aliciad = <fs_but00>-name_first && <fs_but00>-name_last.
        ENDIF.

        IF lv_aliciad IS NOT INITIAL.

          IF lines( lr_smenr ) > 1.
            CONCATENATE lv_aliciad ls_out-zaliciad INTO ls_out-zaliciad SEPARATED BY ` / `.
          ELSE.
            CONCATENATE lv_aliciad ls_out-zaliciad INTO ls_out-zaliciad.

          ENDIF.

        ENDIF.

      ENDIF.

      AT END OF smenr.

        APPEND ls_out TO gt_out.
        CLEAR : ls_out, lr_smenr.

      ENDAT.

    ENDLOOP.

  ENDMETHOD.