      SUBROUTINE BAS1DF(ISUM,HEADNG,NPER,ITMUNI,TOTIM,NCOL,NROW,
     1       NLAY,NODES,INBAS,IOUT,IUNIT)
C
C-----VERSION 1513 12MAY1987 BAS1DF
C     ******************************************************************
C     DEFINE KEY MODEL PARAMETERS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*4 HEADNG
      DIMENSION HEADNG(32),IUNIT(24)
C     ------------------------------------------------------------------
C
C1------PRINT THE NAME OF THE PROGRAM.
C1S1--SEAWAT: WRITE NAME OF PROGRAM
      write(iout, *)' *************************************************'
      write(iout, *)' *       NUMERICAL SIMULATION USING SEAWAT       *'
      write(iout, *)' *************************************************'

C2------READ AND PRINT A HEADING.
      READ(INBAS,2) HEADNG
    2 FORMAT(20A4)
      WRITE(IOUT,3) HEADNG
    3 FORMAT(1H0,32A4)
C
C3------READ NUMBER OF LAYERS,ROWS,COLUMNS,STRESS PERIODS AND
C3------UNITS OF TIME CODE.
      READ(INBAS,4) NLAY,NROW,NCOL,NPER,ITMUNI
    4 FORMAT(8I10)
C
C4------PRINT # OF LAYERS, ROWS, COLUMNS AND STRESS PERIODS.
      WRITE(IOUT,5) NLAY,NROW,NCOL
    5 FORMAT(1X,I4,' LAYERS',I10,' ROWS',I10,' COLUMNS')
      WRITE(IOUT,6) NPER
    6 FORMAT(1X,I3,' STRESS PERIOD(S) IN SIMULATION')
C
C5------SELECT AND PRINT A MESSAGE SHOWING TIME UNITS.
      IF(ITMUNI.LT.0 .OR. ITMUNI.GT.5) ITMUNI=0
      GO TO (10,20,30,40,50),ITMUNI
      WRITE(IOUT,9)
    9 FORMAT(1X,'MODEL TIME UNITS ARE UNDEFINED')
      GO TO 100
   10 WRITE(IOUT,11)
   11 FORMAT(1X,'MODEL TIME UNIT IS SECONDS')
      GO TO 100
   20 WRITE(IOUT,21)
   21 FORMAT(1X,'MODEL TIME UNIT IS MINUTES')
      GO TO 100
   30 WRITE(IOUT,31)
   31 FORMAT(1X,'MODEL TIME UNIT IS HOURS')
      GO TO 100
   40 WRITE(IOUT,41)
   41 FORMAT(1X,'MODEL TIME UNIT IS DAYS')
      GO TO 100
   50 WRITE(IOUT,51)
   51 FORMAT(1X,'MODEL TIME UNIT IS YEARS')
C
C6------READ & PRINT INPUT UNIT NUMBERS (IUNIT) FOR MAJOR OPTIONS.
  100 READ(INBAS,101) IUNIT
  101 FORMAT(24I3)
      WRITE(IOUT,102) (I,I=1,24),IUNIT
  102 FORMAT(1H0,'I/O UNITS:'/1X,'ELEMENT OF IUNIT:',24I3,
     1                       /1X,'        I/O UNIT:',24I3)
C
C7------INITIALIZE TOAL ELAPSED TIME COUNTER STORAGE ARRAY COUNTER
C7------AND CALCULATE NUMBER OF CELLS.
      TOTIM=0.
      ISUM=1
      NODES=NCOL*NROW*NLAY
C
C8------RETURN
      RETURN
      END
      SUBROUTINE BAS1AL(ISUM,LENX,LCHNEW,LCHOLD,LCIBOU,LCCR,LCCC,LCCV,
     1            LCHCOF,LCRHS,LCDELR,LCDELC,LCSTRT,LCBUFF,LCIOFL,INBAS,
     1            ISTRT,NCOL,NROW,NLAY,IOUT)
C-----VERSION 1515 12MAY1987 BAS1AL
C     ******************************************************************
C     ALLOCATE SPACE FOR BASIC MODEL ARRAYS
C     ******************************************************************
C
C        SPECIFICATIONS:
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C1------PRINT A MESSAGE IDENTIFYING THE PACKAGE.
      WRITE(IOUT,1)INBAS
    1 FORMAT(1H0,'BAS1 -- BASIC MODEL PACKAGE, VERSION 1, 9/1/87',
     2' INPUT READ FROM UNIT',I3)
C
C2------READ & PRINT FLAG IAPART (RHS & BUFFER SHARE SPACE?) AND
C2------FLAG ISTRT (SHOULD STARTING HEADS BE SAVED FOR DRAWDOWN?)
      READ(INBAS,2) IAPART,ISTRT
    2 FORMAT(2I10)
      IF(IAPART.EQ.0) WRITE(IOUT,3)
    3 FORMAT(1X,'ARRAYS RHS AND BUFF WILL SHARE MEMORY.')
      IF(ISTRT.NE.0) WRITE(IOUT,4)
    4 FORMAT(1X,'START HEAD WILL BE SAVED')
      IF(ISTRT.EQ.0) WRITE(IOUT,5)
    5 FORMAT(1X,'START HEAD WILL NOT BE SAVED',
     1      ' -- DRAWDOWN CANNOT BE CALCULATED')
