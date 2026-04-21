      *****************************************************************
      * Title..........: SEQ3000 - Employee Maintenance
      * Programmer.....: Ben Stearns
      * Date...........: 4-20-26
      * GitHub URL.....: https://github.com/bstearns07/SEQ3000
      * Program Desc...: Updates an old employee master file depicting
      *                  employee information using Add/Change/Delete
      *                  transactions, then writes the updated information
      *                  into a new master file
      * File Desc......: Define the sole source code for application
      ***************************************************************** 
       
       IDENTIFICATION DIVISION.

       PROGRAM-ID.  SEQ3000.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT EMPTRAN  ASSIGN TO EMPTRAN.
           SELECT OLDEMP  ASSIGN TO OLDEMP.
           SELECT NEWEMP  ASSIGN TO NEWEMP
                           FILE STATUS IS NEWMAST-FILE-STATUS.
           SELECT ERRTRAN  ASSIGN TO ERRTRAN
                           FILE STATUS IS ERRTRAN-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD  EMPTRAN.

       01  TRANSACTION-RECORD      PIC X(50).

       FD  OLDEMP.

       01  OLD-MASTER-RECORD       PIC X(57).

       FD  NEWEMP.

       01  NEW-MASTER-RECORD.

           05  NM-EMPLOYEE-ID              PIC X(5).
           05  NM-EMPLOYEE-NAME            PIC X(30).
           05  NM-DEPART-CODE              PIC X(5).
           05  NM-JOB-CLASS                PIC X(2).
           05  NM-ANNUAL-SALARY            PIC 9(5)V99.
           05  NM-VACATION-HOURS           PIC 9(3).
           05  NM-SICK-HOURS               PIC 9(3)V99.

       FD     ERRTRAN.

       01  ERROR-TRANSACTION       PIC X(50).

       WORKING-STORAGE SECTION.

       01  SWITCHES.
           05  ALL-RECORDS-PROCESSED-SWITCH    PIC X   VALUE "N".
               88  ALL-RECORDS-PROCESSED               VALUE "Y".
           05  NEED-TRANSACTION-SWITCH         PIC X   VALUE "Y".
               88  NEED-TRANSACTION                    VALUE "Y".
           05  NEED-MASTER-SWITCH              PIC X   VALUE "Y".
               88  NEED-MASTER                         VALUE "Y".
           05  WRITE-MASTER-SWITCH             PIC X   VALUE "N".
               88  WRITE-MASTER                        VALUE "Y".

       01  FILE-STATUS-FIELDS.
           05  NEWMAST-FILE-STATUS     PIC XX.
               88  NEWMAST-SUCCESSFUL          VALUE "00".
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

      ******************************************************************
      *    Main processing loop. Opens the all input/output files, then
      *    repeatedly calls the employee record maintenance routine til
      *    all records have been processed. Finally, closes all files &
      *    terminates the program.
      ******************************************************************
       000-MAINTAIN-INVENTORY-FILE.

           OPEN INPUT  OLDEMP
                       EMPTRAN
                OUTPUT NEWEMP
                       ERRTRAN.
           PERFORM  300-MAINTAIN-EMPLOYEE-RECORD
               UNTIL ALL-RECORDS-PROCESSED.
           CLOSE EMPTRAN
                 OLDEMP
                 NEWEMP
                 ERRTRAN.
           STOP RUN.

      ******************************************************************
      *    Initializes the master record for reading in input file info,
      *    then reads in the next transaction and master record as 
      *    needed, checks for a match, and either applies the 
      *    transaction to the read-in variables or keeps the master
      *    record as is. Finally, writes out the new master record once
      *    functions are complete.
      ******************************************************************
       300-MAINTAIN-EMPLOYEE-RECORD.
      *    Wipe any old data from the master record buffer
           MOVE SPACES TO NEW-MASTER-RECORD
           MOVE ZEROS  TO NM-ANNUAL-SALARY
                          NM-VACATION-HOURS
                          NM-SICK-HOURS

      *    READ IN EMPTRAN RECORD
           IF NEED-TRANSACTION
               PERFORM 310-READ-INVENTORY-TRANSACTION
               MOVE "N" TO NEED-TRANSACTION-SWITCH.
           IF NEED-MASTER
               PERFORM 320-READ-OLD-MASTER
               MOVE "N" TO NEED-MASTER-SWITCH.
      *    CHECK FOR A MATCH
           PERFORM 330-MATCH-MASTER-TRAN.
           IF WRITE-MASTER
               PERFORM 340-WRITE-NEW-MASTER
               MOVE "N" TO WRITE-MASTER-SWITCH.

      *****************************************************************
      *    Reads in the next transaction record from the transaction
      *    file. If at end of file, sets the employee ID field to high
      *    values to represents all transactions have been processed
      *****************************************************************
       310-READ-INVENTORY-TRANSACTION.

           READ EMPTRAN INTO EMPLOYEE-TRANSACTION
               AT END
                   MOVE HIGH-VALUE TO    ET-EMPLOYEE-ID.

      *****************************************************************
      *    Reads in the next master record from the old master file. If
      *    at end of file, sets the employee ID field to high values to
      *    represents all master records have been processed
      *****************************************************************
       320-READ-OLD-MASTER.

           READ OLDEMP INTO EMPLOYEE-MASTER-RECORD
               AT END
                   MOVE HIGH-VALUES TO EM-EMPLOYEE-ID.
      
      *****************************************************************
      *    Compares the employee ID fields of the transaction and master
      *    records to determine if the transaction should be applied to
      *    the master record, if the master record should be written as
      *    is, or if the transaction should be written to the error file
      *****************************************************************
       330-MATCH-MASTER-TRAN.

           IF EM-EMPLOYEE-ID > ET-EMPLOYEE-ID
               PERFORM 350-PROCESS-HI-MASTER
           ELSE IF EM-EMPLOYEE-ID < ET-EMPLOYEE-ID
               PERFORM 360-PROCESS-LO-MASTER
           ELSE
               PERFORM 370-PROCESS-MAST-TRAN-EQUAL.

      *****************************************************************
      *    Writes out the new master record to the new master file. If a
      *    write error occurs, writes out the transaction to the error
      *    file and sets the switch to end processing of all records
      *****************************************************************
       340-WRITE-NEW-MASTER.

           WRITE NEW-MASTER-RECORD.
           IF NOT NEWMAST-SUCCESSFUL
               DISPLAY "WRITE ERROR ON NEWMAST FOR ITEM NUMBER "
                   NM-EMPLOYEE-ID
               DISPLAY "FILE STATUS CODE IS " NEWMAST-FILE-STATUS
               SET ALL-RECORDS-PROCESSED TO TRUE.

      *****************************************************************
      *    If the master record employee ID is higher than the 
      *    transaction record employee ID, then the transaction record 
      *    has no master record. Checks to see if the transaction is an
      *    add operation, and if so adds the transaction to the new
      *    master record. If not, writes the transaction to the error
      *    file
      *****************************************************************
       350-PROCESS-HI-MASTER.

           IF ADD-RECORD
               PERFORM 380-APPLY-ADD-TRANSACTION
           ELSE
               PERFORM 390-WRITE-ERROR-TRANSACTION.

      *****************************************************************
      *    If the master record employee ID is lower than the 
      *    transaction record employee ID, then the master record has 
      *    no transaction record. Writes the master record to the new 
      *    master file as is, then sets the switch to read in the next 
      *    master record on the next loop through
      *****************************************************************
       360-PROCESS-LO-MASTER.

           MOVE SPACES TO NEW-MASTER-RECORD
           MOVE EM-EMPLOYEE-ID       TO NM-EMPLOYEE-ID
           MOVE EM-EMPLOYEE-NAME     TO NM-EMPLOYEE-NAME
           MOVE EM-DEPART-CODE       TO NM-DEPART-CODE
           MOVE EM-JOB-CLASS         TO NM-JOB-CLASS
           MOVE EM-ANNUAL-SALARY     TO NM-ANNUAL-SALARY
           MOVE EM-VACATION-HOURS    TO NM-VACATION-HOURS
           MOVE EM-SICK-HOURS        TO NM-SICK-HOURS
           SET WRITE-MASTER TO TRUE.
           SET NEED-MASTER TO TRUE.

      *****************************************************************
      *    If read-in employee ID is HIGH VALUES, all transactions have
      *    been processed, so sets the switch to end processing of all
      *    records. If not, checks to see if the transaction is a delete
      *    or change, and performs the appropriate processing. If 
      *    neither applies, writes the transaction to the error file
      *****************************************************************
       370-PROCESS-MAST-TRAN-EQUAL.
      *    CHECK IF AT END OF FILE
           IF EM-EMPLOYEE-ID = HIGH-VALUES
               SET ALL-RECORDS-PROCESSED TO TRUE
           ELSE
               IF DELETE-RECORD
                   PERFORM 400-APPLY-DELETE-TRANSACTION
               ELSE
                   IF CHANGE-RECORD
                       PERFORM 410-APPLY-CHANGE-TRANSACTION
                   ELSE
                       PERFORM 390-WRITE-ERROR-TRANSACTION.

      *****************************************************************
      *    If the transaction is an add transaction, moves the 
      *    transaction fields to the new master record fields, sets the 
      *    vacation and sick hours to zero, and sets the switch to write
      *    out the new master and get the next transaction record
      *****************************************************************
       380-APPLY-ADD-TRANSACTION.

           MOVE ET-EMPLOYEE-ID TO NM-EMPLOYEE-ID.
           MOVE ET-EMPLOYEE-NAME TO NM-EMPLOYEE-NAME.
           MOVE ET-DEPART-CODE TO NM-DEPART-CODE.
           MOVE ET-JOB-CLASS TO NM-JOB-CLASS.
           MOVE ET-ANNUAL-SALARY TO NM-ANNUAL-SALARY.
           MOVE ZERO TO NM-VACATION-HOURS.
           MOVE ZERO TO NM-SICK-HOURS.
           SET WRITE-MASTER TO TRUE.
           SET NEED-TRANSACTION TO TRUE.

      *****************************************************************
      *    If the transaction is an invalid transaction (not an add
      *    transaction with a high master record, not a delete or change
      *    transaction with an equal master record), writes the 
      *    transaction to the error file and sets the switch to end 
      *    processing of all records
      *****************************************************************
       390-WRITE-ERROR-TRANSACTION.

           WRITE ERROR-TRANSACTION FROM EMPLOYEE-TRANSACTION.
           IF NOT ERRTRAN-SUCCESSFUL
               DISPLAY "WRITE ERROR ON ERRTRAN FOR EMPLOYEE ID "
                   ET-EMPLOYEE-ID
               DISPLAY "FILE STATUS CODE IS " ERRTRAN-FILE-STATUS
               SET ALL-RECORDS-PROCESSED TO TRUE
           ELSE
               SET NEED-TRANSACTION TO TRUE.

      *****************************************************************
      *    If the transaction is a delete transaction, sets the switch 
      *    to get the next master and transaction records without
      *    writing anything, effectively deleting the master record 
      *    from the new master file.
      *****************************************************************
       400-APPLY-DELETE-TRANSACTION.

           SET NEED-MASTER TO TRUE.
           SET NEED-TRANSACTION TO TRUE.

      *****************************************************************
      *    If the transaction is a change transaction, moves the master
      *    record fields to the new master record fields, then applies
      *    any changes from the transaction record to the new master 
      *    record fields. Finally, sets the switch to write out the new
      *    master record and get the next transaction record on the next
      *    loop through
      *****************************************************************
       410-APPLY-CHANGE-TRANSACTION.

      *    copy existing master record to new master record
           MOVE EM-EMPLOYEE-ID       TO NM-EMPLOYEE-ID
           MOVE EM-EMPLOYEE-NAME     TO NM-EMPLOYEE-NAME
           MOVE EM-DEPART-CODE       TO NM-DEPART-CODE
           MOVE EM-JOB-CLASS         TO NM-JOB-CLASS
           MOVE EM-ANNUAL-SALARY     TO NM-ANNUAL-SALARY
           MOVE EM-VACATION-HOURS    TO NM-VACATION-HOURS
           MOVE EM-SICK-HOURS        TO NM-SICK-HOURS

      *    apply changes from transaction record to master record
           IF ET-EMPLOYEE-NAME NOT = SPACES
               MOVE ET-EMPLOYEE-NAME TO NM-EMPLOYEE-NAME.
           IF ET-DEPART-CODE NOT = SPACES
               MOVE ET-DEPART-CODE TO NM-DEPART-CODE.
           IF ET-JOB-CLASS NOT = SPACES
               MOVE ET-JOB-CLASS TO NM-JOB-CLASS.
           IF ET-ANNUAL-SALARY NOT = ZERO
               MOVE ET-ANNUAL-SALARY  TO NM-ANNUAL-SALARY.
           SET NEED-TRANSACTION TO TRUE.
           SET WRITE-MASTER TO TRUE.
           SET NEED-MASTER TO TRUE.
