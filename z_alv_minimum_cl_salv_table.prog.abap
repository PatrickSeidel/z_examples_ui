*&---------------------------------------------------------------------*
*& Report  Z_ALV_MINIMUM
*&
*&---------------------------------------------------------------------*
* Programm:       Z_ALV_MINIMUM
* User:           SEIDELP
* Date:           17.11.2017
* Beschreibung:   Minimumvariante eines ALV im Vollbild (ohne Dynpro)
*                 auf Basis eines DDIC Struktur CL_SALV_TABLE
*&---------------------------------------------------------------------*
REPORT z_alv_minimum_cl_salv_table.

*----------------------------------------------------------------------*
* Datendeklaration
*----------------------------------------------------------------------*

"DDIC Tabellentyp der anzuzeigenden Tabelle
DATA: lt_sflight TYPE TABLE OF sflight.

DATA: r_salv_table TYPE REF TO cl_salv_table.

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*

  "Holen der Daten aus der Datenbank
  SELECT * UP TO 10 ROWS
    FROM sflight
    INTO TABLE lt_sflight.

  "Instanziierung des ALV-Tabellen-Objekts
  CALL METHOD cl_salv_table=>factory
    IMPORTING
      r_salv_table = r_salv_table "Objektreferenz
    CHANGING
      t_table      = lt_sflight. "Anzuzeigende Tabelle

  "Anzeige ALV table.
  r_salv_table->display( ).
