C===============================================================================
c This program is a modified version of perturb_t2 written by Professor Cheinway
c Hwang. The program was modified by Leonardo Pedroso on June 2022.


c The note that came with the original program can be found below.
c ------------------------------------------------------------------------------
c This version uses the rigorous formula of C Hwang (1999)
C Usage:
c	perturb -Ccoeff -Oorbit  -Eperturb -Llmax -Tstart/stop 
c                [-Ptol -Qqmax] 
c
c -C file of difference of geop. coeff. 
c -O file of elements of mean orbit and Kepler elements
c -E file of radial, transverse and normal orbit perturbations 
c -L maximum degree of geopotential coefficients under
c    consideration
c -T start/stop times of the used arc in mjd. 
c -P tolerance of frequency ratio with one cpr. tol >= 0.01 in order to 
c    have a meaningful result
c -Q max of q index in the eccentricity function [default:1]
c  
c Program to compute the perturbations of orbit in the radial,
c transverse and normal directions due to perturbation in 
c the geopotential.
c 
c The formulae of perturbations of the Keplerian elements 
c due to the geopotential are from Kaula, W.: Satellite Geodesy, 1966
c
c Cheinway Hwang
c Dept. of Civil Engineering
c National Chiao Tung University
c 1001 Ta Hsueh Road, Hsinchu 30050
c Taiwan
c Phone: +886-3-5724739
c FAX  : +886-3-5716257
c Email: hwang@geodesy.cv.nctu.edu.tw
c WWW: http://gps.cv.nctu.edu.tw
c
c August 11, 1999
c ------------------------------------------------------------------------------
C===============================================================================

C Include matlab mex compilation header
#include "fintrf.h"

C     Computational subroutine
      subroutine perturb_t2(y, z)
c Inputs    
      real*8  y(8,1), z(6,1)
c Variables
      real*8 time0,a0,e0,incl0,om,m0

c ------------------------------------------------------------------------------

      integer L,M,P,LMAX,K,KK,J,JJ,kmax,i,q,qqmax,qmax,
     1        stderr,nmax,nobs,n_day,count

      real*8 d2r,start,stop,c,s,
     2       ARGU,GMST,Ae,C20,tmp,
     3       PI,TWOPI,tol,Glpq,DGlpq,
     4       n0,Gm,u,mjd_start,radial_d,
     5       ma,w_dot,om_dot,m_dot,mjd,
     6       coex(6),sumc(6),sums(6),a1,a2,a3,a4,a5,a6,sm,cm
c These variables are for Balmino's program
      real*4 ecc,tmp1,tmp2
      


      PARAMETER (NMAX=50,KMAX=(NMAX+1)**2-4,C20=-1082.63d-6,
     1           stderr=0,qqmax=6)
c     2           GM=3986004.415d8,ae=6378136.3d0,,

      real*8 D(NMAX+1,NMAX+1,NMAX+1),BINOC(NMAX*2+1,NMAX*2+1),
     1       FLMP(0:NMAX,0:NMAX,0:NMAX),DFLMP(0:NMAX,0:NMAX,0:NMAX),
     2       G(KMAX,6),RATIO(0:NMAX),pert(3),perte(6),
     3       diffcs(kmax),
     4       coe((nmax+1)*(nmax+2)*(2*nmax+3)/6*(2*qqmax+1),6)

      logical even, MZERO
      
c Variables for input arguments. These variables should not be used in
c the main program.
   	integer ia,nargs,iargc,ic1,ic2
   	character*150 tbuf,cha,ifile1,ifile2,ofile1
   	logical io(20)

c ------------------------------------------------------------------------------
c Set inputs
   	time0 = y(1,1)
   	a0 = y(2,1)
   	m0 = y(3,1)
   	u = y(4,1)
   	e0 = y(5,1)
   	incl0 = y(6,1)
  	om = y(7,1)
   	lmax = y(8,1)

      
c Set parameters

c the code between begin and end below is automaticaly generated, do not
c change the structure
c begin data path
      ifile1 = '/mnt/nfs/home/lpedroso/Desktop/DDELQR_StarlinkCons'//
     1 'tellation/src-osculating2mean/data/egm96_degree360'//
     2 '.ascii'
c end data path

c ------------------------------------------------------------------------------

c 	Validate input degree
	if(LMAX.GT.NMAX) then 
c		write(stderr,*)'Maximum possible degree is ',NMAX,'while degree ', LMAX,' is given.'
		stop
	end if
	mjd_start=0.d0
	tol=0.01
	qmax=1

c 	Open input files
	OPEN(11,FILE=ifile1,status='old') ! difference in coefficients
	call rdcoef(11,diffcs,lmax,kmax,gm,ae)
	CLOSE ( 11, STATUS='KEEP') 
	
c 	Read mean a, e, i 
c	write(0,*)'Mean a, e and i:', a0,' m | ',e0, ' | ',incl0,' rad '
c	write(0,*)'t0 and m0:', time0,' s | ',m0,' rad '
	PI=4.D0*DATAN(1.D0)  
	TWOPI=2.D0*PI
	d2r=PI/180.D0 ! deg to radian factor
