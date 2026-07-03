# 🎯 Field-Symbol Kullanımı (ASSIGNING / UNASSIGN)

<br/>

<div align="center">

<img src="https://img.shields.io/badge/SAP-ABAP_7.40+-008FD3?style=for-the-badge&logo=sap&logoColor=white" />
<img src="https://img.shields.io/badge/FEATURE-FIELD--SYMBOL-success?style=for-the-badge" />
<img src="https://img.shields.io/badge/PERFORMANCE-REFERENCE-blue?style=for-the-badge" />

</div>

<br/>

> **Amaç:** Field-Symbol kullanarak internal table satırlarını referans üzerinden güncellemek, dinamik alan erişimi gerçekleştirmek ve `UNASSIGN` ile güvenli bellek yönetimi sağlamaktır. Bu yöntem özellikle büyük tablolar üzerinde performans avantajı sağlar.

---

# 📋 Kullanılan Yapılar

| Yapı | Açıklama |
|------|----------|
| `LOOP ... ASSIGNING` | Internal table satırına referans ile erişim |
| `READ TABLE ... ASSIGNING` | Kayıdı referans olarak okuma |
| `ASSIGN COMPONENT` | Alan adına göre dinamik component erişimi |
| `FIELD-SYMBOLS` | Bellekteki nesneye referans oluşturma |
| `UNASSIGN` | Field-Symbol bağlantısını kaldırma |
| `IS ASSIGNED` | Referansın geçerli olup olmadığını kontrol etme |
| `CL_DEMO_OUTPUT` | Sonucu ekranda gösterme |


---

# 💡 Kullanım Notları

> [!TIP]
> `ASSIGNING` kullanıldığında satır doğrudan bellekte güncellenir. Ayrı bir `MODIFY` komutuna ihtiyaç kalmaz.

> [!TIP]
> `READ TABLE ... ASSIGNING` büyük internal table'larda `INTO` kullanımına göre daha performanslıdır.

> [!IMPORTANT]
> `ASSIGN COMPONENT` sonrasında mutlaka `IS ASSIGNED` kontrolü yapılmalıdır. Böylece `GETWA_NOT_ASSIGNED` veya `GET_RES_NOT_ASSIGNED` short dump'ları önlenmiş olur.

> [!IMPORTANT]
> `UNASSIGN`, field-symbol'un son referansını serbest bırakır ve yanlışlıkla eski satıra erişilmesini engeller.

> [!WARNING]
> Dynamic component adı yanlış verilirse `ASSIGN COMPONENT` başarısız olur. Bu nedenle işlem öncesinde `IS ASSIGNED` kontrolü zorunludur.

---

# 💻 ABAP Kodu

```abap
CLASS lcl_demo DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS run.
ENDCLASS.

CLASS lcl_demo IMPLEMENTATION.

  METHOD run.

    TYPES:
      BEGIN OF ty_order,
        order_id   TYPE vbeln_va,
        item_no    TYPE posnr_va,
        status     TYPE char1,   " N: New, P: Processed, C: Completed
        net_amount TYPE p LENGTH 8 DECIMALS 2,
      END OF ty_order.

    TYPES tt_orders TYPE STANDARD TABLE OF ty_order
                    WITH EMPTY KEY.

    DATA(lt_orders) = VALUE tt_orders(
      ( order_id = '0010000001'
        item_no = '000010'
        status = 'N'
        net_amount = '1500.00' )

      ( order_id = '0010000002'
        item_no = '000010'
        status = 'P'
        net_amount = '2350.50' )
    ).

    "====================================================================
    "* 1. Inline Loop & Direct Memory Modification
    "====================================================================

    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<ls_order>)
         WHERE status = 'N'.

      " MODIFY yerine doğrudan referans üzerinden güncelleme
      <ls_order>-status = 'P'.

    ENDLOOP.

    " Son referans bağlantısını kaldır
    UNASSIGN <ls_order>.

    "====================================================================
    "* 2. Dynamic Component Assignment
    "====================================================================

    DATA(lv_field_name) = 'NET_AMOUNT'.

    READ TABLE lt_orders ASSIGNING FIELD-SYMBOL(<ls_target_order>)
         WITH KEY order_id = '0010000002'.

    IF sy-subrc = 0.

      ASSIGN COMPONENT lv_field_name
             OF STRUCTURE <ls_target_order>
             TO FIELD-SYMBOL(<lv_amount>).

      IF <lv_amount> IS ASSIGNED.

        " %10 fiyat artışı
        <lv_amount> = <lv_amount> * '1.10'.

        UNASSIGN <lv_amount>.

      ENDIF.

    ENDIF.

    UNASSIGN <ls_target_order>.

    "====================================================================
    "* 3. Output
    "====================================================================

    IF <ls_target_order> IS NOT ASSIGNED.
      cl_demo_output=>display( lt_orders ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  lcl_demo=>run( ).
```
