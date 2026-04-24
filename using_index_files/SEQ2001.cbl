      *****************************************************************
      * Title..........: SEQ3000 - Employee Maintenance
      * Programmer.....: Ben Stearns
      * Date...........: 4-20-26
      * GitHub URL.....: https://github.com/bstearns07/SEQ3000
      * Program Desc...: Updates an old employee master file depicting
      *                  employee information using Add/Change/Delete
      *                  transactions, then writes the updated
      *                  information into a new master file/index file
      * File Desc......: Updates records in the EMPMASTI index file 
      *                  using the EMPTRAN transaction file
      *****************************************************************

       IDENTIFICATION DIVISION.

       PROGRAM-ID.  SEQ2001.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT EMPTRAN  ASSIGN TO EMPTRAN.
           SELECT EMPMASTI  ASSIGN TO EMPMASTI
                           ORGANIZATION IS INDEXED
                           ACCESS IS RANDOM
                           RECORD KEY IS IR-EMPLOYEE-ID.
           SELECT ERRTRAN  ASSIGN TO ERRTRAN
                           FILE STATUS IS ERRTRAN-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD  EMPTRAN.

       01  TRANSACTION-RECORD      PIC X(50).

       FD  EMPMASTI.

       01  INVENTORY-RECORD-AREA.
           05  IR-EMPLOYEE-ID          PIC X(5).
           05  FILLER                  PIC X(52).

       FD  ERRTRAN.

       01  ERROR-TRANSACTION       PIC X(50).

       WORKING-STORAGE SECTION.

       01  SWITCHES.
           05  TRANSACTION-EOF-SWITCH  PIC X   VALUE "N".
               88  TRANSACTION-EOF             VALUE "Y".
           05  MASTER-FOUND-SWITCH     PIC X   VALUE "Y".
               88  MASTER-FOUND                VALUE "Y".

       01  FILE-STATUS-FIELDS.
           05  ERRTRAN-FILE-STATUS     PIC XX.
               88  ERRTRAN-SUCCESSFUL          VALUE "00".

       01  EMPLOYEE-TRANSACTION.
           05  ET-TRANSACTION-CODE     PIC X.
               88  ADD-RECORD                  VALUE "A".
               88  CHANGE-RECORD               VALUE "C".
               88  DELETE-RECORD               VALUE "D".
           05  ET-MASTER-DATA.
                 10  ET-EMPLOYEE-ID              PIC X(5).
                 10  ET-EMPLOYEE-NAME            PIC X(30).
                 10  ET-DEPART-CODE              PIC X(5).
                 10  ET-JOB-CLASS                PIC X(2).
                 10  ET-ANNUAL-SALARY            PIC 9(5)V99.

       01  EMPLOYEE-MASTER-RECORD.
           05  EM-EMPLOYEE-ID              PIC X(5).
           05  EM-EMPLOYEE-NAME            PIC X(30).
           05  EM-DEPART-CODE              PIC X(5).
           05  EM-JOB-CLASS                PIC X(2).
           05  EM-ANNUAL-SALARY            PIC 9(5)V99.
           05  EM-VACATION-HOURS           PIC 9(3).
           05  EM-SICK-HOURS               PIC 9(3)V99.

       PROCEDURE DIVISION.

      *****************************************************************
      * Opens input/output files + index file, performs updates to the
      * index file until no more transactions are found, then closes
      * all files and stops the program.
      *****************************************************************
       000-MAINTAIN-INVENTORY-FILE.

           OPEN INPUT  EMPTRAN
                I-O    EMPMASTI
                OUTPUT ERRTRAN.
           PERFORM 300-MAINTAIN-INVENTORY-RECORD
               UNTIL TRANSACTION-EOF.
           CLOSE EMPTRAN
                 EMPMASTI
                 ERRTRAN.
           STOP RUN.

      *****************************************************************
      * Reads in information from the transaction file, then performs
      * the appropriate action to the index file based on the
      * transaction code. If an error occurs, an error transaction is
      * written to the error file.
      *****************************************************************
       300-MAINTAIN-INVENTORY-RECORD.

           PERFORM 310-READ-INVENTORY-TRANSACTION.
           IF NOT TRANSACTION-EOF
               PERFORM 320-READ-INVENTORY-MASTER
               IF DELETE-RECORD
                   IF MASTER-FOUND
                       PERFORM 330-DELETE-INVENTORY-RECORD
                   ELSE
                       PERFORM 380-WRITE-ERROR-TRANSACTION
               ELSE IF ADD-RECORD
                   IF MASTER-FOUND
                       PERFORM 380-WRITE-ERROR-TRANSACTION
                   ELSE
                       PERFORM 340-ADD-EMPLOYEE-RECORD
               ELSE IF CHANGE-RECORD
                   IF MASTER-FOUND
                       PERFORM 360-CHANGE-INVENTORY-RECORD
                   ELSE
                       PERFORM 380-WRITE-ERROR-TRANSACTION.

      *****************************************************************
      * Reads in a transaction record from the transaction file. If the
      * end of the file is reached, the transaction EOF switch is set to
      * true.
      *****************************************************************
       310-READ-INVENTORY-TRANSACTION.

           READ EMPTRAN INTO EMPLOYEE-TRANSACTION
               AT END
                   SET TRANSACTION-EOF TO TRUE.

      *****************************************************************
      * Reads in a record from the index file based on the employee ID 
      * from the transaction record. If a record with the employee ID is
      * not found, the master found switch is set to false.
      *****************************************************************
       320-READ-INVENTORY-MASTER.

           MOVE ET-EMPLOYEE-ID  TO IR-EMPLOYEE-ID.
           READ EMPMASTI INTO EMPLOYEE-MASTER-RECORD
               INVALID KEY
                   MOVE "N" TO MASTER-FOUND-SWITCH
               NOT INVALID KEY
                   SET MASTER-FOUND TO TRUE.

      *****************************************************************
      * Deletes a record from the index file. The record to be deleted
      * is based on the employee ID from the transaction record.
      *****************************************************************
       330-DELETE-INVENTORY-RECORD.

           DELETE EMPMASTI.

      *****************************************************************
      * Adds a record to the index file. The information for the new 
      * record is based on the employee information from the transaction
      * record. Vacation hours and sick hours are set to zero for a new
      * employee.
      *****************************************************************
       340-ADD-EMPLOYEE-RECORD.

           MOVE ET-EMPLOYEE-ID        TO EM-EMPLOYEE-ID.
           MOVE ET-EMPLOYEE-NAME      TO EM-EMPLOYEE-NAME.
           MOVE ET-DEPART-CODE        TO EM-DEPART-CODE.
           MOVE ET-JOB-CLASS          TO EM-JOB-CLASS.
           MOVE ET-ANNUAL-SALARY      TO EM-ANNUAL-SALARY.
           MOVE ZERO                  TO EM-VACATION-HOURS.
           MOVE ZERO                  TO EM-SICK-HOURS.
           PERFORM 350-WRITE-INVENTORY-RECORD.

      *****************************************************************
      * Changes a record in the index file. The record to be changed is
      * based on the employee ID from the transaction record. Only 
      * fields with information in the transaction record are updated in
      * the index file. If a field in the transaction record is blank or
      * zero, the corresponding field in the index file is not updated.
      *****************************************************************
       350-WRITE-INVENTORY-RECORD.

           WRITE INVENTORY-RECORD-AREA FROM EMPLOYEE-MASTER-RECORD
               INVALID KEY
                   DISPLAY "WRITE ERROR ON EMPMASTI FOR EMPLOYEE ID "
                       IR-EMPLOYEE-ID
                   SET TRANSACTION-EOF TO TRUE.

      *****************************************************************
      * Rewrites a record in the index file. The record to be rewritten
      * is based on the employee ID from the transaction record. Only
      * fields with information in the transaction record are updated in
      * the index file. If a field in the transaction record is blank or
      * zero, the corresponding field in the index file is not updated.
      *****************************************************************
       360-CHANGE-INVENTORY-RECORD.

           IF ET-EMPLOYEE-NAME  NOT = SPACE
               MOVE ET-EMPLOYEE-NAME  TO EM-EMPLOYEE-NAME.
           IF ET-DEPART-CODE NOT = ZERO
               MOVE ET-DEPART-CODE TO EM-DEPART-CODE.
           IF ET-JOB-CLASS NOT = ZERO
               MOVE ET-JOB-CLASS TO EM-JOB-CLASS .
           IF ET-ANNUAL-SALARY NOT = ZERO
               MOVE ET-ANNUAL-SALARY TO EM-ANNUAL-SALARY.
           PERFORM 370-REWRITE-EMPLOYEE-RECORD.

      *****************************************************************
      * Rewrites a record in the index file. The record to be rewritten
      * is based on the employee ID from the transaction record. This is
      * used for both change transactions and add transactions. For 
      * change transactions, only fields with information in the
      * transaction record are updated in the index file
      *****************************************************************  
       370-REWRITE-EMPLOYEE-RECORD.

           REWRITE INVENTORY-RECORD-AREA FROM EMPLOYEE-MASTER-RECORD.

      *****************************************************************
      * Writes an error transaction to the error file. The information
      * for the error transaction is based on the employee information
      * from the transaction record. If an error occurs when writing to
      * the error file, an error message is displayed and the
      * transaction EOF switch is set to true.
      *****************************************************************
       380-WRITE-ERROR-TRANSACTION.

           WRITE ERROR-TRANSACTION FROM EMPLOYEE-MASTER-RECORD.
           IF NOT ERRTRAN-SUCCESSFUL
               DISPLAY "WRITE ERROR ON ERRTRAN FOR EMPLOYEE ID "
                   ET-EMPLOYEE-ID
               DISPLAY "FILE STATUS CODE IS " ERRTRAN-FILE-STATUS
               SET TRANSACTION-EOF TO TRUE.