c 	Total number of Cnm, Snm coefficents. C00,C10,C11,S11 
c 	are excluded.
	JJ=(LMAX+1)**2-4
	KK=((LMAX+1)*(LMAX+2))/2-3 

	n0=dsqrt(GM/a0**3) !mean motion
	call meanvel(a0,e0,incl0,w_dot,om_dot,m_dot)
c	write(0,*)'w_dot,om_dot,m_dot:',w_dot,om_dot,m_dot
c 	Compute the inclination functions
c	write(stderr,*) 'Computing inclination functions'
	call FLMPCC(incl0,NMAX,LMAX,D,BINOC,FLMP,DFLMP,2)
	tmp=ae/a0
	ratio(0)=1
	ecc=e0
	do l=1,lmax
		ratio(l)=ratio(l-1)*tmp
	end do
c	write(stderr,*)'Computing coefficients'
	count=0
	do L=2,LMAX
		do M=0,L
c			write(stderr,*)'Degree: ',L,' | Order: ',M 
			do P=0,L
				do q=-qmax,qmax
c 					Compute eccentricity function
					call GKAULAF(ecc,L,P,Q,LMAX,QMAX,1,tmp1,tmp2)
      				Glpq=tmp1
      				DGlpq=tmp2
      				CALL coeff(l,m,p,q,FLMP(L,M,P),DFLMP(L,M,P),Glpq,DGlpq,
     1 a0,e0,incl0,tol,ratio(L),n0,w_dot,om_dot,m_dot,coex)
      				count=count+1
      				do ia=1,6
      					coe(count,ia)=coex(ia)
      				end do
      			end do
      		end do
		end do
	end do

c	write(stderr,*)'Computing perturbations in orbit'

	n_day=0
	mjd = time0;

c 	w - arg of perigee
c 	ma - mean anomaly
c om - right asc of ascending node

	call mjd2gmst(mjd,gmst)
	gmst=gmst*twopi
c 	Mean anomaly is computed using the J2 perturbation
c 	m0 is the mean anomaly at the start of the arc
	ma=m0+(mjd-time0)*86400.d0*m_dot
	radial_d= a0*(1-e0*dcos(ma)) ! radial distance

	K=0
	j=0
C	Form the design matrix of the three perturbations
c 	Starting at degree l = 2    
	count=0
	DO 16 L=2,LMAX
		DO 17 M=0,L
c			write(stderr,*)'Degree: ',L,' | Order: ',M 
			even=mod(L-M,2).eq.0
			mzero=M.NE.0
			do ia=1,6
				sumc(ia)=0.d0
				sums(ia)=0.d0
			end do

       		do 15 P=0,L
       			do 15 q=-qmax,qmax
       				count=count+1
       				argu=(l-2*p)*u+q*ma+m*(om-gmst)
       				c=dcos(argu)
					s=dsin(argu)
					IF(even) THEN               
						do ia=1,3
							sumc(ia)=sumc(ia)+coe(count,ia)*c
       					end do
       					do ia=4,6
       						sumc(ia)=sumc(ia)+coe(count,ia)*s
       					end do
       					if(mzero) then
       						do ia=1,3
       							sums(ia)=sums(ia)+coe(count,ia)*s
       						end do
       						do ia=4,6
       							sums(ia)=sums(ia)-coe(count,ia)*c
       						end do
       					end if
					ELSE
						do ia=1,3
							sumc(ia)=sumc(ia)+coe(count,ia)*s
						end do
						do ia=4,6
							sumc(ia)=sumc(ia)-coe(count,ia)*c
						end do
						if(mzero) then
							do ia=1,3
								sums(ia)=sums(ia)-coe(count,ia)*c
							end do
							do ia=4,6
								sums(ia)=sums(ia)-coe(count,ia)*s
							end do
						end if
					END IF
15 			CONTINUE
c			write(stderr,*)'sum C: ',sumc(1),' | sumS: ',sums(1)
			K=K+1
			do ia=1,6
				G(k,ia)=sumc(ia)
			end do
			if(MZERO) then
				j=j+1
 				do ia=1,6
					G(j+KK,ia)=sums(ia)
				end do
			end if
17     	CONTINUE
16	CONTINUE        
c 	Compute perturbations in a, e, i, Omega, w, and M
	do k=1,6
		tmp=0
		do j=1,JJ
			tmp=tmp+G(j,k)*diffcs(j)
		end do
		perte(k)=tmp
	end do

c	write(61,'(f20.8,3f10.4,f16.12)')mjd,(perte(k),k=1,),u
c	write(61,'(6ES14.7)')(perte(k),k=1,6)


c ------------------------------------------------------------------------------

      
c Set Outputs   
      do i =1,6
         z(i,1) = perte(i);
      end do    
      
      return
      end


C     The gateway routine
      subroutine mexFunction(nlhs, plhs, nrhs, prhs)

      integer mxGetM, mxGetN, mxIsNumeric
      integer mxCreateDoubleMatrix
      integer plhs(*), prhs(*)
      integer x_pr, y_pr, z_pr
      integer nlhs, nrhs
      integer m, n, size
      real*8  y(8,1), z(6,1)

