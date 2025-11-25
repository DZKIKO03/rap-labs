" ------------------------------------------------------------------------------------
" Script: cleanup_tables.abap
" Purpose: Clear travel tables for development/testing
" Author: Daniele
" ------------------------------------------------------------------------------------

DELETE FROM ztravel_tab.
DELETE FROM ztravel_tab_d.
COMMIT WORK.
