*&---------------------------------------------------------------------*
*& Report Z_SPLITTER_CONTAINER_BASIC
*&---------------------------------------------------------------------*
* User:           SEIDELP
* Datum:          06.02.2019
* Beschreibung:   Basics zum Aufbau eines Splitter Containers
* Vorbereitungen: - Dynpro 1000 mit Modulen STATUS_1000 und USER_COMMAND_1000 anlegen
*                 - Auf Dynpro 1000 CustomContainer mit Bezeichnung 'CONTAINER' anlegen
*                 - Einstellen Dynproeigenschaften Zeilen/Spalten Plege im Bereich
*                   Weitere Attribute auf 200/255 und im Screen Painter CustomContainer auf
*                   maximale Größe Lg 255 H 200 sowie anhaken der Attribute Resizing vertikal
*                   und Resizing horizontal (für Vollbild anzeige)
* Quelle: https://www.berater-wiki.de/Splitting_Container
*&---------------------------------------------------------------------*
REPORT z_splitter_container_basic.



DATA ok_code TYPE sy-ucomm.

DATA gr_container TYPE REF TO cl_gui_custom_container.

DATA gr_split1 TYPE REF TO cl_gui_splitter_container.
DATA gr_split2 TYPE REF TO cl_gui_splitter_container.

DATA gr_alv1 TYPE REF TO cl_salv_table.
DATA gr_alv2 TYPE REF TO cl_salv_table.
DATA gr_alv3 TYPE REF TO cl_salv_table.
DATA lt_sflight TYPE TABLE OF sflight.

*-----------------------------------------------------------------------
START-OF-SELECTION.
*-----------------------------------------------------------------------

  "Ezeugen des Containerobjekts unter Angabe des CustomContainer Namens im Dynpro
  CREATE OBJECT gr_container
    EXPORTING
*     parent                      =
      container_name              = 'CONTAINER'
*     style                       =
*     lifetime                    = lifetime_default
*     repid                       =
*     dynnr                       =
*     no_autodef_progid_dynnr     =
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  "Erzeuge Splittercontainer1 unter Angabe des übergeordneten Containerobjektes
  CREATE OBJECT gr_split1
    EXPORTING
*     link_dynnr        =
*     link_repid        =
*     shellstyle        =
*     left              =
*     top               =
*     width             =
*     height            =
*     metric            = cntl_metric_dynpro
*     align             = 15
      parent            = gr_container
      rows              = 1
      columns           = 2
*     no_autodef_progid_dynnr =
*     name              =
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  "Erzeuge Splittercontainer1 unter Angabe des übergeordneten Containerobjektes
  CREATE OBJECT gr_split2
    EXPORTING
*     link_dynnr        =
*     link_repid        =
*     shellstyle        =
*     left              =
*     top               =
*     width             =
*     height            =
*     metric            = cntl_metric_dynpro
*     align             = 15
      parent            = gr_split1->get_container( row = 1 column = 2 )
      rows              = 2
      columns           = 1
*     no_autodef_progid_dynnr =
*     name              =
    EXCEPTIONS
      cntl_error        = 1
      cntl_system_error = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


  "Breite der ersten Spalte des 1 Containers
  gr_split1->set_column_width( id = 1 width = 20 ).
  "Höhe der 2 Zeile des 2. Containers
  gr_split2->set_row_height(   id = 2 height = 30  ).


  "Holen von Daten aus der Datenbank für ALV
  SELECT * UP TO 10 ROWS
    FROM sflight
    INTO TABLE lt_sflight.

"Erzeugen der ALV-Objekte mit Referenz auf Splittercontainer-Objekt (per Angae von Row&Column)
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
*         list_display = IF_SALV_C_BOOL_SAP=>FALSE
          r_container  = gr_split1->get_container( row = 1 column = 1 )
*         container_name =
        IMPORTING
          r_salv_table = gr_alv1 "Objektreferenz
        CHANGING
          t_table      = lt_sflight. "Anzuzeigende Tabelle
      .
    CATCH cx_salv_msg .
  ENDTRY.

    TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
*         list_display = IF_SALV_C_BOOL_SAP=>FALSE
          r_container  = gr_split2->get_container( row = 1 column = 1 )
*         container_name =
        IMPORTING
          r_salv_table = gr_alv2 "Objektreferenz
        CHANGING
          t_table      = lt_sflight. "Anzuzeigende Tabelle
      .
    CATCH cx_salv_msg .
  ENDTRY.

    TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
*         list_display = IF_SALV_C_BOOL_SAP=>FALSE
          r_container  = gr_split2->get_container( row = 2 column = 1 )
*         container_name =
        IMPORTING
          r_salv_table = gr_alv3 "Objektreferenz
        CHANGING
          t_table      = lt_sflight. "Anzuzeigende Tabelle
      .
    CATCH cx_salv_msg .
  ENDTRY.

  gr_alv1->display( ).
  gr_alv2->display( ).
  gr_alv3->display( ).


  CALL SCREEN 1000.

*&---------------------------------------------------------------------*
*& Unterprogramme
*&---------------------------------------------------------------------*

FORM get_alv
  CHANGING
    c_alv TYPE REF TO cl_gui_alv_grid.

  DATA lt_sflight TYPE TABLE OF sflight.
  DATA lr_salv_table TYPE REF TO cl_salv_table.

  "Holen der Daten aus der Datenbank
  SELECT * UP TO 10 ROWS
    FROM sflight
    INTO TABLE lt_sflight.

  "Instanziierung des ALV-Tabellen-Objekts
*  CALL METHOD cl_salv_table=>factory
*    IMPORTING
*      r_salv_table = lr_salv_table "Objektreferenz
*    CHANGING
*      t_table      = lt_sflight. "Anzuzeigende Tabelle

  "c_alv = lr_salv_table.

  BREAK-POINT.

ENDFORM.

*&---------------------------------------------------------------------*
*& Module Dynpro 1000
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_1000 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_1000 OUTPUT.
  SET PF-STATUS 'STATUS_100' OF PROGRAM 'DEMO_DYNPRO_AT_EXIT_COMMAND'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1000 INPUT.

  CASE ok_code.
    WHEN 'BACK'.
      LEAVE PROGRAM.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
    WHEN 'CANCEL'.
      LEAVE PROGRAM.
    WHEN 'EXECUTE'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
