*&---------------------------------------------------------------------*
*& Report Z_CONTAINER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CONTAINER.


*    DATA: cl_grid1      TYPE REF TO cl_gui_alv_grid,
*          cl_grid2      TYPE REF TO cl_gui_alv_grid,
*          cl_split      TYPE REF TO cl_gui_splitter_container,
*          cl_container  TYPE REF TO cl_gui_container.
*
*    SELECTION-SCREEN BEGIN OF SCREEN 100.
*      SElection-SCREEN END OF SCREEN 100.
*
*    START-OF-SELECTION.
*
*
*
*
*
*
*      CREATE OBJECT cl_split
*        EXPORTING
*          parent                  = cl_gui_container=>default_screen
*          rows                    = 1
*          columns                 = 2
*          no_autodef_progid_dynnr = 'X'
*          .
*
*      cl_container = cl_split->get_container( row = 1 column = 1 ).
*
*      CREATE OBJECT cl_grid1
*        EXPORTING
*          i_parent = cl_container.
*
*      cl_container = cl_split->get_container( row = 1 column = 2 ).
*
*      CREATE OBJECT cl_grid2
*        EXPORTING
*          i_parent = cl_container.
*
*      call screen 100.


*SELECTION-SCREEN BEGIN OF SCREEN 100.
*SELECTION-SCREEN END OF SCREEN 100.

START-OF-SELECTION.

  data cl_split      TYPE REF TO cl_gui_splitter_container.
  DATA: it_sflight TYPE STANDARD TABLE OF sflight.

  CREATE OBJECT cl_split
        EXPORTING
          parent                  = cl_gui_container=>default_screen
          rows                    = 1
          columns                 = 2
          "no_autodef_progid_dynnr = 'X'
          .

  SELECT * FROM sflight INTO TABLE it_sflight.

* ALV-Grid in Standarddynpro cl_gui_container=>default_screen einbetten
  "DATA(o_alv) = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen ).
  DATA(o_alv) = NEW cl_gui_alv_grid( i_parent = cl_split->get_container( row = 1 column = 2 ) ).

  o_alv->set_table_for_first_display( EXPORTING
                                        i_structure_name = 'SFLIGHT'
                                      CHANGING
                                        it_outtab        = it_sflight ).

* leeres Dynpro anzeigen und Ausgabe von cl_gui_container=>default_screen erzwingen
*  CALL SCREEN 100.


CALL SCREEN 1000.
