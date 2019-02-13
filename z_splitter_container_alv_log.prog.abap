*&---------------------------------------------------------------------*
*& Report Z_SPLITTER_CONTAINER_ALV_LOG
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
*&---------------------------------------------------------------------*
REPORT z_splitter_container_alv_log.


DATA ok_code TYPE sy-ucomm.

"Container für den CustomContainer des Dynpros
DATA gr_container TYPE REF TO cl_gui_custom_container.

"Splitter Container
DATA gr_split TYPE REF TO cl_gui_splitter_container.

"AlV
DATA gr_alv TYPE REF TO cl_salv_table.
DATA lt_sflight TYPE TABLE OF sflight.

"ApplicationLog
DATA:
  g_log_handle        TYPE balloghndl,
  g_control_handle    TYPE balcnthndl,
  g_s_log             TYPE bal_s_log,
  g_t_log_handle      TYPE bal_t_logh,
  g_s_msg             TYPE bal_s_msg,
  g_s_display_profile TYPE bal_s_prof,
  g_msgno             TYPE bal_s_msg-msgno VALUE '300'.


*-----------------------------------------------------------------------
START-OF-SELECTION.
*-----------------------------------------------------------------------

*-----------------------------------------------------------------------
* Container für den CustomContainer des Dynpros erzeugen
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

*-----------------------------------------------------------------------
* SplitterContainer erzeugen
*-----------------------------------------------------------------------

  "Erzeuge Splittercontainer unter Angabe des übergeordneten Containerobjektes
  CREATE OBJECT gr_split
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
*  gr_split1->set_column_width( id = 1 width = 20 ).

*-----------------------------------------------------------------------
* ALV im oberen Splitter erzeugen
*-----------------------------------------------------------------------

  "Holen von Daten aus der Datenbank für ALV
  SELECT * UP TO 10 ROWS
    FROM sflight
    INTO TABLE lt_sflight.

  "Erzeugen der ALV-Objekte mit Referenz auf Splittercontainer-Objekt (per Angae von Row&Column)
  TRY.
      CALL METHOD cl_salv_table=>factory
        EXPORTING
*         list_display = IF_SALV_C_BOOL_SAP=>FALSE
          r_container  = gr_split->get_container( row = 1 column = 1 )
*         container_name =
        IMPORTING
          r_salv_table = gr_alv "Objektreferenz
        CHANGING
          t_table      = lt_sflight. "Anzuzeigende Tabelle
      .
    CATCH cx_salv_msg .
  ENDTRY.

  "ALV ausgeben
  gr_alv->display( ).

*-----------------------------------------------------------------------
* ApplikationLog im unteren Splitter erzeugen
*-----------------------------------------------------------------------

  "Erzeugen des ApplicationLog
  CLEAR g_s_log.
  g_s_log-extnumber = 'APPLICATION LOG CONTROL DEMO'.
  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log      = g_s_log
    IMPORTING
      e_log_handle = g_log_handle
    EXCEPTIONS
      OTHERS       = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  "Erzeugen einer Nachricht
  CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
    EXPORTING
      i_log_handle = g_log_handle
      i_msgty      = 'E'
*     I_PROBCLASS  = '4'
      i_text       = 'Hallo'
*     I_S_CONTEXT  =
*     I_S_PARAMS   =
*           IMPORTING
*     E_S_MSG_HANDLE            =
*     E_MSG_WAS_LOGGED          =
*     E_MSG_WAS_DISPLAYED       =
*           EXCEPTIONS
*     LOG_NOT_FOUND             = 1
*     MSG_INCONSISTENT          = 2
*     LOG_IS_FULL  = 3
*     OTHERS       = 4
    .
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  "Holen eines Anzeigeprofils
  CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
    IMPORTING
      e_s_display_profile = g_s_display_profile.
  g_s_display_profile-no_toolbar = 'X'.

*       define amount of data to be displayed
*  INSERT g_log_handle INTO TABLE g_t_log_handle.

  DATA gr_split_down TYPE REF TO cl_gui_container.
  gr_split_down = gr_split->get_container( row = 2 column = 1 ).

*       create control to display data
  CALL FUNCTION 'BAL_CNTL_CREATE'
    EXPORTING
      i_container         = gr_split_down
      i_s_display_profile = g_s_display_profile
      i_t_log_handle      = g_t_log_handle
    IMPORTING
      e_control_handle    = g_control_handle
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL SCREEN 1000.


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