C     Check for proper number of arguments. 
      if (nrhs .ne. 1) then
         call mexErrMsgTxt('One input required.')
      elseif (nlhs .ne. 1) then
         call mexErrMsgTxt('One output required.')
      endif

C     Check to see both inputs are numeric.
      if (mxIsNumeric(prhs(1)) .ne. 1) then
         call mexErrMsgTxt('Input #1 is not a numeric.')
      endif

C     Get the size of the input matrix.
      m = mxGetM(prhs(1))
      n = mxGetN(prhs(1))
      size = m*n

C     Create matrix for the return argument.
      plhs(1) = mxCreateDoubleMatrix(m, n, 0)
      y_pr = mxGetPr(prhs(1))
      plhs(1) = mxCreateDoubleMatrix(6, 1, 0)
      z_pr = mxGetPr(plhs(1))

C     Load the data into Fortran arrays.
      call mxCopyPtrToReal8(y_pr, y, size)

C     Call the computational subroutine.
      call perturb_t2(y, z)

C     Load the output into a MATLAB array.
      call mxCopyReal8ToPtr(z, z_pr, 6)

      return
      end
      
      
            SUBROUTINE FLMPCC(RINCL,NMAX,LMAX,D,BINOC,FLMP,DFLMP,iflag)     
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C  PRG COMPUTES THE INCLINATION FUNCTION (UNNORMALIZED  C
C  OR  NORMALIZED)                                     C
C  NOTE: THIS VERSION IS ACCURATE EVEN WHEN N UP TO 50  C
C        THE ENGLIS' PRG FLMPC GIVES ERRORS EVEN WHEN N  C
C        UP TO 36 (UNNORMALIZED CASE)                  C
C  INCLINATION FUNCTION USED: N.V. EMELJANOV ET AL.    C
C  M.G. 1989, VOL 14, NO.2, EQ.(2), P.78               C
C      PARAMETER
C        RINCL...INCLINATION OF SATELITTE IN RADIAN    C
c        NMAX ... max degree of FLMP etc as specified in
c                the calling programs
C        LMAX..  MAXIUM OF DEGREE OF THE COMPUTED      C
C                INCLINATION FUNCTION                  C
C        IFLAG...1 UNNORMALIZED INCLINATION FUNCTION   C
C                WILL BE COMPUTED, ELSE NORMALIZED     C
C                INCLINATION FUNCTION WILL BE COMPUTED C
C                         Y.M. Wang     5-14-1990      C
c Modified by Cheinway Hwang, May 31, 1999.
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
      IMPLICIT real*8 (A-H,O-Z)
      real*8 D(NMAX+1,NMAX+1,NMAX+1),BINOC(NMAX*2+1,NMAX*2+1),
     +FLMP(0:NMAX,0:NMAX,0:NMAX),DFLMP(0:NMAX,0:NMAX,0:NMAX)

      PI=4.D0*DATAN(1.D0)
      PHI=RINCL/2.0
      S=DSIN(PHI)
      C=DCOS(PHI)
      T=DTAN(PHI)
      IF(IFLAG.EQ.1) THEN
cc      WRITE(6,*)'UNNORMALIZED INCLINATION FUNCTION WILL BE COMPUTED'
      CALL FACT(NMAX,LMAX,D,C,S,T)
        ELSE
cc      WRITE(6,*)'NORMALIZED INCLINATION FUNCTION WILL BE COMPUTED'
      CALL NFACT(NMAX,LMAX,D,C,S,T)
        ENDIF
      LMAX2=2*LMAX
      NMAX2=2*NMAX
      CALL BINO(NMAX2,LMAX2,BINOC)
      DO 1 L=2,LMAX
      DO 1 IP=0,L
           J2=2*L-2*IP
      DO 1 M=0,L
           IE=L-M+1
           IE=IE/2
           JJ=L-2*IP-M
           J0=MAX(JJ,0)
           J1=MIN(L-M,J2)
           S0=S**(J0*2)
           C0=C**(J0*2)
           SUM=0.
           DSUM=0.
      DO 2 J=J0,J1
           XX=(-1)**J*BINOC(J2+1,J+1)*BINOC(2*IP+1,L-M-J+1)*S0/C0
           SUM=SUM+XX
           CC=-(3.*L-M-2.*IP-2.*J)*S/C/2.+(M-L+2.*IP+2.*J)*C/S/2.
           DSUM=DSUM+XX*CC
           S0=S0*S*S
           C0=C0*C*C
2     CONTINUE
           FLMP(L,M,IP)=(-1)**IE*SUM*D(L+1,M+1,IP+1)
           DFLMP(L,M,IP)=(-1)**IE*DSUM*D(L+1,M+1,IP+1)
