      *****************************************************************
      * Title..........: SEQ3000 - Employee Maintenance
      * Programmer.....: Ben Stearns
      * Date...........: 4-20-26
      * GitHub URL.....: https://github.com/bstearns07/SEQ3000
      * Program Desc...: Updates an old employee master file depicting
      *                  employee information using Add/Change/Delete
      *                  transactions, then writes the updated
      *                  information into a new master file/index file
      * File Desc......: Creates an index file out of of the OLDMAST
      *                  sequential file
      *****************************************************************

       IDENTIFICATION DIVISION.

       PROGRAM-ID. SEQ1001.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT OLDEMP ASSIGN TO OLDEMP.
           SELECT EMPMASTI ASSIGN TO EMPMASTI
                           ORGANIZATION IS INDEXED
                           ACCESS IS SEQUENTIAL
                           RECORD KEY IS IR-EMPLOYEE-ID.

       DATA DIVISION.

       FILE SECTION.

       FD  OLDEMP.

       01  SEQUENTIAL-RECORD-AREA  PIC X(57).

       FD  EMPMASTI.

       01  INDEXED-RECORD-AREA.
           05  IR-EMPLOYEE-ID             PIC X(5).
           05  FILLER                  PIC X(52).

       WORKING-STORAGE SECTION.

       01  SWITCHES.
           05  OLDEMP-EOF-SWITCH      PIC X    VALUE "N".
               88  OLDEMP-EOF                  VALUE "Y".

       01  EMPLOYEE-MASTER-RECORD.
           05  EM-EMPLOYEE-ID              PIC X(5).
           05  FILLER                      PIC X(52).

       PROCEDURE DIVISION.

      *****************************************************************
      * Opens the seqential file and the indexed file, then beings 
      * creating records in the indexed file based on the records in the
      * sequential file until the end of the sequential file is reached
      *****************************************************************
       000-CREATE-INVENTORY-FILE.

           OPEN INPUT  OLDEMP
                OUTPUT EMPMASTI.
           PERFORM 100-CREATE-INVENTORY-RECORD
               UNTIL OLDEMP-EOF.
           CLOSE OLDEMP
                 EMPMASTI.
           STOP RUN.

      *****************************************************************
      * Reads a record from the sequential file, then writes that record
      * to the indexed file. If the end of the sequential file is
      * reached, the EOF switch is set to true and the program will stop
      * creating records in the indexed file
      *****************************************************************
       100-CREATE-INVENTORY-RECORD.

           PERFORM 110-READ-SEQUENTIAL-RECORD.
           IF NOT OLDEMP-EOF
               PERFORM 120-WRITE-INDEXED-RECORD.

      *****************************************************************
      * Reads a record from the sequential file into the employee master
      * record. If the end of the sequential file is reached, the EOF
      * switch is set to true and the program will stop creating records
      * in the indexed file
      *****************************************************************
       110-READ-SEQUENTIAL-RECORD.

           READ OLDEMP INTO EMPLOYEE-MASTER-RECORD
               AT END
                   SET OLDEMP-EOF TO TRUE.

      *****************************************************************
      * Writes the employee master record into the indexed file. If
      * there is an error writing the record, a message is displayed and
      * the EOF switch is set to true to stop creating records in the
      * indexed file
      *****************************************************************
       120-WRITE-INDEXED-RECORD.

           WRITE INDEXED-RECORD-AREA FROM EMPLOYEE-MASTER-RECORD
               INVALID KEY
                   DISPLAY "WRITE ERROR ON INVMAST FOR ITEM NUMBER "
                       IR-EMPLOYEE-ID
                   SET OLDEMP-EOF TO TRUE.
