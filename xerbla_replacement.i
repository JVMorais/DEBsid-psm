











# 1 "xerbla_replacement.f"
      SUBROUTINE XERBLA( SRNAME, INFO )
*
*  Replacement for LAPACK auxiliary routine XERBLA for Matlab
*  external routine use...
*
*     .. Scalar Arguments ..
      CHARACTER*6        SRNAME
      INTEGER            INFO
*     ..
*
*  Purpose
*  =======
*
*  XERBLA  is an error handler for the LAPACK routines.
*  It is called by an LAPACK routine if an input parameter has an
*  invalid value.  A message is printed and execution stops.  This
*  version simply calls mexErrMsgTxt to notify MATLAB.
*
*  Arguments
*  =========
*
*  SRNAME  (input) CHARACTER*6
*          The name of the routine which called XERBLA.
*
*  INFO    (input) INTEGER
*          The position of the invalid parameter in the parameter list
*          of the calling routine.
*
* =====================================================================
*
*     .. Executable Statements ..
*
      call mexErrMsgTxt('Caught a LAPACK parameter error: this should ne
     +ver happen.')

*
*     End of XERBLA
*
      END