C
C3------STORE,IN ISOLD, LOCATION OF FIRST UNALLOCATED SPACE IN X.
      ISOLD=ISUM
      NRCL=NROW*NCOL*NLAY
C
C4------ALLOCATE SPACE FOR ARRAYS.
      LCHNEW=ISUM
      ISUM=ISUM+2*NRCL
      LCHOLD=ISUM
      ISUM=ISUM+NRCL
      LCIBOU=ISUM
      ISUM=ISUM+NRCL
      LCCR=ISUM
      ISUM=ISUM+NRCL
      LCCC=ISUM
      ISUM=ISUM+NRCL
      LCCV=ISUM
      ISUM=ISUM+NROW*NCOL*(NLAY-1)
      LCHCOF=ISUM
      ISUM=ISUM+NRCL
      LCRHS=ISUM
      ISUM=ISUM+NRCL
      LCDELR=ISUM
      ISUM=ISUM+NCOL
      LCDELC=ISUM
      ISUM=ISUM+NROW
      LCIOFL=ISUM
      ISUM=ISUM+NLAY*4
C
C5------IF BUFFER AND RHS SHARE SPACE THEN LCBUFF=LCRHS.
      LCBUFF=LCRHS
      IF(IAPART.EQ.0) GO TO 50
      LCBUFF=ISUM
      ISUM=ISUM+NRCL
C
C6------IF STRT WILL BE SAVED THEN ALLOCATE SPACE.
   50 LCSTRT=ISUM
      IF(ISTRT.NE.0) ISUM=ISUM+NRCL
      ISP=ISUM-ISOLD
C
C7------PRINT AMOUNT OF SPACE USED.
      WRITE(IOUT,6) ISP
    6 FORMAT(1X,I8,' ELEMENTS IN X ARRAY ARE USED BY BAS')
      ISUM1=ISUM-1
      WRITE(IOUT,7) ISUM1,LENX
    7 FORMAT(1X,I8,' ELEMENTS OF X ARRAY USED OUT OF',I8)
      IF(ISUM1.GT.LENX) WRITE(IOUT,8)
    8 FORMAT(1X,'   ***X ARRAY MUST BE DIMENSIONED LARGER***')
C
C
C8------RETURN
      RETURN
C
      END

      SUBROUTINE BAS1AD(DELT,TSMULT,TOTIM,PERTIM,HNEW,HOLD,KSTP,
     1                  NCOL,NROW,NLAY)