CC           IF(L.LE.10) WRITE(6,*) L,M,IP,FLMP(L,M,IP),DFLMP(L,M,IP)
cc           WRITE(1) L,M,IP,FLMP,DFLMP
1     CONTINUE
cc      WRITE(6,*) 'THE LAST RECORDS'
cc      WRITE(6,*) L,M,IP,FLMP,DFLMP
      RETURN
      END
      SUBROUTINE FACT(NMAX,LMAX,D,C,S,T)
C========================================================
C  SUB. FACT COMPUTES THE FACTOR (L+M)!/2**L/P!/(L-P)!  =
C  *C**(3L-M-2P)*S**(M-L+2P)                            =
C========================================================
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION D(NMAX+1,NMAX+1,NMAX+1)
      D(1,1,1)=1.
      DO 1 L=1,LMAX
           D(L+1,1,1)=D(L,1,1)/2.*C*C/T
      DO 2 M=0,L
           IF(M.EQ.0) GOTO 4
           D(L+1,M+1,1)=(L+M)*D(L+1,M,1)*T
4     DO 3 IP=1,L
3          D(L+1,M+1,IP+1)=D(L+1,M+1,IP)*(L-IP+1)/IP*T*T
2     CONTINUE
1     CONTINUE
      RETURN
      END
      SUBROUTINE BINO(LMM,LM,BINOC)
C=====================================================
C  SUB. BINO COMPUTES BINOMINAL COEFIICIENTS C(N,K)  =
C  BY USING RECURENCE FORMULA                        =
C=====================================================
      DOUBLE PRECISION BINOC(LMM+1,LMM+1)
      DO 1 I=0,LM
1          BINOC(I+1,1)=1.
      DO 2 I=1,LM
C          IB=0
C          WRITE(6,*) I,IB,BINOC(I,1)
      DO 3 J=1,I
           BINOC(I+1,J+1)=BINOC(I+1,J)*(I-J+1.)/J
C          WRITE(6,*) I,J,BINOC(I+1,J+1)
3     CONTINUE
2     CONTINUE
      RETURN
      END
      SUBROUTINE NFACT(NMAX,LMAX,D,C,S,T)
C========================================================
C  SUB. FACT COMPUTES THE FACTOR (L+M)!/2**L/P!/(L-P)!* =
C  NLM*C**(3L-M-2P)*S(M-L+2P)                           =
C    NLM... NORMALIZED FACTOR                           =
C========================================================
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION D(NMAX+1,NMAX+1,NMAX+1)
      D(1,1,1)=DSQRT(2.D0)
      DO 1 L=1,LMAX
           XX=(2.*L+1.)/(2.*L-1.)
           D(L+1,1,1)=D(L,1,1)/2.*C*C/T*DSQRT(XX)
      DO 2 M=0,L
           IF(M.EQ.0) GOTO 4
           XX=(L+M)/(L-M+1.)
           D(L+1,M+1,1)=D(L+1,M,1)*T*DSQRT(XX)
4     DO 3 IP=1,L
3          D(L+1,M+1,IP+1)=D(L+1,M+1,IP)*(L-IP+1)/IP*T*T
2     CONTINUE
1     CONTINUE
      DO 5 L=0,LMAX
      DO 5 IP=0,L
           D(L+1,1,IP+1)=D(L+1,1,IP+1)/DSQRT(2.D0)
5     CONTINUE
      RETURN
      END
          
      SUBROUTINE coeff(l,m,p,q,flmp,dflmp,glpq,dglpq,a,e,i,tol,f,
     1 n,w_dot,om_dot,m_dot,coe)
c Program to compute the amplitude of lumped Fourier coefficients
c in the linear theory
      IMPLICIT NONE
      INTEGER l,m,p,q,k
      real*8 flmp,dflmp,glpq,dglpq,a,e,i,tol,f,
     1 n,w_dot,om_dot,m_dot,coe(6),c,s,t,psi_dot,e1
      call velocity(l,m,p,q,w_dot,om_dot,m_dot,tol,psi_dot)
      if(psi_dot.eq.0.0) then
      do k=1,6
      coe(k)=0.0
      enddo
      else
      c=dcos(i)
      s=dsin(i)
      t=n/psi_dot
      e1=dsqrt(1-e*e)
c Coefficient of a
      coe(1)=2*a*f*flmp*glpq*(l-2*p+q)*t
c Coefficient of e
      coe(2)=f*e1/e*flmp*glpq*(e1*(l-2*p+q)-(l-2*p))*t
c Coefficient of i
      coe(3)=f*flmp*glpq/s/e1*((l-2*p)*c-m)*t
c Coefficient of Omega
      coe(4)=f*dflmp*glpq/s/e1*t
c Coefficient of argument of latitude
      coe(5)=f*(e1*flmp*dglpq/e-c/s/e1*dflmp*glpq)*t
c Coefficient of mean anomaly
c The last term is the second-order effect
      coe(6)=f*flmp*(2*(l+1)*glpq-e1*e1/e*dglpq-3*glpq*
     1 (l-2*p+q)*t)*t

      end if
      RETURN
      END
      subroutine velocity(l,m,p,q,w_dot,om_dot,m_dot,tol,psi_dot)
      implicit none
      integer l,m,p,q
      real*8 w_dot,om_dot,m_dot,tol,psi_dot,we
      parameter(we=7.292115D-5)! mean rotation rate of the earth inrad/sec
      psi_dot=(l-2*p+q)*(w_dot+m_dot)-q*w_dot+m*(om_dot-we)
      if(dabs(psi_dot)/(w_dot+m_dot).lt.tol) psi_dot=0.0
      end

            
       SUBROUTINE MJD2GMST(MJD,GMST)
