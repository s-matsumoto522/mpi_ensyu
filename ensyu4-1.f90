program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer procs
    integer myrank
    integer send, recv

    integer req_send, req_recv
    integer, dimension(MPI_STATUS_SIZE) :: sta_send, sta_recv

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    send = 2020
    recv = 0

    !rank1 send to rank2
    if(myrank == 1) then
        call MPI_Isend(send, 1, MPI_INTEGER, 2, 0, MPI_COMM_WORLD, req_send, ierr)
        call MPI_Wait(req_send, sta_send, ierr)
    endif

    !rank2 recieve from rank1
    if(myrank == 2) then
        call MPI_Irecv(recv, 1, MPI_INTEGER, 1, 0, MPI_COMM_WORLD, req_recv, ierr)
        call MPI_Wait(req_recv, sta_recv, ierr)
    endif

    !output
    if(myrank == 2) then
        write(*, *) 'recv :', recv
    endif

    call MPI_Finalize(ierr)
end program main