C
C-----VERSION 1412 22FEB1982 BAS1AD, modified for seawater model
C
C     ******************************************************************
C     ADVANCE TO NEXT TIME STEP
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      DIMENSION HNEW(NCOL,NROW,NLAY), HOLD(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------IF NOT FIRST TIME STEP THEN CALCULATE TIME STEP LENGTH.
C1S1--SEAWAT: REMOVED THIS SECTION
C--SEAWAT: IF(KSTP.NE.1) DELT=TSMULT*DELT

C2------ACCUMULATE ELAPSED TIME IN SIMULATION(TOTIM) AND IN THIS
C2------STRESS PERIOD(PERTIM).
          TOTIM=TOTIM+DELT
          PERTIM=PERTIM+DELT

C
C3------COPY HNEW TO HOLD.
      DO 10 K=1,NLAY
      DO 10 I=1,NROW
      DO 10 J=1,NCOL
   10 HOLD(J,I,K)=HNEW(J,I,K)
C
C4------RETURN
      RETURN
      END
      SUBROUTINE BAS1FM(HCOF,RHS,NODES)
C
C
C-----VERSION 1632 24JUL1987 BAS1FM
C     ******************************************************************
C     SET HCOF=RHS=0.
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION HCOF(NODES),RHS(NODES)
C     ------------------------------------------------------------------
C
C1------FOR EACH CELL INITIALIZE HCOF AND RHS ACCUMULATORS.
      DO 100 I=1,NODES
      HCOF(I)=0.
      RHS(I)=0.
  100 CONTINUE
C
C2------RETURN
      RETURN
      END
      SUBROUTINE BAS1OC(NSTP,KSTP,ICNVG,IOFLG,NLAY,
     1      IBUDFL,ICBCFL,IHDDFL,INOC,IOUT)
C
C-----VERSION 1632 24JUL1987 BAS1OC
C     ******************************************************************
C     OUTPUT CONTROLLER FOR HEAD, DRAWDOWN, AND BUDGET
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION IOFLG(NLAY,4)
C     ------------------------------------------------------------------
C
C
C1------TEST UNIT NUMBER (INOC (INOC=IUNIT(12))) TO SEE IF
C1------OUTPUT CONTROL IS ACTIVE.
      IF(INOC.NE.0)GO TO 500
C
C2------IF OUTPUT CONTROL IS INACTIVE THEN SET DEFAULTS AND RETURN.
      IHDDFL=0
      IF(ICNVG.EQ.0 .OR. KSTP.EQ.NSTP)IHDDFL=1
      IBUDFL=0
      IF(ICNVG.EQ.0 .OR. KSTP.EQ.NSTP)IBUDFL=1
      ICBCFL=0
      GO TO 1000
C
C3-------READ AND PRINT OUTPUT FLAGS AND CODE FOR DEFINING IOFLG.
  500  continue

C3S1--SEAWAT: READ OC IF ITS FIRST TRANSPORT STEP IN STRESS PERIOD
        READ(INOC,1) INCODE,IHDDFL,IBUDFL,ICBCFL

    1 FORMAT(4I10)
      WRITE(IOUT,3) IHDDFL,IBUDFL,ICBCFL
    3 FORMAT(1H0,'HEAD/DRAWDOWN PRINTOUT FLAG =',I2,
     1    5X,'TOTAL BUDGET PRINTOUT FLAG =',I2,
     2    5X,'CELL-BY-CELL FLOW TERM FLAG =',I2)
C
C4------DECODE INCODE TO DETERMINE HOW TO SET FLAGS IN IOFLG.
      IF(INCODE) 100,200,300
C
C5------USE IOFLG FROM LAST TIME STEP.
  100 WRITE(IOUT,101)
  101 FORMAT(1H ,'REUSING PREVIOUS VALUES OF IOFLG')
      GO TO 600
C
C6------READ IOFLG FOR LAYER 1 AND ASSIGN SAME TO ALL LAYERS
  200    CONTINUE

C6S1--SEAWAT: READ OC IF FIRST TRANSPORT STEP IN THE STRESS PERIOD
      READ(INOC,201) (IOFLG(1,M),M=1,4)

  201 FORMAT(4I10)
      DO 210 K=1,NLAY
      IOFLG(K,1)=IOFLG(1,1)
      IOFLG(K,2)=IOFLG(1,2)
      IOFLG(K,3)=IOFLG(1,3)
      IOFLG(K,4)=IOFLG(1,4)
  210 CONTINUE
      WRITE(IOUT,211) (IOFLG(1,M),M=1,4)
  211 FORMAT(1H0,'OUTPUT FLAGS FOR ALL LAYERS ARE THE SAME:'/
     1   1X,'  HEAD    DRAWDOWN  HEAD  DRAWDOWN'/
     2   1X,'PRINTOUT  PRINTOUT  SAVE    SAVE'/
     3   1X,34('-')/1X,I5,I10,I8,I8)
      GO TO 600
C
C7------READ IOFLG IN ENTIRETY
  300    continue

C7S1--SEAWAT: READ OC IF FIRST TRANSPORT STEP
      READ(INOC,301) ((IOFLG(K,I),I=1,4),K=1,NLAY)

  301 FORMAT(4I10)
      WRITE(IOUT,302)
  302 FORMAT(1H0,'OUTPUT FLAGS FOR EACH LAYER:'/
     1   1X,'         HEAD    DRAWDOWN  HEAD  DRAWDOWN'/
     2   1X,'LAYER  PRINTOUT  PRINTOUT  SAVE    SAVE'/
     3   1X,41('-'))
      WRITE(IOUT,303) (K,(IOFLG(K,I),I=1,4),K=1,NLAY)
  303 FORMAT(1X,I4,I8,I10,I8,I8)
C
C8------THE LAST STEP IN A STRESS PERIOD AND STEPS WHERE ITERATIVE
C8------PROCEDURE FAILED TO CONVERGE GET A VOLUMETRIC BUDGET.
  600 IF(ICNVG.EQ.0 .OR. KSTP.EQ.NSTP) IBUDFL=1
C
C9------RETURN
 1000 RETURN
      END
      SUBROUTINE BAS1OT(HNEW,STRT,ISTRT,BUFF,IOFLG,MSUM,IBOUND,VBNM,
     1 VBVL,ntr,KSTP,KPER,DELT,PERTIM,TOTIM,ITMUNI,NCOL,NROW,NLAY,ICNVG,
     2  IHDDFL,IBUDFL,IHEDFM,IHEDUN,IDDNFM,IDDNUN,IOUT,PRTOUT,STEPEND,
     3  dtrans)
C-----VERSION 1522 12MAY1987 BAS1OT
C     ******************************************************************
C     OUTPUT TIME, VOLUMETRIC BUDGET, HEAD, AND DRAWDOWN
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*4 VBNM

C0S1--SEAWAT: LOGICAL
        LOGICAL PRTOUT,STEPEND
C
      DIMENSION HNEW(NCOL,NROW,NLAY),STRT(NCOL,NROW,NLAY),
     1          VBNM(4,20),VBVL(4,20),IOFLG(NLAY,4),
     2          IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY)
C     ------------------------------------------------------------------
C
C1------CLEAR PRINTOUT FLAG (IPFLG)
      IPFLG=0
C
C2------IF ITERATIVE PROCEDURE FAILED TO CONVERGE PRINT MESSAGE
C2S1--SEAWAT: PRINTING 'TRANSPORT STEP'  TIME STEP and Stress Period
      IF(ICNVG.EQ.0) WRITE(IOUT,1) ntr, KSTP,KPER
    1 FORMAT(1H0,10X,'****FAILED TO CONVERGE IN TRANSPORT STEP',I3,
     1      ' OF TIME STEP',I3,' OF STRESS PERIOD',I3,'****')
C
C3------IF HEAD AND DRAWDOWN FLAG (IHDDFL) IS SET WRITE HEAD AND
C3------DRAWDOWN IN ACCORDANCE WITH FLAGS IN IOFLG.
C3S1--SEAWAT: PRINT HEAD AND DRAWDOWNS IF PRTOUT
cwxg      IF((IHDDFL.EQ.0.OR..NOT.PERDONE).AND.(.NOT.PRTOUT)) GO TO 100
      IF(IHDDFL.EQ.0.OR..NOT.STEPEND) GO TO 100

