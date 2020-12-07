program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer myrank
    integer procs
    integer i
    integer x(10)
    character(2) chmyrank

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)
    write(chmyrank, '(i2.2)') myrank
    if(myrank == 0) then
        open(11, file = 'sample_data.d')
        do i = 1, 10
            read(11, *) x(i)
        enddo
    endif

    call MPI_Bcast(x(1), 10, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)

    !output1
    if(myrank == 1) then
        open(20, file = 'output_'//chmyrank//'.d')
        do i = 1, 10
            write(20, *) x(i)
        enddo
        close(20)
    endif

    !output2
    if(myrank == 2) then
        open(30, file = 'output_'//chmyrank//'.d')
        do i = 1, 10
            write(30, *) x(i)
        enddo
        close(30)
    endif
    !output3
    if(myrank == 3) then
        open(40, file = 'output_'//chmyrank//'.d')
        do i = 1, 10
            write(40, *) x(i)
        enddo
        close(40)
    endif
    call MPI_Finalize(ierr)
end program main