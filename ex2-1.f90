module subprogs
    implicit none
    include 'mpif.h'
    integer, parameter :: NXmax = 100                   !resolution of X
    integer, parameter :: total_step = 20000
    integer, parameter :: file_output = 100
    double precision, parameter :: alpha = 0.5d0    !thermal diffusivity
    double precision, parameter :: Xmin = 0.0d0     !origin of coordinates
    double precision, parameter :: Xmax = 10.0d0    !maximum coordinates
    double precision, parameter :: dt = 5.0d-3      !time step size
    double precision, parameter :: dX = Xmax / dble(NXmax)          !grid size
    double precision, parameter :: beta = alpha*dt / (dX**2)        !relaxation component

    integer NX_procs     !array size of parallel

    !variables for mpi
    integer ierr, procs, myrank
    integer next_rank, former_rank
    integer req1s, req1r, req2s, req2r
    integer, dimension(MPI_STATUS_SIZE) :: sta1s, sta1r, sta2s, sta2r
contains
!****************************
!   set initial conditions  *
!****************************
    subroutine init_settings(Phi, phi_procs)
        double precision, intent(out) :: Phi(0:NXmax+1)     !temperature
        double precision, allocatable :: Phi_procs(:)   !temperature for parallel
        integer iX

        !calculate the size of parallel array
        NX_procs = NXmax / procs            !size of parallel array
        allocate(Phi_procs(0:NX_procs+1))

        !initialize
        Phi(:) = 0.0d0
        Phi_procs(:) = 0.0d0

        !set initial condition
        if(myrank == 0) then
            do iX = 0, NXmax + 1
                Phi(iX) = atan(iX*dX)
            enddo

            !output initial value
            open(20, file = './data_ex2-1/Phi_00000.d')
            do iX = 0, NXmax
                write(20, '(2e17.8)') iX*dX, Phi(iX)
            enddo
            close(20)
        endif

        !send initial value to all rank
        call MPI_Scatter(Phi(1), NX_procs, MPI_DOUBLE_PRECISION, Phi_procs(1) &
                            , NX_procs, MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr)

        !set boundary value
        if(myrank == 0) then
            Phi_procs(0) = 0.0d0
        else if(myrank == procs - 1) then
            Phi_procs(NX_procs+1) = atan(dX*(NXmax+1))
        endif

        !
        next_rank = myrank + 1
        former_rank = myrank - 1

        if(myrank == procs - 1) then
            next_rank = MPI_PROC_NULL
        else if(myrank == 0) then
            former_rank = MPI_PROC_NULL
        endif
    end subroutine init_settings
!********************************
!   MPI boundary communication  *
!********************************
    subroutine MPI_Boundary(Phi_procs)
        double precision, intent(out) :: Phi_procs(0:NX_procs+1)

        !recieve final data from former_rank
        call MPI_Isend(Phi_procs(NX_procs), 1, MPI_DOUBLE_PRECISION, next_rank, 1, MPI_COMM_WORLD, req1s, ierr)
        call MPI_Irecv(Phi_procs(0), 1, MPI_DOUBLE_PRECISION, former_rank, 1, MPI_COMM_WORLD, req1r, ierr)

        !recieve initial data from next_rank
        call MPI_Isend(Phi_procs(1), 1, MPI_DOUBLE_PRECISION, former_rank, 2, MPI_COMM_WORLD, req2s, ierr)
        call MPI_Irecv(Phi_procs(NX_procs+1), 1, MPI_DOUBLE_PRECISION, next_rank, 2, MPI_COMM_WORLD, req2r, ierr)

        !Wait until finishing communications
        call MPI_Wait(req1s, sta1s, ierr)
        call MPI_Wait(req1r, sta1r, ierr)
        call MPI_Wait(req2s, sta2s, ierr)
        call MPI_Wait(req2r, sta2r, ierr)
    end subroutine MPI_Boundary
!*************************
!   solve heat equation  *
!*************************
    subroutine heat_eq_solver(Phi_procs)
        double precision, intent(out) :: Phi_procs(0:NX_procs+1)
        double precision prev_Phi_procs(0:NX_procs+1)
        integer iX

        !SOR method
        prev_Phi_procs(:) = Phi_procs(:)
        do iX = 1, NX_procs
            Phi_procs(iX) = prev_Phi_procs(iX) + beta*(prev_Phi_procs(iX - 1) &
                                            - 2.0d0*prev_Phi_procs(iX) + prev_Phi_procs(iX + 1))
        enddo
    end subroutine heat_eq_solver
!****************
!   output data *
!****************
    subroutine output(Phi_procs, Phi, istep)
        integer, intent(in) :: istep
        double precision, intent(in) :: Phi_procs(0:NX_procs)
        double precision, intent(out) :: Phi(0:NXmax+1)
        integer iX
        character(5) chistep

        !assign all data to Phi
        call MPI_Gather(Phi_procs(1), NX_procs, MPI_DOUBLE_PRECISION, Phi(1), NX_procs &
                            , MPI_DOUBLE_PRECISION, 0, MPI_COMM_WORLD, ierr)
        !output data(at rank 0)
        if(myrank == 0) then
            write(chistep, '(i5.5)') istep
            open(20, file = './data_ex2-1/Phi_'//chistep//'.d')
            do iX = 0, NXmax + 1
                write(20, '(2e17.8)') iX*dX, Phi(iX)
            enddo
            close(20)
        endif
    end subroutine output
end module subprogs

!************
!   main    *
!************
program main
    use subprogs
    implicit none
    integer istep
    double precision Phi(0:NXmax+1)
    double precision, allocatable :: Phi_procs(:)

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    !set initial condition
    call init_settings(Phi, Phi_procs)

    !time steps
    do istep = 1, total_step
        !MPI boundary communication
        call MPI_Boundary(Phi_procs)
        !solve heat equation
        call heat_eq_solver(Phi_procs)
        !output data
        if(mod(istep, file_output) == 0) then
            call output(Phi_procs, Phi, istep)
        endif
    enddo

    call MPI_Finalize(ierr)
end program main
