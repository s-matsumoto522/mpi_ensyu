program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer procs
    integer myrank

    integer req_s, req_r
    integer, dimension(MPI_STATUS_SIZE) :: sta_s, sta_r

    integer, parameter :: N = 3
    integer array1(N, N), array2(N, N)
    integer iX, iY

    call MPi_Init(ierr)
    call MPI_Comm_Size(MPi_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    !set initial value
    array1(:, :) = 0
    array2(:, :) = 0

    do iY = 1, N
        do iX = 1, N
            array1(iX, iY) = iY + N*(iX - 1)
        enddo
    enddo

    !send Informstion of array1 to array2
    if(myrank == 1) then
        call MPI_Isend(array1(1, 1), N, MPI_INTEGER, 2, 0, MPI_COMM_WORLD, req_s, ierr)
        call MPI_Wait(req_s, sta_s, ierr)
    else if(myrank == 2) then
        call MPI_Irecv(array2(1, 1), N, MPI_INTEGER, 1, 0, MPI_COMM_WORLD, req_r, ierr)
        call MPI_Wait(req_r, sta_r, ierr)
    endif

    !output
    if(myrank == 2) then
        do iX = 1, N
            write(*, *) (array2(iX, iY), iY = 1, 3)
        enddo
    endif
    call MPI_Finalize(ierr)
end program main