C
      CALL SBAS1H(HNEW,BUFF,IOFLG,NTR,KSTP,KPER,NCOL,NROW,  !pasing NTR
     1    NLAY,IOUT,IHEDFM,IHEDUN,IPFLG,PERTIM,TOTIM)

      CALL SBAS1D(HNEW,BUFF,IOFLG,NTR,KSTP,KPER,NCOL,NROW,NLAY,IOUT, !passing NTR
     1 IDDNFM,IDDNUN,STRT,ISTRT,IBOUND,IPFLG,PERTIM,TOTIM)
C
C4------PRINT TOTAL BUDGET IF REQUESTED
C4S1--SEAWAT: OUTPUT BUDGET IF PRTOUT
cwxg  100 IF((IBUDFL.EQ.0.OR..NOT.PERDONE).AND.(.NOT.PRTOUT)) GO TO 120
  100 IF(IBUDFL.EQ.0.OR..NOT.STEPEND) GO TO 120

      CALL SBAS1V(MSUM,VBNM,VBVL,NTR,KSTP,KPER,IOUT)      !passing NTR
      IPFLG=1
C
C5------END PRINTOUT WITH TIME SUMMARY AND FORM FEED IF ANY PRINTOUT
C5------WILL BE PRODUCED.
  120 IF(IPFLG.EQ.0) RETURN
      CALL SBAS1T(KSTP,KPER,DELT,PERTIM,TOTIM,ITMUNI,IOUT, NTR,dtrans) !passing ntr and dtrans
      WRITE(IOUT,101)
  101 FORMAT(1H1)
C
C6------RETURN
      RETURN
      END

      SUBROUTINE BAS1RP(IBOUND,HNEW,STRT,HOLD,ISTRT,INBAS,
     1    HEADNG,NCOL,NROW,NLAY,NODES,VBVL,IOFLG,INOC,IHEDFM,
     2    IDDNFM,IHEDUN,IDDNUN,IOUT)
C-----VERSION 1628 15MAY1987 BAS1RP
C     ******************************************************************
C     READ AND INITIALIZE BASIC MODEL ARRAYS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*4 HEADNG,ANAME
C
      DIMENSION HNEW(NODES),IBOUND(NODES),STRT(NODES),HOLD(NODES),
     1             ANAME(6,2),VBVL(4,20),IOFLG(NLAY,4),HEADNG(32)
C
      DATA ANAME(1,1),ANAME(2,1),ANAME(3,1),ANAME(4,1),ANAME(5,1),
     1   ANAME(6,1) /'    ','    ','  BO','UNDA','RY A','RRAY'/
      DATA ANAME(1,2),ANAME(2,2),ANAME(3,2),ANAME(4,2),ANAME(5,2),
     1   ANAME(6,2) /'    ','    ','    ','INIT','IAL ','HEAD'/
C     ------------------------------------------------------------------
C
C1------PRINT SIMULATION TITLE, CALCULATE # OF CELLS IN A LAYER.
      WRITE(IOUT,1) HEADNG
    1 FORMAT(1H1,32A4)
      NCR=NCOL*NROW
C
C2------READ BOUNDARY ARRAY(IBOUND) ONE LAYER AT A TIME.
      DO 100 K=1,NLAY
      KK=K
      LOC=1+(K-1)*NCR
      CALL U2DINT(IBOUND(LOC),ANAME(1,1),NROW,NCOL,KK,INBAS,IOUT)
  100 CONTINUE
C
C3------READ AND PRINT HEAD VALUE TO BE PRINTED FOR NO-FLOW CELLS.
      READ(INBAS,2) TMP
    2 FORMAT(F10.0)
      HNOFLO=TMP
      WRITE(IOUT,3) TMP
    3 FORMAT(1H0,'AQUIFER HEAD WILL BE SET TO ',1PG11.5,
     1       ' AT ALL NO-FLOW NODES (IBOUND=0).')
C
C4------READ STARTING HEADS.
      DO 300 K=1,NLAY
      KK=K
      LOC=1+(K-1)*NCR
      CALL U2DREL(HOLD(LOC),ANAME(1,2),NROW,NCOL,KK,INBAS,IOUT)
  300 CONTINUE

CZ
C5------SET IBOUND=0 IF HOLD IS 1.E30 OR 888.88 OR HNOFLO
      DO 350 I=1,NODES
      IF(IBOUND(I).EQ.0) GOTO 350
      IF(HOLD(I).EQ.1.E30 .OR. HOLD(I).EQ.888.88 .OR.
     & HOLD(I).EQ.HNOFLO) IBOUND(I)=0
  350 CONTINUE
CZ
C5------COPY INITIAL HEADS FROM HOLD TO HNEW.
      DO 400 I=1,NODES
      HNEW(I)=HOLD(I)
      IF(IBOUND(I).EQ.0) HNEW(I)=HNOFLO
  400 CONTINUE
C
C6------IF STARTING HEADS ARE TO BE SAVED THEN COPY HOLD TO STRT.
      IF(ISTRT.EQ.0) GO TO 590
      DO 500 I=1,NODES
      STRT(I)=HOLD(I)
  500 CONTINUE
C
C7------INITIALIZE VOLUMETRIC BUDGET ACCUMULATORS TO ZERO.
  590 DO 600 I=1,20
      DO 600 J=1,4
      VBVL(J,I)=0.
  600 CONTINUE
