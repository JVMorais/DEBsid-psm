c
c     Gateway function (a la Matlab) for the trust-region solver in 
c     MINPACK2, gqt.
c
c     soltr should be called as:
c
c     [f, x{, iter, info, par}] = soltr(A, b, delta{, rtol, atol, itmax, par})
c
c     with the items in {} being optional.
c

      subroutine mexFunction(nlhs, plhs, nrhs, prhs)
      implicit none
c
      integer   plhs(*), prhs(*)
      integer*4 nlhs, nrhs

c
c     External Matlab functions
c
      integer    mxGetPr, mxCreateFull
      integer*4  mxGetM, mxGetN
      real*8     mxGetScalar

c
c     Local variables
c

c
c     Outputs
c
      integer    x
      integer*4  iter, info
      real*8     f, par, auxinfo,auxiter

c
c     Inputs
c
      integer    A, b
      integer*4  itmax
      real*8     delta, rtol, atol

c
c     Auxillary variables
c
      integer*4 n, m, p
      integer z, wa1, wa2
      integer zm, wa1m, wa2m

      if ( nrhs .lt. 3 ) then
         call mexErrMsgTxt('At least three input arguments required.')
      elseif ( nlhs .lt. 2 ) then
         call mexErrMsgTxt('At least two output arguments required.')
      endif

c
c     Set up input defaults
c
      rtol = 1.0D-10
      atol = rtol
      itmax = 100
      par = 0.0D0

c
c     Set up and check sanity of inputs
c
      n = mxGetN( prhs(1) )
      m = mxGetM( prhs(1) )

      if ( n .ne. m ) then
         call mexErrMsgTxt('Need square A matrix.')
      endif

      p = mxGetN( prhs(2) )
      m = mxGetM( prhs(2) )

      if ( (max(p,m) .ne. n) .or. (min(p,m) .ne. 1) ) then
         call mexErrMsgTxt('b vector needs to be same size as A')
      endif

      A = mxGetPr( prhs(1) )
      b = mxGetPr( prhs(2) )
      delta = mxGetScalar( prhs(3) )

      if ( delta .lt. 0 ) then
         call mexErrMsgTxt('delta must be greater than zero')
      endif

      if ( nrhs .ge. 4 ) then
         rtol = mxGetScalar( prhs(4) )
      endif

      if ( nrhs .ge. 5 ) then
         atol = mxGetScalar( prhs(5) )
      endif

      if ( nrhs .ge. 6 ) then
         itmax = mxGetScalar( prhs(6) )
      endif

      if ( nrhs .eq. 7 ) then
         par = mxGetScalar( prhs(7) )
      endif

c
c     Set up f and x vector for output
c
      plhs(1) = mxCreateFull(1, 1, 0)
      plhs(2) = mxCreateFull(n, 1, 0)
      x = mxGetPr( plhs(2) )

c
c     Create work matricies
c
      zm = mxCreateFull(n, n, 0)
      wa1m = mxCreateFull(n, n, 0)
      wa2m = mxCreateFull(n, n, 0)
      z = mxGetPr(zm)
      wa1 = mxGetPr(wa1m)
      wa2 = mxGetPr(wa2m)

c
c     Call dgqt, using %VAL for the "pointers" to arrays
c
      call dgqt( n, %VAL(A), n, %VAL(b), delta, rtol, atol, itmax,
     &     par, f, %VAL(x), info, iter,
     &     %VAL(z), %VAL(wa1), %VAL(wa2) )

c
c     Copy f to return
c
      call mxCopyReal8ToPtr( f, mxGetPr(plhs(1)), 1 )

c
c     If we have to, set up and copy the non-required outputs
c
      auxiter = iter
	if ( nlhs .ge. 3 ) then
         plhs(3) = mxCreateFull(1, 1, 0)
         call mxCopyReal8ToPtr( auxiter, mxGetPr(plhs(3)), 1 )
      endif

      auxinfo = info
	if ( nlhs .ge. 4 ) then
         plhs(4) = mxCreateFull(1, 1, 0)
         call mxCopyReal8ToPtr( auxinfo, mxGetPr(plhs(4)), 1 )
      endif
 
      if ( nlhs .ge. 5 ) then
         plhs(5) = mxCreateFull(1, 1, 0)
         call mxCopyReal8ToPtr( par, mxGetPr(plhs(5)), 1 )
      endif

c
c     Free up the work matricies
c
      call mxFreeMatrix( zm )
      call mxFreeMatrix( wa1m )
      call mxFreeMatrix( wa2m )

      end
