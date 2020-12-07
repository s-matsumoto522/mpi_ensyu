program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer procs
    integer myrank
    integer i
    double precision data(1000)
    double precision sum, ave
    character(2) chmyrank

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    data(:) = 0.0d0
    sum = 0.0d0
    ave = 0.0d0

    write(chmyrank, '(i2.2)') myrank
    open(10, file = './data/random_data_'//chmyrank//'.d', status = 'old')
    do i = 1, 1000
        read(10, *) data(i)
        sum = sum + data(i)
    enddo
    close(10)

    call MPI_Reduce(sum, ave, 1, MPI_DOUBLE_PRECISION, MPI_SUM, 0, MPI_COMM_WORLD, ierr)
    ave = ave / dble(1000*procs)

    if(myrank == 0) then
        write(*, *) 'ave : ', ave
    endif
    
    call MPI_Finalize(ierr)
end program main