C
C8------SET UP OUTPUT CONTROL.
      CALL SBAS1I(NLAY,ISTRT,IOFLG,INOC,IOUT,IHEDFM,
     1         IDDNFM,IHEDUN,IDDNUN)
C
C9------RETURN
 1000 RETURN
      END

      SUBROUTINE BAS1ST(NSTP,TSMULT,PERTIM,KPER,INBAS,IOUT)
C-----VERSION 1614 08SEP1982 BAS1ST
C     ******************************************************************
C     SETUP TIME PARAMETERS FOR NEW TIME PERIOD
C     ******************************************************************
C
C        SPECIFICATIONS:
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C1------READ LENGTH OF STRESS PERIOD, NUMBER OF TIME STEPS AND.
C1------TIME STEP MULTIPLIER.
C--SEAWAT: FOLLOWING LINES COMMENTED: INFO READ FROM BTN PACKAGE
C      READ (INBAS,1) PERLEN,NSTP,TSMULT
C    1 FORMAT(F10.0,I10,F10.0)
      PERTIM=0.
C
C5------RETURN
      RETURN
      END

      SUBROUTINE SBAS1D(HNEW,BUFF,IOFLG,ntr,KSTP,KPER,NCOL,NROW,
     1    NLAY,IOUT,IDDNFM,IDDNUN,STRT,ISTRT,IBOUND,IPFLG,
     2    PERTIM,TOTIM)
C-----VERSION 1630 15MAY1987 SBAS1D
C     *******************************************************
C     CALCULATE PRINT AND RECORD DRAWDOWNS
C     *******************************************************
C
C        SPECIFICATIONS
C     -------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*4 TEXT
C
      DIMENSION HNEW(NCOL,NROW,NLAY),IOFLG(NLAY,4),TEXT(4),
     1     BUFF(NCOL,NROW,NLAY),STRT(NCOL,NROW,NLAY),
     2     IBOUND(NCOL,NROW,NLAY)
C
      DATA TEXT(1),TEXT(2),TEXT(3),TEXT(4) /'    ','    ','DRAW',
     1       'DOWN'/
C     -------------------------------------------------------
C
C1------FOR EACH LAYER CALCULATE DRAWDOWN IF PRINT OR RECORD
C1------IS REQUESTED
      DO 59 K=1,NLAY
C
C2------IS DRAWDOWN NEEDED FRO THIS LAYER?
      IF(IOFLG(K,2).EQ.0 .AND. IOFLG(K,4).EQ.0) GO TO 59
C
C3------DRAWDOWN IS NEEDED. WERE STARTING HEADS SAVED?
      IF(ISTRT.NE.0) GO TO 53
C
C4------STARTING HEADS WERE NOT SAVED. PRINT MESSAGE AND STOP.
      WRITE(IOUT,52)
   52 FORMAT(1H0,'CANNOT CALCULATE DRAWDOWN BECAUSE START',
     1   ' HEADS WERE NOT SAVED')
      STOP
C
C5------CALCULATE DRAWDOWN FOR THE LAYER.
   53 DO 58 I=1,NROW
      DO 58 J=1,NCOL
      HSING=HNEW(J,I,K)
      BUFF(J,I,K)=HSING
      IF(IBOUND(J,I,K).NE.0) BUFF(J,I,K)=STRT(J,I,K)-HSING
   58 CONTINUE
   59 CONTINUE
C
C6------FOR EACH LAYER: DETERMINE IF DRAWDOWN SHOULD BE PRINTED.
C6------IF SO THEN CALL ULAPRS OR ULAPRW TO PRINT DRAWDOWN.
      DO 69 K=1,NLAY
      KK=K
      IF(IOFLG(K,2).EQ.0) GO TO 69
      IF(IDDNFM.LT.0) CALL ULAPRS(BUFF(1,1,K),TEXT(1),KSTP,KPER,
     1             NCOL,NROW,KK,-IDDNFM,IOUT)
      IF(IDDNFM.GE.0) CALL ULAPRW(BUFF(1,1,K),TEXT(1),KSTP,KPER,
     1             NCOL,NROW,KK,IDDNFM,IOUT)
      IPFLG=1
   69 CONTINUE
C
C7------FOR EACH LAYER: DETERMINE IF DRAWDOWN SHOULD BE RECORDED.
C7------IF SO THEN CALL ULASAV TO RECORD DRAWDOWN.
      IFIRST=1
      IF(IDDNUN.LE.0) GO TO 80
      DO 79 K=1,NLAY
      KK=K
      IF(IOFLG(K,4).LE.0) GO TO 79
      IF(IFIRST.EQ.1) WRITE(IOUT,74) IDDNUN,NTR,KSTP,KPER
C7S1--SEAWAT: CHANGING 'TIME STEP' TO 'TRANSPORT'
   74 FORMAT(1H0,'DRAWDOWN WILL BE SAVED ON UNIT',I3,
     1    ' AT END OF TRANSPORT STEP',I6,', TIME STEP',I3
     2    ', STRESS PERIOD',I3)
      IFIRST=0
      CALL ULASAV(BUFF(1,1,K),TEXT(1),KSTP,KPER,PERTIM,TOTIM,NCOL,
     1              NROW,KK,IDDNUN)
   79 CONTINUE