c Program to compute gmst at given mjd
c
c Input: 
c mjd ... modified Julian day
c Output:
c gmst ... GMST in revolution (1 r = 2*pi= 360 degree )
c
	real*8 TU,GMST,MJD,FRAC
        FRAC=MJD-dint(MJD)
	Tu=(dint(MJD)-51544.5D0)/36525.D0        
	GMST=24110.54841d0+8640184.812866d0*Tu+0.093104D0*Tu**2
     &       -6.2D-6*Tu**3
	GMST=1.002737909350795D0*FRAC+GMST/86400.D0
        GMST=GMST-dint(GMST)
        if(GMST.gt.1.d0) GMST=GMST-1.d0
        if(GMST.lt.0.d0) GMST=GMST+1.d0
	RETURN
	END

      function inm(n,m,cors,lmax)
c Function to compute the sequence number in the 
c following order of C and S coefficients
c
c  C20, C21,C22
C  C30,C31,C32,C33
C  ...
C  CN0,CN1,CN2 ..., CNN 
C
c  S21,S22
C  S31,S32,S33
C  ...
C  SN1,SN2 ..., SNN
C 
C C00,C10,C11,S11 ARE EXCLUDED. N = lmax
C COEFFICIENT
C 
      implicit none
      integer n,m,cors,lmax,inm,k
 
      
      k=(lmax+1)*(lmax+2)/2-3
      if(cors.eq.1) then
         inm=n*(n+1)/2+m-2
      else
         inm=n*(n-1)/2+m +k-1
      end if
      return
      end

      subroutine rdcoef(unit,diffcs,lmax,kmax,gm,ae)
      implicit none
      integer unit,lmax,kmax,inm,n,m
      real*8 diffcs(kmax),c,s,gm,ae
      read(unit,*)gm,ae
1     read(unit,*,end=2)n,m,c,s
      if(n.lt.2) go to 1
      if(n.gt.lmax) go to 2
      diffcs(inm(n,m,1,lmax))=c
      if(m.ne.0) diffcs(inm(n,m,0,lmax))=s
      go to 1
2     return
      end
      
      subroutine meanvel(a,e,incl,w_dot,om_dot,m_dot)
c Program to compute the angular velocities of orbit
c
      implicit none
      real*8  w_dot,m_dot,om_dot,j2,gm,a,i,e,ae,incl,n
      data gm,j2/3986004.415d8,0.00108263d0/
      data ae/6378136.3d0/
      n=dsqrt(gm/a**3)
      i=incl
      w_dot=-j2*3*n*ae**2*(1-5*(dcos(i))**2)/(4*a**2*(1-e**2)**2)
      m_dot = n+ j2*3*n*ae**2*(-1+3*(dcos(i))**2)/(4*a**2*(1-e**2)**1.5)
      om_dot=-j2*3*n*ae**2*dcos(i)/(2*a**2*(1-e**2)**2)
      return
      end

      SUBROUTINE GKAULAF(E,L,P,Q,LMAX,QMAX,IDER,G,DG)
c Program to compute Hansen functions. This code is from Balmino.
C
C  CALCUL DES FONCTIONS DE HANSEN PARTICULIERES G[L,P,Q]](E) DITES
C  DE KAULA,PAR TRANSFORMEE DE FOURIER
C
C***** VAR.IN :
C
C   E : EXCENTRICITE
C   L,P,Q : INDICES DE LA FONCTION (ENTIERS)
C   LMAX : VALEUR MAXIMALE DE L POUR TOUS LES APPELS
C   QMAX : VALEUR MAXIMALE DE IABS(Q) POUR TOUS LES APPELS
C   IDER : CLE POUR CALCUL DE LA DERIVEE 1.ERE PAR RAPPORT A E
C           1 : OUI , 0 ; NON
C
C***** VAR.OUT :
C
C   G : VALEUR DE LA FONCTION
C   DG : VALEUR DE LA DERIVEE (SI IDER=1)
C
C***** METHODE
C
C  PRETABULATION DE A/R,V,M EN NP POINTS DE L'ORBITE,AVEC
C  NP=2*QMAX+4*(LMAX+1)+2+2*INT[(E/2)*100]  PUIS TRANSFORMEE DE FOURIER
C  PAR S/P 'CFOUR'
C
C***** S/P : EKEPLR2,ANGLE,CFOUR
C
C                  G.BALMINO (B.G.I.) 1990
C
      INTEGER P,Q,QMAX,P0
      REAL M
      CHARACTER LQ*1
C
      SAVE PI,NP,ASR,VM,DVE,DRE,C,S,A,B,AP,BP,E0,L0,P0
