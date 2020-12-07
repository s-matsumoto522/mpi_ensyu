program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer procs
    integer myrank
    integer x, y

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    x = 0
    y = 0

    call MPI_Reduce(myrank, x, 1, MPI_INTEGER, MPI_SUM, 0, MPI_COMM_WORLD, ierr)

    if(myrank == 0) then
        write(*, *) 'myrank :', myrank
        write(*, *) 'x :', x
    endif

    call MPI_Allreduce(myrank, y, 1, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr)

    if(myrank == 2) then
        write(*, *) 'myrank :', myrank
        write(*, *) 'y :', y
    endif

    call MPI_Finalize(ierr)
end program main