C
C8------RETURN
   80 RETURN
      END
      SUBROUTINE SBAS1H(HNEW,BUFF,IOFLG,ntr,KSTP,KPER,NCOL,NROW,
     1    NLAY,IOUT,IHEDFM,IHEDUN,IPFLG,PERTIM,TOTIM)
C
C-----VERSION 1653 15MAY1987 SBAS1H
C     *******************************************************
C     PRINT AND RECORD HEADS
C     *******************************************************
C
C        SPECIFICATIONS
C     -------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*4 TEXT
C
      DIMENSION HNEW(NCOL,NROW,NLAY),IOFLG(NLAY,4),TEXT(4),
     1     BUFF(NCOL,NROW,NLAY)
C
      DATA TEXT(1),TEXT(2),TEXT(3),TEXT(4) /'    ','    ','    ',
     1       'HEAD'/
C     -------------------------------------------------------
C
C1------FOR EACH LAYER: PRINT HEAD IF REQUESTED.
      DO 39 K=1,NLAY
      KK=K
C
C2------TEST IOFLG TO SEE IF HEAD SHOULD BE PRINTED.
      IF(IOFLG(K,1).EQ.0) GO TO 39
      IPFLG=1
C
C3------COPY HEADS FOR THIS LAYER INTO BUFFER.
      DO 32 I=1,NROW
      DO 32 J=1,NCOL
      BUFF(J,I,1)=HNEW(J,I,K)
   32 CONTINUE
C
C4------CALL UTILITY MODULE TO PRINT CONTENTS OF BUFFER.
      IF(IHEDFM.LT.0) CALL ULAPRS(BUFF,TEXT(1),KSTP,KPER,NCOL,NROW,KK,
     1          -IHEDFM,IOUT)
      IF(IHEDFM.GE.0) CALL ULAPRW(BUFF,TEXT(1),KSTP,KPER,NCOL,NROW,KK,
     1            IHEDFM,IOUT)
   39 CONTINUE
C
C5------IF UNIT FOR RECORDING HEADS <= 0: THEN RETURN.
      IF(IHEDUN.LE.0)GO TO 50
      IFIRST=1
C
C6------FOR EACH LAYER: RECORD HEAD IF REQUESTED.
      DO 49 K=1,NLAY
      KK=K
C
C7------CHECK IOFLG TO SEE IF HEAD FOR THIS LAYER SHOULD BE RECORDED.
      IF(IOFLG(K,3).LE.0) GO TO 49
      IF(IFIRST.EQ.1) WRITE(IOUT,41) IHEDUN,NTR,KSTP,KPER
C7--SEAWAT: CHANGING 'TIME' TO 'TRANSPORT', HEAD TO FRESHWATER HEAD
   41 FORMAT(1H0,'FRESHWATER HEAD WILL BE SAVED ON UNIT',I3,
     1    ' AT END OF TRANSPORT STEP',I6,', TIME STEP',I3,
     2    ', STRESS PERIOD',I3)
      IFIRST=0
C
C8------COPY HEADS FOR THIS LAYER INTO BUFFER.
      DO 44 I=1,NROW
      DO 44 J=1,NCOL
      BUFF(J,I,1)=HNEW(J,I,K)
   44 CONTINUE
C
C9------RECORD CONTENTS OF BUFFER ON UNIT=IHEDUN

      CALL ULASAV(BUFF,TEXT(1),KSTP,KPER,PERTIM,TOTIM,NCOL,NROW,KK,
     1            IHEDUN)
   49 CONTINUE
C
C10-----RETURN
   50 RETURN
      END


      SUBROUTINE SBAS1I(NLAY,ISTRT,IOFLG,INOC,IOUT,IHEDFM,
     1         IDDNFM,IHEDUN,IDDNUN)
C
C-----VERSION 1531 12MAY1987 SBAS1I
C     **************************************************************
C     SET UP OUTPUT CONTROL
C     **************************************************************
C
C        SPECIFICATIONS:
C     ---------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION IOFLG(NLAY,4)
C     ---------------------------------------------------------------
C
C1------TEST UNIT NUMBER FROM IUNIT (INOC) TO SEE IF OUTPUT
C1------CONTROL IS ACTIVE.
      IF(INOC.LE.0) GO TO 600
C
C2------READ AND PRINT FORMATS FOR PRINTING AND UNIT NUMBERS FOR
C2------RECORDING HEADS AND DRAWDOWN. THEN RETURN.
  500 READ (INOC,1)IHEDFM,IDDNFM,IHEDUN,IDDNUN
    1 FORMAT (4I10)
      WRITE (IOUT,3)IHEDFM,IDDNFM
    3 FORMAT (1H0,'HEAD PRINT FORMAT IS FORMAT NUMBER',I4,
     1        '    DRAWDOWN PRINT FORMAT IS FORMAT NUMBER',I4)
      WRITE (IOUT,4)IHEDUN,IDDNUN
    4 FORMAT (1H0,'HEADS WILL BE SAVED ON UNIT',I3,
     1        '    DRAWDOWNS WILL BE SAVED ON UNIT',I3)
      WRITE(IOUT,561)
  561 FORMAT(1H0,'OUTPUT CONTROL IS SPECIFIED EVERY TIME STEP')
      GO TO 1000