C
      PARAMETER (LMAX0=100)
      PARAMETER (KQMAX=6,NPMAX=2*KQMAX+4*(LMAX0+1)+2+100)
C
      DIMENSION C(NPMAX,KQMAX),S(NPMAX,KQMAX),A(0:KQMAX),B(KQMAX),
     1          F(NPMAX),ASR(NPMAX),VM(NPMAX),DVE(NPMAX),DRE(NPMAX),
     1          CVM(NPMAX),SVM(NPMAX),AP(0:KQMAX),BP(KQMAX)
C
      DATA E0/-999./,PI/3.141592653589793/,L0/-999/,P0/-999/
C
      IF(E.EQ.E0) GO TO 5
      E0=E
      IF(LMAX.GT.LMAX0) THEN
          LQ='L'
          PRINT 1,LQ,LMAX,LMAX0
          STOP
      END IF
      IF(QMAX.GT.KQMAX) THEN
         LQ='Q'
         PRINT 1,LQ,QMAX,KQMAX
1        FORMAT(///1X,10('*'),'ERREUR S/P GKAULAF : ',A1,'MAX=',I3,
     1   'TROP GRAND - MAX.AUTORISE=',I3)
         STOP
      END IF
      IF(E.GT.0.) GO TO 3
      DO 2 I=-QMAX,QMAX
      A(I)=0.
      B(I)=0.
      AP(I)=0.
2     BP(I)=0.
      A(0)=1.
      GO TO 8
3     NP=2*QMAX+4*(LMAX+1)+2
      NE=50*E
      NP=NP+2*NE
      NP=MIN0(NP,NPMAX)
      DM=2*PI/NP
      UME2=1.-E*E
      AUX=1./UME2
      RAC=SQRT(UME2)
      DO 4 I=1,NP
      M=(I-1)*DM
      EE=EKEPLR2(M,E)
      CE=COS(EE)
      SE=SIN(EE)
      ASR(I)=1./(1.-E*CE)
      CV=(CE-E)*ASR(I)
      SV=RAC*SE*ASR(I)
      DVE(I)=SV*(ASR(I)+AUX)
      DRE(I)=ASR(I)*CV
      VM(I)=ANGLE(CV,SV,KER)-M
4     CONTINUE
      GO TO 55
C
5     IF(L.EQ.L0 .AND. P.EQ.P0) GO TO 8
55    L0=L
      P0=P
      LM2P=L-2*P
      LP1=L+1
      DO 6 I=1,NP
      ARG=LM2P*VM(I)
      CVM(I)=COS(ARG)
      SVM(I)=SIN(ARG)
6     F(I)=ASR(I)**LP1*(CVM(I)+SVM(I))
      CALL CFOUR(NP,F,QMAX,A,B,C,S,IER)
      IF(IDER.EQ.1) THEN
        DO 7 I=1,NP
7       F(I)=ASR(I)**LP1*(LM2P*(CVM(I)-SVM(I))*DVE(I)
     1                    +LP1*(CVM(I)+SVM(I))*DRE(I))
        CALL CFOUR(NP,F,QMAX,AP,BP,C,S,IER)
      END IF
C
8     IF(Q.GT.0) THEN
         G=(A(Q)+B(Q))/2.
         IF(IDER.EQ.1) DG=(AP(Q)+BP(Q))/2.
      ELSE IF(Q.LT.0) THEN
         G=(A(-Q)-B(-Q))/2.
         IF(IDER.EQ.1) DG=(AP(-Q)-BP(-Q))/2.
      ELSE
         G=A(0)
         IF(IDER.EQ.1) DG=AP(0)
      END IF
C
      RETURN
      END
      FUNCTION ANGLE(ACOSA,ASINA,IER)
C
C SI ASINA ET ACOSA SONT NULS IER=1 ET ANGLE=0
C
      IF(ACOSA.NE.0. .OR. ASINA.NE.0.) GO TO 10
      IER=1
      ANGLE=0.
      RETURN
10    IER=0
      ANGLE=ATAN2(ASINA,ACOSA)
      IF(ANGLE.LT.0.) ANGLE=ANGLE+6.2831853071796
      RETURN
      END
      SUBROUTINE CFOUR(N,F,M,A,B,C,S,IER)
C
C S/P DE CALCUL DES COEFFICIENTS DE FOURIER D'UNE FONCTION
C F=A(0)+A(1)*COS(X)+B(1)*SIN(X)+....+A(M)*COS(M*X)+B(M)*SIN(M*X)
C A PARTIR DE N VALEURS F(I) AUX POINTS X(I)=2*PI*(I-1)/N
C
C SI F EST DE PERIODE P ET DEFINIE DE T0 A T0+P,IL FAUT POSER
C X=(T-T0)*2PI/P POUR SE RAMENER A UNE FONCTION DE PERIODE 2PI DEFINIE
C ENTRE 0 ET 2PI
C
C***** VAR.IN :
C
C       N : NOMBRE DE VALEURS DE F
C       F : VECTEUR (DIM.>N) DES F(I)
C       M : ORDRE DU DEVELOPPEMENT DE FOURIER. M EST AU PLUS EGAL A
C            [(N-1)/2]
C
C***** VAR.OUT :
C
C       A,B : COEFFICIENTS DE FOURIER A(0:M),B(1:M)
C       IER : CODE D'ERREUR : 0=O.K. , -1 SI M> [(N-1)/2]
C
C***** TABLEAUX AUXILIAIRES : C,S : DIMENSION (N,M)
C      (NECESSAIRES POUR ACCELERER LE CALCUL LORSQUE N ET M SONT FIXES)
C
C                 ALGORITHME DIRECT , VECTORISE
C
C                    G.BALMINO (B.G.I.) 1990
C
      DIMENSION F(N),A(0:M),B(M),C(N,M),S(N,M)
