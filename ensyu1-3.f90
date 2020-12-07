program main
    implicit none
    include 'mpif.h'
    integer ierr    !error code for mpi
    integer myrank
    integer procs
    character(2) chmyrank

    !start mpi parallel
    call MPI_Init(ierr)

    !assign the parallel number into procs
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)

    !assign the rank number into myrank
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)
    write(chmyrank, '(i2.2)') myrank
    open(11, file ='output_'//chmyrank//'.d', status = 'replace')
    if(mod(myrank, 2) == 0) then
        write(11, *) 'HELLO WORLD!!'
        write(11, *) 'myrank: ', myrank
    else
        write(11, *) 'HELLO WORLD!!'
        write(11, *) 'myrank: ', myrank
        write(11, *) 'myrank squared is: ', myrank**2
    endif

    !end mpi parallel
    call MPI_Finalize(ierr)
end program main