C
C3------OUTPUT CONTROL IS INACTIVE. PRINT A MESSAGE LISTING DEFAULTS.
  600 WRITE(IOUT,641)
  641 FORMAT(1H0,'DEFAULT OUTPUT CONTROL -- THE FOLLOWING OUTPUT',
     1      ' COMES AT THE END OF EACH STRESS PERIOD:')
      WRITE(IOUT,642)
  642 FORMAT(1X,'TOTAL VOLUMETRIC BUDGET')
      WRITE(IOUT,643)
  643 FORMAT(1X,10X,'HEAD')
      IF(ISTRT.NE.0)WRITE(IOUT,644)
  644 FORMAT(1X,10X,'DRAWDOWN')
C
C4------SET THE FORMAT CODES EQUAL TO THE DEFAULT FORMAT.
      IHEDFM=0
      IDDNFM=0
C
C5------SET DEFAULT FLAGS IN IOFLG SO THAT HEAD (AND DRAWDOWN) IS
C5------PRINTED FOR EVERY LAYER.
      ID=0
      IF(ISTRT.NE.0) ID=1
  670 DO 680 K=1,NLAY
      IOFLG(K,1)=1
      IOFLG(K,2)=ID
      IOFLG(K,3)=0
      IOFLG(K,4)=0
  680 CONTINUE
      GO TO 1000