C
      SAVE PI,N0,M0
C
      DATA PI/3.141592653589793/
      DATA N0/-999/,M0/-999/
C
      IER=0
      IF(M.GT.(N-1)/2) THEN
        IER=-1
        RETURN
      END IF
C
      IF(N.NE.N0) THEN
         N0=N
         DX=(PI+PI)/N
         CDX=COS(DX)
         SDX=SIN(DX)
         C(1,1)=1.
         S(1,1)=0.
         DO 1 I=2,N
         I1=I-1
         C(I,1)=C(I1,1)*CDX-S(I1,1)*SDX
1        S(I,1)=S(I1,1)*CDX+C(I1,1)*SDX
      END IF
      IF(M.GT.M0) THEN
        JINF=MAX0(2,M0+1)
        DO 3 J=JINF,M
        J1=J-1
        DO 2 I=1,N
        C(I,J)=C(I,J1)*C(I,1)-S(I,J1)*S(I,1)
2       S(I,J)=S(I,J1)*C(I,1)+C(I,J1)*S(I,1)
3       CONTINUE
        M0=M
      END IF
C
      DO 5 J=1,M
      AJ=0.
      BJ=0.
      DO 4 I=1,N
      AJ=AJ+F(I)*C(I,J)
4     BJ=BJ+F(I)*S(I,J)
      A(J)=2.*AJ/N
5     B(J)=2.*BJ/N
      SOM=0.
      DO 6 I=1,N
6     SOM=SOM+F(I)
      A(0)=SOM/N
C
      RETURN
      END
      FUNCTION EKEPLR2(ANOM,EX)
C
C  RESOLUTION DE L'EQUATION DE KEPLER (MVT.ELLIPTIQUE) PAR LA METHODE DE
C  MIKKOLA-NIJENHUIS.
C  EX : EXCENTRICITE , ANOM:ANOMALIE MOYENNE .
C        CONVERSION DU S/P TURBO_PASCAL DE NIJENHUIS
C                    G.BALMINO - 1990 -
C
      SAVE AMMIN,EMAX,S2,S4,C2,C4
C
      REAL M,M1
C
      LOGICAL MIKOLA,MBIG,EBIG
C
      PARAMETER (IORD=7,NSTEP=2)
C
C ON PEUT JOUER SUR 'IORD' ET 'NSTEP' SUIVANT LA PRECISION ET LA
C RAPIDITE DEMANDEES.
C EX : (IORD=7,NSTEP=1) <==> (IORD=3,NSTEP=2) SUR C.D.C. POUR
C      EPS=2.E-14
C
      PARAMETER (PI=3.141592653589793,PIM1=PI-1.,HPI=PI/2.,PI2=2.*PI)
C
      DIMENSION F(0:IORD),H(1:IORD)
C
      COMMON/CONTRO/KONV
C-------------------KONV=1 SI CONVERGENCE OBTENUE A "EPS" PRES ,=0 SINON
C
      DATA AMMIN,EMAX/0.45,0.55/
      DATA S2,S4/-0.16605,0.00761/
      DATA C2,C4/-0.83025,0.03805/
      DATA EPS/2.E-14/
C
C  ON MET M ENTRE 0 ET PI
C     SI M > PI , ON PREND 2*PI-M
C
      M=AMOD(ANOM,PI2)
      IF(M.LT.0.) M=M+PI2
C
C  CAS PARTICULIERS
C
      IF(EX.EQ.0.) THEN
        EKEPLR2=M
        RETURN
      END IF
      IF(M.EQ.0.) THEN
        EKEPLR2=0.
        RETURN
      ELSE IF(M.EQ.PI) THEN
        EKEPLR2=PI
        RETURN
      ELSE IF(M.GT.PI) THEN
        M=PI2-M
        MBIG=.TRUE.
      ELSE
        MBIG=.FALSE.
      ENDIF
C
C********** (1) DEMARRAGE - INITIALISATION PAR REGIONS **********
      M1=M+EX
      E1=1.-EX
      MIKOLA=.FALSE.
      IF(M1.GT.PIM1) THEN
         E=(M+EX*PI)/(1.+EX)
C                                      REGION A
      ELSE IF(M1.GT.1.) THEN
         IF(M.GT.AMMIN) THEN
            E=M1
C                                      REGION B
         ELSE
            MIKOLA=.TRUE.