C
C6------RETURN
1000  RETURN
      END
      SUBROUTINE SBAS1T(KSTP,KPER,DELT,PERTIM,TOTIM,ITMUNI,IOUT,NTR,
     #            dtrans)
C
C
C-----VERSION 0837 09APR1982 SBAS1T
C     ******************************************************************
C     PRINT SIMULATION TIME
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ------------------------------------------------------------------

      WRITE(IOUT,199) NTR,KSTP,KPER
C0S1--SEAWAT: CHANGING 'TIME' TO 'TRANSPORT'
  199 FORMAT(1H0,///10X,'TIME SUMMARY AT END OF TRANSPORT STEP',I3,
     1     ' IN TIME STEP',I3,' IN STRESS PERIOD',I3)
C
C1------USE TIME UNIT INDICATOR TO GET FACTOR TO CONVERT TO SECONDS.
      CNV=0.
      IF(ITMUNI.EQ.1) CNV=1.
      IF(ITMUNI.EQ.2) CNV=60.
      IF(ITMUNI.EQ.3) CNV=3600.
      IF(ITMUNI.EQ.4) CNV=86400.
      IF(ITMUNI.EQ.5) CNV=31557600.
C
C2------IF FACTOR=0 THEN TIME UNITS ARE NON-STANDARD.
      IF(CNV.NE.0.) GO TO 100
C
C2A-----PRINT TIMES IN NON-STANDARD TIME UNITS.
      WRITE(IOUT,301) DTRANS,DELT,PERTIM,TOTIM
C2AS1--SEAWAT: CONVERTING FROM 'TIME' TO 'TRANSPORT'
cwxg
  301 FORMAT(21X,'TRANSPORT STEP LENGTH =',G15.6/
     1       21X,'   TIME  STEP  LENGTH =',G15.6/
     2       21X,'   STRESS PERIOD TIME =',G15.6/
     3       21X,'TOTAL SIMULATION TIME =',G15.6)
C
C2B-----RETURN
      RETURN
C
C3------CALCULATE LENGTH OF TIME STEP & ELAPSED TIMES IN SECONDS.
C3S1--SEAWAT:Add TRansport step to the table
  100 TRNSEC=CNV*DTRANS
      DELSEC=CNV*DELT
      TOTSEC=CNV*TOTIM
      PERSEC=CNV*PERTIM
C
C4------CALCULATE TIMES IN MINUTES,HOURS,DAYS AND YEARS.
C4S1--SEAWAT:Add Transport step to the table
      TRNMN=TRNSEC/60.
      TRNHR=TRNMN/60.
      TRNDY=TRNHR/24.
      TRNYR=TRNDY/365.25

      DELMN=DELSEC/60.
      DELHR=DELMN/60.
      DELDY=DELHR/24.
      DELYR=DELDY/365.25
      TOTMN=TOTSEC/60.
      TOTHR=TOTMN/60.
      TOTDY=TOTHR/24.
      TOTYR=TOTDY/365.25
      PERMN=PERSEC/60.
      PERHR=PERMN/60.
      PERDY=PERHR/24.
      PERYR=PERDY/365.25
C
C5------PRINT TIME STEP LENGTH AND ELAPSED TIMES IN ALL TIME UNITS.
      WRITE(IOUT,200)
  200 FORMAT(27X,'    SECONDS        MINUTES         HOURS',10X,
     1    'DAYS           YEARS'/27X,75('-'))
C5S1--SEAWAT: CONVERTING FROM 'TIME STEP' TO 'TRANSPORT STEP'
      WRITE (IOUT,204) TRNSEC,TRNMN,TRNHR,TRNDY,TRNYR
  204 FORMAT(1X,'TRANSPORT STEP LENGTH',5X,5G15.6)
      WRITE (IOUT,201) DELSEC,DELMN,DELHR,DELDY,DELYR
  201 FORMAT(1X,'     TIME STEP LENGTH',5X,5G15.6)
      WRITE(IOUT,202) PERSEC,PERMN,PERHR,PERDY,PERYR
  202 FORMAT(1X,'   STRESS PERIOD TIME',5X,5G15.6)
      WRITE(IOUT,203) TOTSEC,TOTMN,TOTHR,TOTDY,TOTYR
  203 FORMAT(1X,'TOTAL SIMULATION TIME',5X,5G15.6)
C
C6------RETURN
      RETURN
      END
      SUBROUTINE SBAS1V(MSUM,VBNM,VBVL,NTR,KSTP,KPER,IOUT) !add ntr
C
C
C-----VERSION 1531 12MAY1987 SBAS1V
C     ******************************************************************
C     PRINT VOLUMETRIC BUDGET
C     ******************************************************************
C
C     SPECIFICATIONS:
C     ------------------------------------------------------------------
	IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*4 VBNM
      DIMENSION VBNM(4,20),VBVL(4,20)
C     ------------------------------------------------------------------
C
C1------DETERMINE NUMBER OF INDIVIDUAL BUDGET ENTRIES.
      MSUM1=MSUM-1
      IF(MSUM1.LE.0) RETURN
C
C2------CLEAR RATE AND VOLUME ACCUMULATORS.
      TOTRIN=0.
      TOTROT=0.
      TOTVIN=0.
      TOTVOT=0.
C
C3------ADD RATES AND VOLUMES (IN AND OUT) TO ACCUMULATORS.
      DO 100 L=1,MSUM1
      TOTRIN=TOTRIN+VBVL(3,L)
      TOTROT=TOTROT+VBVL(4,L)
      TOTVIN=TOTVIN+VBVL(1,L)
      TOTVOT=TOTVOT+VBVL(2,L)
  100 CONTINUE
C
C4------PRINT TIME STEP NUMBER AND STRESS PERIOD NUMBER.
      WRITE(IOUT,260) NTR, KSTP,KPER   !add transport steps
      WRITE(IOUT,265)
C
C5------PRINT INDIVIDUAL INFLOW RATES AND VOLUMES AND THEIR TOTALS.
      DO 200 L=1,MSUM1
      WRITE(IOUT,275) (VBNM(I,L),I=1,4),VBVL(1,L),(VBNM(I,L),I=1,4)
     1,VBVL(3,L)
  200 CONTINUE
      WRITE(IOUT,286) TOTVIN,TOTRIN
C
C6------PRINT INDIVIDUAL OUTFLOW RATES AND VOLUMES AND THEIR TOTALS.
      WRITE(IOUT,287)
      DO 250 L=1,MSUM1
      WRITE(IOUT,275) (VBNM(I,L),I=1,4),VBVL(2,L),(VBNM(I,L),I=1,4)
     1,VBVL(4,L)
  250 CONTINUE
      WRITE(IOUT,298) TOTVOT,TOTROT
C
C7------CALCULATE THE DIFFERENCE BETWEEN INFLOW AND OUTFLOW.
C
C7A-----CALCULATE DIFFERENCE BETWEEN RATE IN AND RATE OUT.
      DIFFR=TOTRIN-TOTROT
C
C7B-----CALCULATE PERCENT DIFFERENCE BETWEEN RATE IN AND RATE OUT.
      PDIFFR=100.*DIFFR/((TOTRIN+TOTROT)/2)
C
C7C-----CALCULATE DIFFERENCE BETWEEN VOLUME IN AND VOLUME OUT.
      DIFFV=TOTVIN-TOTVOT
C
C7D-----GET PERCENT DIFFERENCE BETWEEN VOLUME IN AND VOLUME OUT.
      PDIFFV=100.*DIFFV/((TOTVIN+TOTVOT)/2)
C
C8------PRINT DIFFERENCES AND PERCENT DIFFERENCES BETWEEN INPUT
C8------AND OUTPUT RATES AND VOLUMES.
      WRITE(IOUT,299) DIFFV,DIFFR
      WRITE(IOUT,300) PDIFFV,PDIFFR
C
C9------RETURN
      RETURN
C
C    ---FORMATS
C
C9S1--SEAWAT: SWITCHED FROM VOLUME TO MASS BALANCE
C9S1--SEAWAT: PRINTING TRANSPORT STEP INSTEAD OF TIME STEP
  260 FORMAT(1H0,///30X,'MASS BUDGET FOR ENTIRE MODEL AT END OF'
     1,' TRANSPORT STEP',I3,' IN TIME STEP',I3,' IN STRESS PERIOD',
     2  I3/30X,77('-'))
  265 FORMAT(1H0,19X,'CUMULATIVE MASS',6X,'M',37X
     1,'RATES FOR THIS TRANSPORT STEP',6X,'M/T'/20X,18('-'),47X,24('-')
     2//26X,'IN:',68X,'IN:'/26X,'---',68X,'---')
  275 FORMAT(1X,18X,4A4,' =',G14.5,39X,4A4,' =',G14.5)
  286 FORMAT(1H0,26X,'TOTAL IN =',G14.5,47X,'TOTAL IN ='
     1,G14.5)
  287 FORMAT(1H0,24X,'OUT:',67X,'OUT:'/25X,4('-'),67X,4('-'))
  298 FORMAT(1H0,25X,'TOTAL OUT =',G14.5,46X,'TOTAL OUT ='
     1,G14.5)
  299 FORMAT(1H0,26X,'IN - OUT =',G14.5,47X,'IN - OUT =',G14.5)
  300 FORMAT(1H0,15X,'PERCENT DISCREPANCY =',F20.2
     1,30X,'PERCENT DISCREPANCY =',F20.2,///)
C
      END