C                                      REGION D  (PARTIE SUP.)
         END IF
      ELSE IF(EX.LT.EMAX) THEN
         E=M/E1
C                                      REGION C
      ELSE
         MIKOLA=.TRUE.
C                                      REGION D  (PARTIE INF.)
      END IF
C
C          CAS DE LA REGION D
C
      IF(MIKOLA) THEN
         DEN=0.5+4.*EX
         P=E1/DEN
         Q=0.5*M/DEN
         Y=SQRT(P**3+Q**2)+Q
         Z2=Y**(2./3.)
C                                RESOLUTION EQUATION 3.EME DEG.
         S=2*Q/(Z2+P*(1.+P/Z2))
C                                MEILLEURE APPROX.(EQU. 5.EME DEG.)
         SSQ=S*S
         SQQ=SSQ*SSQ
         S=S*(1.-0.075*SQQ/(E1+DEN*SSQ+0.375*SQQ))
         E=M+EX*S*(3.-4.*SSQ)
C          CAS DES REGIONS A,B,C - MEILLEURE APPROX.(HALLEY)
      ELSE
         EBIG=(E.GT.HPI)
         IF(EBIG) THEN
           X=PI-E
         ELSE
           X=E
         END IF
         X2=X*X
         SN=X*(1.+X2*(S2+X2*S4))
         CS=1.+X2*(C2+X2*C4)
         IF(EBIG) CS=-CS
C                                SN,CS = APPROX. DE SIN(E),COS(E)
         F2=EX*SN
         F0=E-F2-M
         F1=1.-EX*CS
C                                FORMULE DE HALLEY
         E=E-F0/(F1-0.5*F0*F2/F1)
      END IF
C
C********** (2) ITERATIONS SUIVANTES
C               FORMULES DE HALLEY MODIFIEES , D'ORDRE "IORD"
C               REPETEES 'NSTEP' FOIS          **********
      DO 4 K=1,NSTEP
      ESE=EX*SIN(E)
      ECE=EX*COS(E)
      F(0)=E-ESE-M
      F(1)=1.-ECE
      F(2)=ESE/2.
      F(3)=ECE/6.
      IF(IORD.GT.3) THEN
      DO 1 I=4,IORD
      RI=I
1     F(I)=-F(I-2)/RI/(RI-1.)
      END IF
      DO 3 I=1,IORD
      DELTA=F(I)
      DO 2 J=1,I-1
2     DELTA=DELTA*H(J)+F(I-J)
3     H(I)=-F(0)/DELTA
      E=E+H(IORD)
      IF(ABS(H(IORD)-H(IORD-1)).LE.EPS) THEN
        KONV=1
        IF(MBIG) E=PI2-E
        EKEPLR2=E
        RETURN
      ELSE
        KONV=0
      END IF
4     CONTINUE
C
      IF(MBIG)E=PI2-E
      EKEPLR2=E
      RETURN
      END

      SUBROUTINE SECOND(TIME)
c Program to sum the system and user times 
      REAL*8 TIME
      REAL*4 T(2)
      DATA TOT/0.D0/
      TIME=DTIME(T)+TOT
      TOT=TIME
      RETURN
      END


      subroutine design(u,t,ip,a)
c
c Compute coefficients of design matrix of the empirical parameters
c
c u ... argument of latitude
c t ... time
c ip ... number of empirical parameters
c a ... row vector of the coefficients of the design matrix
c
      implicit none
      integer ip
      real*8 u,t,a(ip),w
c one cpr rate in rad/sec for rocsat-3
      data w/ 1.0365626665207D-03/

c Constant and one cpr terms
      a(1)=1
      a(2)=dcos(u)
      a(3)=dsin(u)
c Resonant terms: time-dependent amplitude  
      a(4)=t*dcos(u)
      a(5)=t*dsin(u)
      a(6)=t*t*dcos(u)
      a(7)=t*t*dsin(u)

c Resonant terms: linear and quadratic terms in time
      a(8)=t
      a(9)=t**2
c Second order terms
      a(10)=t*dsin(2*u)
      a(11)=t*dcos(2*u)
      a(12)=dcos(2*u)
      a(13)=dsin(2*u)
c      a(14)=dcos(0.020036*u)
c     a(15)=dsin(0.020036*u)
c Long period perturbation at 0.02 cpr
      a(14)=dcos(0.020036*w*t)
      a(15)=dsin(0.020036*w*t)
      return
      end

      subroutine write_error
      write(0,*)'Usage: perturb -Ccoeff -Oorbit  -Eperturb -Llmax' 
      write(0,*)'       -Tstart/stop [-Ptol -Qmax]'
      write(0,*)'-C file of difference of geop coefficient'
      write(0,*)'-O file of input orbit'
      write(0,*)'-E file of output perturbations'  
      write(0,*)'-L max degree of harmonic coeff.'
      write(0,*)'-T start/stop times of the used arc in mjd'
      write(0,*)'-P tolerance number of resonce effect [default: 0.01]'
c      write(0,*)'-Q max of q index in the eccentricity function [default:1]'

      return
      end 

